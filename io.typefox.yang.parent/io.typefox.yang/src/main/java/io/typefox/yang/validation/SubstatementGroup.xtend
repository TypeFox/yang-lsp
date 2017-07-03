package io.typefox.yang.validation

import com.google.common.base.Splitter
import com.google.common.collect.Range
import io.typefox.yang.yang.Statement
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.validation.ValidationMessageAcceptor

import static io.typefox.yang.validation.IssueCodes.*

import static extension io.typefox.yang.utils.YangNameUtils.*
import static extension java.lang.Integer.parseInt
import io.typefox.yang.yang.YangPackage

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

	def atLeastOne(EClass clazz) {
		return add(clazz, Cardinality.AT_LEAST_ONE);
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

	def void checkSubstatements(Statement substatementContainer, ValidationMessageAcceptor acceptor,
		(EClass)=>EStructuralFeature featureMapper) {

		val substatements = substatementContainer.subStatements;
		val substatementTypes = substatementContainer.subStatements.toMap([eClass]);
		constraintMapping.filter[clazz, constraint|constraint.cardinality === Cardinality.MUST].keySet.filter [
			!substatementTypes.containsKey(it);
		].forEach [
			val message = '''Missing mandatory substatement: '«yangName»'.''';
			val feature = featureMapper.apply(substatementContainer.eClass);
			acceptor.acceptError(message, substatementContainer, feature, SUBSTATEMENT_CARDINALITY);
		];
		substatements.forEach [ statement, index |
			checkStatementInContext(statement, substatementContainer, acceptor, featureMapper);
		];
	}

	private def void checkStatementInContext(Statement statement, Statement substatementContainer,
		ValidationMessageAcceptor acceptor, (EClass)=>EStructuralFeature featureMapper) {

		val substatements = substatementContainer.subStatements;
		val clazz = statement.eClass
		if (clazz === YangPackage.Literals.UNKNOWN) {
			// extensions are fine anywhere
			return;
		}
		val constraint = constraintMapping.get(clazz);
		val feature = featureMapper.apply(clazz);

		// Unexpected statement.
		if (constraint === null) {
			val message = '''Unexpected substatement: '«clazz.yangName»'.''';
			acceptor.acceptError(message, statement, feature, UNEXPECTED_SUBSTATEMENT);
			return;
		}

		// Cardinality issue.
		val cardinality = constraint.cardinality;
		val elementCount = substatements.filter(clazz.instanceClass).size;
		if (!cardinality.contains(elementCount)) {
			val message = '''Expected '«clazz.yangName»' with «cardinality» cardinality. Got «elementCount» instead.''';
			acceptor.acceptError(message, statement, feature, SUBSTATEMENT_CARDINALITY);
			return;
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
					acceptor.acceptError(message, statement, feature, SUBSTATEMENT_ORDERING);
					return;
				}
			}
			i--;
		}

	}

	private def isGreater(String left, String right) {
		val ordinals = [Splitter.on(".").trimResults.splitToList(it).map[parseInt]];
		val leftOrdinals = ordinals.apply(left);
		val rightOrdinals = ordinals.apply(right);
		for (var i = 0; i < leftOrdinals.size; i++) {
			if (rightOrdinals.size > i) {
				val result = Integer.compare(leftOrdinals.get(i), rightOrdinals.get(i));
				if (result < 0) {
					return false;
				} else if (result > 0) {
					return true;
				}
			} else {
				return false;
			}
		}
		return rightOrdinals.size > leftOrdinals.size;
	}

	private def acceptError(ValidationMessageAcceptor it, String message, EObject object, EStructuralFeature feature,
		String code) {
		acceptError(message, object, feature, -1, code);
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
