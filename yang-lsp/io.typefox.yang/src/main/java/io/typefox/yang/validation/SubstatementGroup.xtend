package io.typefox.yang.validation

import com.google.common.base.Splitter
import com.google.common.collect.Range
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.yang.Statement
import java.math.BigDecimal
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.TextRegion
import org.eclipse.xtext.validation.ValidationMessageAcceptor

import static io.typefox.yang.validation.IssueCodes.*
import static io.typefox.yang.yang.YangPackage.Literals.UNKNOWN

import static extension com.google.common.collect.Iterables.skip
import static extension io.typefox.yang.utils.YangNameUtils.*
import static extension java.lang.Integer.parseInt

/**
 * YANG sub-statement validation helper for checking sub-statement ordering and cardinality.
 * 
 * @author akos.kitta
 */
class SubstatementGroup {

	val boolean ordered;
	val Map<SubstatementConstraint, String> orderedConstraint;
	val Map<EClass, SubstatementConstraint> constraintMapping;

	var ordinal = 0;

	package new(boolean ordered) {
		this.ordered = ordered;
		this.orderedConstraint = newHashMap();
		this.constraintMapping = newHashMap();
	}

	def any(EClass clazz) {
		return any(null, clazz);
	}

	def any(String version, EClass clazz) {
		return add(version, clazz, Cardinality.ANY);
	}

	def must(EClass clazz) {
		return must(null, clazz);
	}

	def must(String version, EClass clazz) {
		return add(version, clazz, Cardinality.MUST);
	}

	def atLeastOne(EClass clazz) {
		return atLeastOne(null, clazz);
	}

	def atLeastOne(String version, EClass clazz) {
		return add(version, clazz, Cardinality.AT_LEAST_ONE);
	}

	def optional(EClass clazz) {
		return optional(null, clazz);
	}

	def optional(String version, EClass clazz) {
		return add(version, clazz, Cardinality.OPTIONAL);
	}

	private def add(String version, EClass clazz, Cardinality cardinality) {
		val constraint = new SubstatementConstraint(version, clazz, cardinality);
		constraintMapping.put(clazz, constraint);
		orderedConstraint.put(constraint, '''«ordinal»''');
		if (ordered) {
			ordinal++;
		}
		return this;
	}

	def with(SubstatementGroup ruleGroup) {
		constraintMapping.putAll(ruleGroup.constraintMapping);
		ruleGroup.orderedConstraint.forEach [ constraint, ordinal |
			// If the constraint we are adding is contained in an unordered group and
			// we are processing an unordered group too, then do not convert ordinal `0`
			// into `0.0` but leave as is.
			val mergedOrdinal = if (!ordered && this.ordinal.toString == ordinal) {
					'''«this.ordinal»''';
				} else {
					'''«this.ordinal».«ordinal»''';
				};
			orderedConstraint.put(constraint, mergedOrdinal);
		];
		if (ordered) {
			ordinal++;
		}
		return this;
	}

	def void checkSubstatements(Statement substatementContainer, ValidationMessageAcceptor acceptor) {

		val substatements = substatementContainer.substatements;
		val substatementTypes = substatements.toMap([eClass]);
		constraintMapping.filter[clazz, constraint|constraint.cardinality === Cardinality.MUST].keySet.filter [
			!substatementTypes.containsKey(it);
		].forEach [
			val message = '''Missing mandatory substatement: '«yangName»'.''';
			val range = getKeywordRange(substatementContainer);
			acceptor.acceptError(message, substatementContainer, range.offset, range.length, SUBSTATEMENT_CARDINALITY);
		];
		substatements.forEach [ statement, index |
			checkStatementInContext(statement, substatementContainer, acceptor);
		];
	}

	private def TextRegion getKeywordRange(Statement stmnt) {
		val node = NodeModelUtils.getNode(stmnt).leafNodes.findFirst[grammarElement instanceof Keyword]
		return new TextRegion(node.offset, node.length)
	}

	def boolean canInsert(Statement substatementContainer, EClass toInsert, int toInsertIndex) {

		// We do not allow anything but those types first which satisfies the mandatory cardinalities.
		val missingMandatoryTypes = substatementContainer.missingMandatoryTypes;
		// If there are any mandatory ones and the `toInsert` type is not among them. Return.
		if (!missingMandatoryTypes.empty && !substatementContainer.missingMandatoryTypes.exists[it === toInsert]) {
			return false;
		}

		val constraint = constraintMapping.get(toInsert);

		// Unexpected statement.
		if (constraint === null) {
			return false;
		}

		val cardinality = constraint.cardinality;
		val substatements = substatementContainer.substatements;
		// Increment the counter by 1 to imitate its existence.
		val elementCount = substatements.filter(toInsert.instanceClass).size + 1;

		// Cardinality issue.
		if (!cardinality.contains(elementCount)) {
			return false;
		}

		// YANG version aware cardinality issue.
		val version11 = substatementContainer.version11;
		if (constraint.version11 && !version11) {
			return false;
		}

		// List of existing sub-statements: [s0, s1, insterAfter, offset (<|>), instertBefore, s4, s5...].
		if (!substatements.empty) {
			val insertAfterStatement = substatements.get(toInsertIndex);
			val insertAfterConstraint = constraintMapping.get(insertAfterStatement.eClass);
			if (insertAfterStatement.eClass !== UNKNOWN && constraint != insertAfterConstraint) {
				val ordinal = orderedConstraint.get(constraint);
				val insertAfterOrdinal = orderedConstraint.get(insertAfterConstraint);
				if (insertAfterOrdinal.isGreater(ordinal)) {
					return false;
				} else if (toInsertIndex + 1 < substatements.size) {
					val insertBeforeStatement = substatements.get(toInsertIndex + 1);
					val insertBeforeConstraint = constraintMapping.get(insertBeforeStatement.eClass);
					if (insertBeforeStatement.eClass !== UNKNOWN && constraint != insertBeforeConstraint) {
						val insertBeforeOrdinal = orderedConstraint.get(insertBeforeConstraint);
						if (ordinal.isGreater(insertBeforeOrdinal)) {
							return false;
						}
					}
				}
			}
		}

		return true;
	}

	def private getMissingMandatoryTypes(Statement substatementContainer) {
		val substatements = substatementContainer.substatements;
		val substatementTypes = substatements.toMap([eClass]);
		return constraintMapping.filter[clazz, constraint|constraint.cardinality === Cardinality.MUST].keySet.filter [
			!substatementTypes.containsKey(it);
		];
	}

	private def void checkStatementInContext(Statement statement, Statement substatementContainer,
		ValidationMessageAcceptor acceptor) {

		val substatements = substatementContainer.substatements;
		val clazz = statement.eClass
		if (clazz === UNKNOWN) {
			// Extensions are fine everywhere.
			return;
		}
		val constraint = constraintMapping.get(clazz);
		val range = getKeywordRange(statement);
		val version11 = substatementContainer.isVersion11;

		// Unexpected statement.
		if (constraint === null) {
			val message = '''Unexpected substatement: '«clazz.yangName»'.''';
			acceptor.acceptError(message, statement, range.offset, range.length, UNEXPECTED_SUBSTATEMENT);
			return;
		}

		// Cardinality issue.
		val cardinality = constraint.cardinality;
		val elementCount = substatements.filter(clazz.instanceClass).size;
		if (!cardinality.contains(elementCount)) {
			val message = '''Expected '«clazz.yangName»' with «cardinality» cardinality. Got «elementCount» instead.''';
			acceptor.acceptError(message, statement, range.offset, range.length, SUBSTATEMENT_CARDINALITY);
			return;
		}

		// YANG version aware cardinality issue.
		if (constraint.version11 && !version11) {
			val message = '''Statment '«clazz.yangName»' requires explicit YANG version «YangExtensions.YANG_1_1».''';
			acceptor.acceptError(message, statement, range.offset, range.length, SUBSTATEMENT_CARDINALITY);
			return;
		}

		// Ordering issue.
		val index = substatements.indexOf(statement);
		// No need to check the zero index and if it does not contained in the context.
		// The latter one must not happen anyway. 
		if (index < 0) {
			throw new IllegalStateException('''The context does not contain the given statement: «substatements», «statement».''');
		}

		var i = index - 1; // -1 since we do not have to compare the statement argument with itself.
		while (i >= 0) {
			val precedingStatement = substatements.get(i);
			val precedingConstraint = constraintMapping.get(precedingStatement.eClass);

			// Do not check statements for the same constraint and ignore extensions (Unknown) as they are valid everywhere.
			if (precedingStatement.eClass !== UNKNOWN && constraint != precedingConstraint) {
				val ordinal = orderedConstraint.get(constraint);
				val precedingOrdinal = orderedConstraint.get(precedingConstraint);
				if (precedingOrdinal.isGreater(ordinal)) {
					val message = '''Substatement '«clazz.yangName»' must be declared before '«precedingStatement.yangName»'.''';
					acceptor.acceptError(message, statement, range.offset, range.length, SUBSTATEMENT_ORDERING);
					return;
				}
			}
			i--;
		}

	}

	private def isGreater(String left, String right) {
		return left.value.compareTo(right.value) > 0;
	}

	/**
	 * Converts the string given in {@code \d(.\d)*} format into a big decimal.
	 * For instance 0.0.1 will be 0,01 while 2.1.2.3 will be 2,123 value.
	 */
	private def getValue(String it) {
		val segments = Splitter.on(".").trimResults.splitToList(it).map[parseInt];
		return new BigDecimal('''«segments.head».«segments.skip(1).join»''');
	}

	private def isVersion11(EObject it) {
		val resource = it?.eResource
		if (resource instanceof XtextResource) {
			val yangExtensions = resource.resourceServiceProvider.get(YangExtensions);
			val version = yangExtensions.getYangVersion(it);
			return YangExtensions.YANG_1_1 == version;
		}
		return false;
	}

	@Data
	private static class SubstatementConstraint {

		val String version;
		val EClass clazz;
		val Cardinality cardinality;

		override toString() {
			return '''«clazz.yangName» «cardinality»«IF !version.nullOrEmpty» [Version: «version»]«ENDIF»''';
		}

		def boolean isVersion11() {
			return YangExtensions.YANG_1_1 == version;
		}

	}

	private static class Cardinality {

		public static val ANY = new Cardinality(Range.closed(0, Integer.MAX_VALUE));
		public static val OPTIONAL = new Cardinality(Range.closed(0, 1));
		public static val MUST = new Cardinality(Range.closed(1, 1));
		public static val AT_LEAST_ONE = new Cardinality(Range.closed(1, Integer.MAX_VALUE));

		val Range<Integer> delegate;

		private new(Range<Integer> delegate) {
			this.delegate = delegate;
		}

		private def boolean contains(int i) {
			return delegate.contains(i);
		}

		override toString() {
			if (delegate.upperEndpoint == Integer.MAX_VALUE) {
				return '''[«delegate.lowerEndpoint»..*]''';
			}
			return '''«delegate»''';
		}

	}

}
