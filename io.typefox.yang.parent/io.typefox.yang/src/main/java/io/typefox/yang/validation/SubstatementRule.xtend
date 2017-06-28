package io.typefox.yang.validation

import com.google.common.base.Preconditions
import com.google.common.base.Splitter
import com.google.common.collect.Range
import io.typefox.yang.yang.Statement
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtend.lib.annotations.Data

import static extension java.lang.Integer.parseInt

interface SubstatementRule {

	public static class SubstatementGroup implements SubstatementRule {

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

		def boolean isValidInContext(Statement statement, List<? extends Statement> context) {
			val clazz = statement.eClass
			val constraint = constraintMapping.get(clazz);

			// Unexpected statement.
			if (constraint === null) {
				println('Unexpected keyword: ' + clazz.instanceClass.simpleName);
				return false;
			}

			// Cardinality issue.
			val cardinality = constraint.cardinality;
			val elementCount = context.filter(clazz.instanceClass).size;
			if (!cardinality.contains(elementCount)) {
				println('Cardinality error. Expected: ' + cardinality + ' got: ' + elementCount + ' instead.');
				return false;
			}

			// Ordering issue.
			val index = context.indexOf(statement);
			// No need to check the zero index and if it does not contained in the context.
			// The latter one must not happen anyway. 
			if (index < 0) {
				throw new IllegalStateException('''The context does not conatin the given statement: «context», «statement».''');
			}

			var i = index - 1; // -1 since we do not have to compare the statement argument with itself.
			while (i >= 0) {
				val precedingStatement = context.get(i);
				val precedingConstraint = constraintMapping.get(precedingStatement.eClass);
				// Do not check statements for the same constraint.
				if (constraint != precedingConstraint) {
					val ordinal = orderedConstraint.get(constraint);
					val precedingOrdinal = orderedConstraint.get(precedingConstraint);
					if (precedingOrdinal.isGreater(ordinal)) {
						println('''Ordering issue. «»''');
						return false;
					}
				}
				i--;
			}

			return true;
		}

		private def isGreater(String left, String right) {
			val ordinals = [Splitter.on(".").trimResults.splitToList(it).map[parseInt]];
			val leftList = ordinals.apply(left);
			val rightList = ordinals.apply(right);
			Preconditions.checkArgument(!leftList.nullOrEmpty, '''Cannot parse ordinals: «left».''');
			Preconditions.checkArgument(!rightList.nullOrEmpty, '''Cannot parse ordinals: «right».''');
			for (var i = 0; i < leftList.size; i++) {
				if (rightList.size > i) {
					if (leftList.get(i) > rightList.get(i)) {
						return true;
					}
				} else {
					return false;
				}
			}
			return rightList.size > leftList.size;
		}

		def boolean isValid(List<? extends Statement> context) {
			return false;
		}

	}

	@Data
	public static class SubstatementConstraint implements SubstatementRule {

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

		def boolean contains(int i) {
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
