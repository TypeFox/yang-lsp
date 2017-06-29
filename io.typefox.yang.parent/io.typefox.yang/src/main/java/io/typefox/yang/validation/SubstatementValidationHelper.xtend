package io.typefox.yang.validation

import com.google.common.base.Preconditions
import com.google.common.base.Splitter
import com.google.common.collect.ImmutableList
import com.google.common.collect.Range
import io.typefox.yang.yang.Statement
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.diagnostics.Severity

import static io.typefox.yang.validation.YangIssueCodes.*

import static extension io.typefox.yang.utils.YangNameUtils.*
import static extension java.lang.Integer.parseInt

/**
 * YANG sub-statement validation helper for checking sub-statement ordering and cardinality.
 * 
 * @author akos.kitta
 */
abstract class SubstatementValidationHelper {

	public static class SubstatementGroup {

		val boolean ordered;
		val Map<SubstatementConstraint, String> orderedConstraint;
		val Map<EClass, SubstatementConstraint> constraintMapping;

		var ordinal = 0;

		package new() {
			this(true);
		}

		package new(boolean ordered) {
			this.ordered = ordered;
			this.orderedConstraint = newHashMap();
			this.constraintMapping = newHashMap();
		}

		def any(EClass clazz) {
			return add(clazz, Cardinality.ANY);
		}

		def optional(EClass clazz) {
			return add(clazz, Cardinality.OPTIONAL);
		}

		def must(EClass clazz) {
			return add(clazz, Cardinality.MUST);
		}

		private def add(EClass clazz, Cardinality cardinality) {
			val constraint = new SubstatementConstraint(clazz, cardinality);
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
				orderedConstraint.put(constraint, '''«this.ordinal».«ordinal»''');
			];
			if (ordered) {
				ordinal++;
			}
			return this;
		}

		def Status checkStatementInContext(Statement statement, Statement substatementContainer) {
			val substatements = substatementContainer.subStatements;
			val clazz = statement.eClass
			val constraint = constraintMapping.get(clazz);

			// Unexpected statement.
			if (constraint === null) {
				val message = '''Unexpected substatement: '«clazz.yangName»'.''';
				return Status.error(message, UNEXPECTED_SUBSTATEMENT);
			}

			// Cardinality issue.
			val cardinality = constraint.cardinality;
			val elementCount = substatements.filter(clazz.instanceClass).size;
			if (!cardinality.contains(elementCount)) {
				val message = '''Expected '«clazz.yangName»' with «cardinality» cardinality. Got «elementCount» instead.''';
				return Status.error(message, SUBSTATEMENT_CARDINALITY);
			}

			// Ordering issue.
			val index = substatements.indexOf(statement);
			// No need to check the zero index and if it does not contained in the context.
			// The latter one must not happen anyway. 
			if (index < 0) {
				throw new IllegalStateException('''The context does not conatin the given statement: «substatements», «statement».''');
			}

			var i = index - 1; // -1 since we do not have to compare the statement argument with itself.
			while (i >= 0) {
				val precedingStatement = substatements.get(i);
				val precedingConstraint = constraintMapping.get(precedingStatement.eClass);
				// Do not check statements for the same constraint.
				if (constraint != precedingConstraint) {
					val ordinal = orderedConstraint.get(constraint);
					val precedingOrdinal = orderedConstraint.get(precedingConstraint);
					if (precedingOrdinal.isGreater(ordinal)) {
						val message = '''Substatement '«clazz.yangName»' must be declared before '«precedingStatement.yangName»'.''';
						return Status.error(message, SUBSTATEMENT_ORDERING);
					}
				}
				i--;
			}

			return Status.OK;
		}

		def Status checkContext(Statement substatementContainer) {
			val substatements = substatementContainer.subStatements.toMap([eClass]);
			val issues = constraintMapping.filter[clazz, constraint|constraint.cardinality === Cardinality.MUST].keySet.
				filter[!substatements.containsKey(it)].map [
					val message = '''Missing mandatory substatement: '«yangName»'.''';
					Status.error(message, SUBSTATEMENT_CARDINALITY);
				].toList;
			return if(issues.nullOrEmpty) Status.OK else new MultiStatus(Severity.ERROR, "", issues);
		}

		private def isGreater(String left, String right) {
			val ordinals = [Splitter.on(".").trimResults.splitToList(it).map[parseInt]];
			val leftOrdinals = ordinals.apply(left);
			val rightOrdinals = ordinals.apply(right);
			Preconditions.checkArgument(!leftOrdinals.nullOrEmpty, '''Cannot parse ordinals: «left».''');
			Preconditions.checkArgument(!rightOrdinals.nullOrEmpty, '''Cannot parse ordinals: «right».''');
			for (var i = 0; i < leftOrdinals.size; i++) {
				if (rightOrdinals.size > i) {
					if (leftOrdinals.get(i) > rightOrdinals.get(i)) {
						return true;
					} else if (leftOrdinals.get(i) < rightOrdinals.get(i)) {
						return false;
					}
				} else {
					return false;
				}
			}
			return rightOrdinals.size > leftOrdinals.size;
		}

	}

	@Data
	public static class SubstatementConstraint {

		val EClass clazz;
		val Cardinality cardinality;

		override toString() {
			return '''«clazz.instanceClass.simpleName» «cardinality»'''
		}

	}

	public static class Cardinality {

		public static val ANY = new Cardinality(Range.closed(0, Integer.MAX_VALUE));
		public static val OPTIONAL = new Cardinality(Range.closed(0, 1));
		public static val MUST = new Cardinality(Range.closed(1, 1));

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

	@Data
	public static class Status {

		static val OK = new Status(Severity.INFO, "", null);

		private static def error(String message, String issueCode) {
			return new Status(Severity.ERROR, message, issueCode);
		}

		val Severity severity;
		val String message;
		val String issueCode;

		def boolean isOK() {
			return severity === Severity.INFO;
		}

	}

	public static class MultiStatus extends Status {

		val List<Status> children;

		new(Severity severity, String message) {
			this(severity, message, newArrayList());
		}

		new(Severity severity, String message, List<? super Status> children) {
			super(severity, message, null);
			this.children = ImmutableList.copyOf(children as List<Status>);
		}

		def List<Status> getChildren() {
			return children;
		}

	}
	
	private new() {
		
	}

}
