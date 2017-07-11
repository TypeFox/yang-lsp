package io.typefox.yang.utils

import com.google.common.base.Preconditions
import com.google.common.base.Supplier
import com.google.common.base.Suppliers
import com.google.common.collect.ImmutableList
import io.typefox.yang.yang.BinaryOperation
import io.typefox.yang.yang.Literal
import io.typefox.yang.yang.Max
import io.typefox.yang.yang.Min
import io.typefox.yang.yang.Refinable
import io.typefox.yang.yang.util.YangSwitch
import java.math.BigDecimal
import java.util.Comparator
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.validation.ValidationMessageAcceptor
import org.eclipse.xtext.xbase.lib.Functions.Function1

import static com.google.common.base.Preconditions.checkState
import static io.typefox.yang.validation.IssueCodes.*
import static io.typefox.yang.yang.YangPackage.Literals.*

import static extension io.typefox.yang.utils.ValidationMessageAcceptorExt.wrappedAcceptor

/**
 * Immutable representation of a <a href="https://tools.ietf.org/html/rfc7950#section-9.2.4">YANG refinable</a>.
 * 
 * @author akos.kitta
 */
class YangRefinable {

	/**
	 * NOOP refinable. The validation does nothing on this instance.
	 */
	public static val NOOP = new YangRefinable(emptyList, null) {

		override validate(ValidationMessageAcceptor it) {
			return true;
		}

		override toString() {
			return 'NOOP';
		}

	};

	static val MIN = 'min';
	static val MAX = 'max';

	/**
	 * Null-safe comparator that creates {@link BigDecimal}s from the string literal arguments and compares the
	 * values of the big decimals.
	 * <p>
	 * The arguments could be {@code null}, but if present must be a valid value literal.
	 * 
	 * @see BigDecimal#BigDecimal(String)
	 */
	static val Comparator<String> NUMBER_LITERAL_COMPARATOR = [ left, right |
		val nullSafe = Comparator.<BigDecimal>nullsLast[o1, o2|o1.compareTo(o2)];
		return nullSafe.compare(VALUE_CONVERTER.apply(left), VALUE_CONVERTER.apply(right));
	];

	static val (String)=>BigDecimal VALUE_CONVERTER = [
		if (it === null) {
			return null;
		}
		try {
			return new BigDecimal(it);
		} catch (NumberFormatException e) {
			e.printStackTrace
			return null
		}
	];

	val YangRefinable parentRange;
	val List<Segment> segments;
	val Supplier<String> minSupplier;
	val Supplier<String> maxSupplier;

	/**
	 * Use {@link YangTypeExtensions#getYangRange(Range)} instead.
	 */
	static def create(Refinable refinable, YangRefinable parentRange) {
		Preconditions.checkNotNull(parentRange, 'parentRange');
		return new YangRefinable(new RefinableTransformer().apply(refinable), parentRange);
	}

	/**
	 * This should be used only for built-in type definition.
	 */
	static def createBuiltin(String lowerBound, String upperBound) {
		return new YangRefinable(#[new Cut(lowerBound, null), new Cut('..', null), new Cut(upperBound, null)], null);
	}

	private new(Iterable<Cut> segments, YangRefinable parentRange) {
		val builder = ImmutableList.builder;
		val itr = segments.toList.listIterator;
		while (itr.hasNext) {
			val lowerCandidate = itr.next;
			val wait = itr.hasNext && itr.next.endpoint == '..'; // We always consume the operators (if any).
			if (wait) {
				builder.add(new Segment(lowerCandidate, itr.next));
				// This must be a PIPE character or the end of iterator.
				if (itr.hasNext) {
					itr.next;
				}
			} else {
				builder.add(new Segment(lowerCandidate, lowerCandidate));
			}
		}
		this.segments = builder.build;
		this.parentRange = parentRange;
		maxSupplier = Suppliers.memoize [
			val max = this.segments.last.upperBound;
			return if (max.endpoint == MAX) {
				checkState(this.parentRange !==
					null, '''Cannot substitute '«MAX»' keyword when parent refinement is not specified.''');
				this.parentRange.max;
			} else {
				max.endpoint;
			}
		];
		minSupplier = Suppliers.memoize [
			val min = this.segments.head.lowerBound;
			return if (min.endpoint == MIN) {
				checkState(this.parentRange !==
					null, '''Cannot substitute '«MIN»' keyword when parent refinement is not specified.''');
				this.parentRange.min;
			} else {
				min.endpoint;
			}
		];
	}

	/**
	 * Returns {@code true} if the refinement is valid, otherwise returns {@code false}.
	 */
	def validate(ValidationMessageAcceptor it) {
		// There should be nothing to do for built-in types.
		if (parentRange === null) {
			return true;
		}
		val acceptor = wrappedAcceptor;
		return checkDisjointOrder(acceptor) && checkContains(parentRange, acceptor);
	}

	override toString() {
		return segments.map[label].join(' | ');
	}

	/**
	 * If multiple values or refinement are given, they all must be disjoint and must be in ascending order.
	 * 
	 * See: https://tools.ietf.org/html/rfc7950#section-9.2.4 
	 */
	private def checkDisjointOrder(ValidationMessageAcceptorExt acceptor) {
		for (var i = 1; i < segments.size; i++) {
			val previous = segments.get(i - 1).substitute(this);
			val current = segments.get(i).substitute(this);
			val message = if (current.lowerBound.isLessThanOrEqual(previous.upperBound)) {
					'''Each range restriction must be disjoint.''';
				} else if (current.upperBound.isLessThanOrEqual(previous.lowerBound)) {
					'''Each range restriction must be in ascending order.''';
				} else {
					null
				};
			if (message !== null) {
				acceptError(current, acceptor, message);
			}
		}
		return !acceptor.hasError;
	}

	/**
	 * Checks whether the segment argument is contained in the current segment.
	 * More formally, the lower bound of the current is less than or equals the lower 
	 * bound of the other, and the upper bound of the argument is less than or equals 
	 * the upper bound of the current one.
	 * 
	 * See: https://tools.ietf.org/html/rfc7950#section-9.2.4 
	 */
	private def checkContains(YangRefinable other, ValidationMessageAcceptorExt acceptor) {
		segments.map[substitute(this)].forEach [ current |
			if (!other.segments.map[substitute(other)].exists [ parent |
				// parent lower is less than or equals to the current lower
				// and the current upper is less than the or equal to the parent upper
				parent.lowerBound.isLessThanOrEqual(current.lowerBound) &&
					current.upperBound.isLessThanOrEqual(parent.upperBound);
			]) {
				// Use the lower bound for both refinements and concrete values to log the error.
				val message = '''The «IF current.range»range«ELSE»explicit value«ENDIF» "«current»" is not valid for the base type.'''
				current.acceptError(acceptor, message);
			}
		];
		return !acceptor.hasError;
	}

	private def acceptError(Segment segment, extension ValidationMessageAcceptor acceptor, String message) {
		val lowerBound = segment.lowerBound;
		val astNode = lowerBound.node;
		val code = TYPE_ERROR;
		val index = ValidationMessageAcceptor.INSIGNIFICANT_INDEX;
		val object = if (astNode.eContainer instanceof BinaryOperation) {
				astNode.eContainer;
			} else {
				astNode;
			};

		if (object instanceof Literal) {
			acceptError(message, object, LITERAL__VALUE, index, code);
		} else if (object instanceof Min || object instanceof Max) {
			val op = object.eContainer as BinaryOperation;
			val feature = if(op.right === object) BINARY_OPERATION__RIGHT else BINARY_OPERATION__RIGHT;
			acceptError(message, op, feature, index, code);
		} else if (object instanceof BinaryOperation) {
			val feature = if (object.operator == '..') {
					null;
				} else if (object.right === astNode) {
					BINARY_OPERATION__RIGHT
				} else if (object.left === astNode) {
					BINARY_OPERATION__LEFT
				} else {
					null;
				}
			acceptError(message, object, feature, index, code);
		}
	}

	private def String getMin() {
		return minSupplier.get;
	}

	private def String getMax() {
		return maxSupplier.get;
	}

	// Label pattern: `36` or `0..36`. Also, `min` and `max` should be substituted.
	// This is used only for testing and debugging purposes.
	private def getLabel(Segment it) {
		val bounds = #[lowerBound, upperBound].map[substitute(this)].map[endpoint];
		return '''«bounds.head»«IF bounds.head != bounds.last»..«bounds.last»«ENDIF»''';
	}

	@Data
	private static class Cut implements Comparable<Cut> {
		val String endpoint;
		val EObject node;

		override compareTo(Cut o) {
			return NUMBER_LITERAL_COMPARATOR.compare(endpoint, o?.endpoint);
		}

		private def boolean isLessThanOrEqual(Cut o) {
			return !(compareTo(o) > 0);
		}

		private def Cut substitute(YangRefinable conatiner) {
			return switch (endpoint) {
				case MIN: new Cut(conatiner.min, node)
				case MAX: new Cut(conatiner.max, node)
				default: this
			};
		}

	}

	@Data
	private static class Segment {
		val Cut lowerBound;
		val Cut upperBound;

		private def Segment substitute(YangRefinable conatiner) {
			val sLoweBound = lowerBound.substitute(conatiner);
			val sUpperBound = upperBound.substitute(conatiner);
			if (lowerBound !== sLoweBound || upperBound !== sUpperBound) {
				return new Segment(sLoweBound, sUpperBound);
			}
			return this;
		}

		private def isRange() {
			return lowerBound.endpoint != upperBound.endpoint;
		}

		override toString() {
			return '''«lowerBound.endpoint»«IF range»..«upperBound.endpoint»«ENDIF»''';
		}

	}

	/**
	 * YANG refinement visitor that transforms the AST nodes into a list of range strings. 
	 */
	private static class RefinableTransformer extends YangSwitch<List<Pair<String, EObject>>> implements Function1<Refinable, Iterable<Cut>> {

		override apply(Refinable it) {
			return doSwitch.map[new Cut(key, value)];
		}

		override caseRefinable(Refinable it) {
			return doSwitch(expression);
		}

		override caseBinaryOperation(BinaryOperation it) {
			val builder = ImmutableList.builder;
			builder.addAll(doSwitch(left)).add(operator.trim -> null).addAll(doSwitch(right));
			return builder.build;
		}

		override caseMin(Min it) {
			return #[MIN -> it];
		}

		override caseMax(Max it) {
			return #[MAX -> it];
		}

		override caseLiteral(Literal it) {
			return #[value.trim -> it];
		}

	}

}
