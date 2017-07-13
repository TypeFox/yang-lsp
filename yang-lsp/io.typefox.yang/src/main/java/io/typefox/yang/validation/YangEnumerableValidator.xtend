package io.typefox.yang.validation

import com.google.common.collect.Range
import com.google.inject.Inject
import com.google.inject.Singleton
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.utils.YangTypesExtensions
import io.typefox.yang.yang.Bit
import io.typefox.yang.yang.Enum
import io.typefox.yang.yang.Enumerable
import io.typefox.yang.yang.Ordered
import io.typefox.yang.yang.Position
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Value
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.validation.ValidationMessageAcceptor

import static io.typefox.yang.validation.IssueCodes.*
import static io.typefox.yang.yang.YangPackage.Literals.*

import static extension io.typefox.yang.utils.IterableExtensions2.toMultimap
import static extension io.typefox.yang.utils.YangNameUtils.getYangName
import static extension org.eclipse.xtext.util.Strings.*

/**
 * Validator for YANG enumeration and bits types.
 * 
 * @author akos.kitta
 */
@Singleton
class YangEnumerableValidator {

	@Inject
	extension YangExtensions;

	@Inject
	extension YangTypesExtensions;

	def validateEnumerable(Type type, ValidationMessageAcceptor acceptor) {
		val context = type.context;
		if (context === null) {
			return;
		}
		val it = context.astNode;
		val minValid = context.ordinalRange.lowerEndpoint.longValue;
		val maxValid = context.ordinalRange.upperEndpoint.longValue;
		val enumerableName = context.enumerableClass.yangName;
		val orderedName = context.enumerableClass.yangName;

		// The "bit" statement, which is a sub-statement to the "type" statement, must be present if the type is "bits".
		// https://tools.ietf.org/html/rfc7950#section-9.7.4
		val enumerables = substatementsOfType(context.enumerableClass);
		if (!context.substatementCardinality.contains(enumerables.size) && builtin) {
			val message = '''«context.name.toFirstUpper» type must have at least one "«enumerableName»" statement.''';
			acceptor.error(message, it, TYPE__TYPE_REF, TYPE_ERROR);
		} else {
			// All assigned names in a bits type must be unique.
			// https://tools.ietf.org/html/rfc7950#section-9.7.4
			enumerables.toMultimap[name].asMap.forEach [ name, statementsWithSameName |
				if (statementsWithSameName.size > 1) {
					statementsWithSameName.forEach [
						val message = '''The «orderedName» name has already been used for the «context.name».''';
						acceptor.error(message, it, ENUMERABLE__NAME, DUPLICATE_ENUMERABLE_NAME);
					];
				}
			];
			// All assigned positions in a bits type must be unique
			// https://tools.ietf.org/html/rfc7950#section-9.7.4.2
			val allOrdinals = enumerables.map[firstSubstatementsOfType(context.orderedClass)];
			allOrdinals.filterNull.toMultimap[ordinal].asMap.forEach [ ordinal, statementsWithSameOrdinal |
				if (statementsWithSameOrdinal.size > 1) {
					statementsWithSameOrdinal.forEach [
						val message = '''The integer value «orderedName»s has already been used for the «context.name».''';
						acceptor.error(message, it, ORDERED__ORDINAL, DUPLICATE_ENUMERABLE_VALUE);
					];
				}
			];

			val maxOrdinal = newArrayList(minValid);
			// Assigned values must be between 0 and 4294967295.
			// https://tools.ietf.org/html/rfc7950#section-9.7.4.2
			enumerables.forEach [
				val ordered = firstSubstatementsOfType(context.orderedClass);
				val ordinal = ordered?.ordinal;
				if (ordinal !== null) {
					try {
						val value = Long.parseLong(ordinal);
						if (value < minValid || value > maxValid) {
							throw new NumberFormatException;
						}
						if (value > maxOrdinal.head.longValue) {
							maxOrdinal.set(0, value);
						}
					} catch (NumberFormatException e) {
						val message = '''The «enumerableName» value is not an integer between «minValid» and «maxValid».''';
						acceptor.error(message, ordered, ORDERED__ORDINAL, ORDINAL_VALUE);
					}
				} else {
					// If the current highest bit position value is equal to 4294967295,
					// then a position value must be specified for "bit" sub-statements
					// following the one with the current highest position value.
					if (maxOrdinal.head.longValue >= maxValid) {
						val message = '''Cannot automatically asign a value to «orderedName». An explicit «orderedName» has to be assigned instead.''';
						acceptor.error(message, it, ENUMERABLE__NAME, ORDINAL_VALUE);
					} else {
						maxOrdinal.set(0, maxOrdinal.head.longValue + 1L);
					}
				}
			];

			// When an existing bits type is restricted, the "position" statement
			// must either have the same value as in the base type or not be
			// present, in which case the value is the same as in the base type.
			// No need to validate the direct subtype of bits as no restrictions are applied on them.
			if (!builtin) {
				val currentType = it;
				val allEnumerablesNames = typeHierarchy.filter[it !== currentType].map [
					substatementsOfType(context.enumerableClass)
				].flatten.toMultimap[name];

				enumerables.forEach [
					val message = '''A new assigned name must not declared when restricting an existing «context.name» type.''';
					val enumerablesWithSameNames = allEnumerablesNames.get(name);
					if (enumerablesWithSameNames.nullOrEmpty) {
						acceptor.error(message, it, ENUMERABLE__NAME, ENUMERABLE_RESTRICTION_NAME);
					} else {
						val ordered = firstSubstatementsOfType(context.orderedClass);
						val ordinal = ordered?.ordinal;
						val parentOrdinals = enumerablesWithSameNames.map [
							firstSubstatementsOfType(context.orderedClass)
						].filterNull.map[it.ordinal];

						if (ordinal !== null && !parentOrdinals.exists[ordinal == it]) {
							acceptor.error(message, it, ENUMERABLE__NAME, ENUMERABLE_RESTRICTION_VALUE);
						}
					}
				];
			}
		}

	}

	private def Context getContext(Type it) {
		return switch (it) {
			case subtypeOfEnumeration: {
				val cardinalityRange = Range.closed(0, Integer.MAX_VALUE);
				val ordinalRange = Range.closed(-2147483648L, 2147483647L);
				new Context(it, 'enumeration', Enum, Value, cardinalityRange, ordinalRange);
			}
			case subtypeOfBits: {
				val cardinalityRange = Range.closed(1, Integer.MAX_VALUE);
				val ordinalRange = Range.closed(0L, 4294967295L);
				new Context(it, 'bits', Bit, Position, cardinalityRange, ordinalRange);
			}
			default:
				null
		}
	}

	private def error(ValidationMessageAcceptor it, String message, EObject object, EStructuralFeature feature,
		String issueCode) {
		acceptError(message, object, feature, -1, issueCode);
	}

	@Data
	private static class Context {
		val Type astNode;
		val String name;
		val Class<? extends Enumerable> enumerableClass;
		val Class<? extends Ordered> orderedClass;
		val Range<Integer> substatementCardinality;
		val Range<Long> ordinalRange;
	}

}
