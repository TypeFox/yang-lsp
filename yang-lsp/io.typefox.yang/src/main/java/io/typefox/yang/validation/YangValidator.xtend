/*
 * generated by Xtext 2.13.0-SNAPSHOT
 */
package io.typefox.yang.validation

import com.google.common.collect.ImmutableSet
import com.google.inject.Inject
import com.google.inject.Singleton
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.utils.YangTypeExtensions
import io.typefox.yang.yang.BinaryOperation
import io.typefox.yang.yang.FractionDigits
import io.typefox.yang.yang.Refinable
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.YangVersion
import org.eclipse.xtext.validation.Check

import static io.typefox.yang.utils.YangExtensions.*
import static io.typefox.yang.validation.IssueCodes.*
import static io.typefox.yang.yang.YangPackage.Literals.*

import static extension org.eclipse.xtext.EcoreUtil2.getAllContentsOfType

/**
 * This class contains custom validation rules for the YANG language. 
 */
@Singleton
class YangValidator extends AbstractYangValidator {

	static val RANGE_BINARY_OPERATORS = ImmutableSet.of('|', '..');

	@Inject
	extension YangExtensions;

	@Inject
	extension YangTypeExtensions;

	@Inject
	SubstatementRuleProvider substatementRuleProvider;

	@Inject
	SubstatementFeatureMapper featureMapper;

	@Check
	def void checkVersion(YangVersion it) {
		if (yangVersion != YANG_1 && yangVersion != YANG_1_1) {
			val message = '''The version must be either '«YANG_1»' or '«YANG_1_1»'.''';
			error(message, it, YANG_VERSION__YANG_VERSION, INCORRECT_VERSION);
		}
	}

	@Check
	def void checkSubstatements(Statement it) {
		substatementRuleProvider.get(eClass)?.checkSubstatements(it, this, featureMapper);
	}

	@Check
	def void checkTypeRestriction(Type it) {
		// https://tools.ietf.org/html/rfc7950#section-9.2.3
		// https://tools.ietf.org/html/rfc7950#section-9.3.3
		// Same for string it just has another statement name.
		// https://tools.ietf.org/html/rfc7950#section-9.4.3
		if (!subTypeOfNumber && !subTypeOfString) {
			getAllContentsOfType(Refinable).forEach [
				val message = '''Only integer and decimal types can be restricted with the 'range' statement.''';
				error(message, it, REFINABLE__EXPRESSION, SYNTAX_ERROR);
			];
		}
	}

	@Check
	def checkRefinement(Refinable it) {
		if (checkSyntax) {
			val yangRefinable = yangRefinable;
			if (yangRefinable !== null) {
				yangRefinable.validate(this);
			}
		}
	}

	@Check
	def checkFractionDigitsExist(Type it) {
		// https://tools.ietf.org/html/rfc7950#section-9.3.4
		val fractionDigits = firstSubstatementsOfType(FractionDigits);
		val fractionDigitsExist = fractionDigits !== null;
		// Note, only the decimal type definition MUST have the `fraction-digits` statement.
		// It is not mandatory for types that are derived from decimal built-ins. 
		val decimalBuiltin = decimalBuiltin;
		if (decimalBuiltin) {
			if (fractionDigitsExist) {
				// Validate the fraction digits. It takes as an argument an integer between 1 and 18, inclusively.
				val value = fractionDigitsAsInt;
				if (value.intValue < 1 || value.intValue > 18) {
					val message = '''The "fraction-digits" value must be an integer between 1 and 18, inclusively.''';
					error(message, fractionDigits, FRACTION_DIGITS__RANGE, TYPE_ERROR);
				}

			} else {
				// Decimal types must have fraction-digits sub-statement.
				val message = '''The "fraction-digits" statement must be present for "decimal64" types.''';
				error(message, it, TYPE__TYPE_REF, TYPE_ERROR);
			}
		} else {
			if (fractionDigitsExist) {
				val message = '''Only decimal64 types can have a "fraction-digits" statement."''';
				error(message, it, TYPE__TYPE_REF, TYPE_ERROR);
			}
		}
	}
	

	private def boolean checkSyntax(Refinable it) {
		val invalidOperations = getAllContentsOfType(BinaryOperation).
			filter[!RANGE_BINARY_OPERATORS.contains(operator)];
		invalidOperations.forEach [
			val message = '''Syntax error. Unexpected operator "«operator»".''';
			error(message, it, BINARY_OPERATION__OPERATOR, SYNTAX_ERROR);
		];
		return invalidOperations.nullOrEmpty;
	}

}