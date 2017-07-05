package io.typefox.yang.types

import com.google.common.base.Supplier
import com.google.common.base.Suppliers
import com.google.common.collect.ImmutableList
import io.typefox.yang.yang.BinaryOperation
import io.typefox.yang.yang.Literal
import io.typefox.yang.yang.Max
import io.typefox.yang.yang.Min
import io.typefox.yang.yang.Range
import io.typefox.yang.yang.util.YangSwitch
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.xbase.lib.Functions.Function1

import static com.google.common.base.Preconditions.checkState

/**
 * Immutable representation of a <a href="https://tools.ietf.org/html/rfc7950#section-9.2.4">YANG range</a>.
 * 
 * @author akos.kitta
 */
class YangRange {

	static val MIN = 'min';
	static val MAX = 'max';

	@Data
	private static class Cut {
		val String endpoint;
		val EObject node;
	}

	@Data
	private static class Segment {
		val Cut lowerBound;
		val Cut upperBound;
	}

	val YangRange parentRange;
	val List<Segment> segments;
	val Supplier<String> minSupplier;
	val Supplier<String> maxSupplier;

	static def create(Range range, YangRange parentRange) {
		return new YangRange(new RangeTransformer(parentRange).apply(range), parentRange);
	}

	static def createBuiltin(String lowerBound, String upperBound) {
		return new YangRange(#[new Cut(lowerBound, null), new Cut('..', null), new Cut(upperBound, null)], null);
	}

	private new(Iterable<Cut> segments, YangRange parentRange) {
		val builder = ImmutableList.builder;
		val itr = segments.toList.listIterator;
		while (itr.hasNext) {
			val lowerCandidate = itr.next;
			val wait = itr.hasNext && itr.next.endpoint == '..'; // We always consume the operators (if any).
			if (wait) {
				builder.add(new Segment(lowerCandidate, itr.next));
				// This must be a `|`. Consume it. Expect when we are done.
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
					null, '''Cannot substitute '«MAX»' keyword when parent range is not specified.''');
				this.parentRange.max;
			} else {
				max.endpoint;
			}
		];
		minSupplier = Suppliers.memoize [
			val min = this.segments.head.lowerBound;
			return if (min.endpoint == MIN) {
				checkState(this.parentRange !==
					null, '''Cannot substitute '«MIN»' keyword when parent range is not specified.''');
				this.parentRange.min;
			} else {
				min.endpoint;
			}
		];
	}

	override toString() {
		return segments.map[label].join(' | ');
	}

	private def String getMin() {
		return minSupplier.get;
	}

	private def String getMax() {
		return maxSupplier.get;
	}

	// Label pattern: `36` or `0..36`.
	private def getLabel(Segment it) {
		val bounds = #[lowerBound, upperBound].map [
			switch (endpoint) {
				case MIN: min
				case MAX: max
				default: endpoint
			}
		];
		return '''«bounds.head»«IF bounds.head != bounds.last»..«bounds.last»«ENDIF»''';
	}

	/**
	 * YANG range visitor that transforms the AST nodes into a list of range strings. 
	 */
	private static class RangeTransformer extends YangSwitch<List<Pair<String, EObject>>> implements Function1<Range, Iterable<Cut>> {

		val YangRange parentRange;

		private new(YangRange parentRange) {
			this.parentRange = parentRange;
		}

		override apply(Range it) {
			doSwitch.map[new Cut(key, value)];
		}

		override caseRange(Range it) {
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
