package io.typefox.yang.utils

import com.google.common.base.Supplier
import com.google.common.base.Suppliers
import com.google.common.collect.ImmutableSet
import com.google.inject.Inject
import com.google.inject.Singleton
import io.typefox.yang.services.YangGrammarAccess
import io.typefox.yang.yang.FractionDigits
import io.typefox.yang.yang.Length
import io.typefox.yang.yang.Range
import io.typefox.yang.yang.Refinable
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import java.math.BigDecimal
import java.util.Collection
import java.util.Map
import java.util.Stack
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.Keyword

import static extension com.google.common.collect.ImmutableMap.copyOf

/**
 * Extensions for YANG <a href="https://tools.ietf.org/html/rfc7950#section-9.2">built-in types</a>.
 * 
 * @author akos.kitta
 */
@Singleton
class YangTypesExtensions {

	@Inject
	extension YangExtensions;

	@Inject
	YangGrammarAccess grammarAccess;

	val Supplier<Collection<String>> builtinNames = Suppliers.memoize [
		return ImmutableSet.copyOf(grammarAccess.BUILTIN_TYPEAccess.alternatives.elements.filter(Keyword).map[value]);
	];

	val Supplier<Map<String, YangRefinable>> integerBuiltins = Suppliers.memoize [
		val it = grammarAccess.BUILTIN_TYPEAccess;
		return newHashMap(#[
			int8Keyword_8 -> BuiltinRanges.INT_8,
			int16Keyword_9 -> BuiltinRanges.INT_16,
			int32Keyword_10 -> BuiltinRanges.INT_32,
			int64Keyword_11 -> BuiltinRanges.INT_64,
			uint8Keyword_14 -> BuiltinRanges.UINT_8,
			uint16Keyword_15 -> BuiltinRanges.UINT_16,
			uint32Keyword_16 -> BuiltinRanges.UINT_32,
			uint64Keyword_17 -> BuiltinRanges.UINT_64
		].map[key.value -> value]).copyOf;
	];

	val Supplier<String> decimalBuiltin = Suppliers.memoize [
		return grammarAccess.BUILTIN_TYPEAccess.decimal64Keyword_3.value;
	];

	val Supplier<String> stringBuiltin = Suppliers.memoize [
		return grammarAccess.BUILTIN_TYPEAccess.stringKeyword_13.value;
	];

	val Supplier<String> binaryBuiltin = Suppliers.memoize [
		return grammarAccess.BUILTIN_TYPEAccess.binaryKeyword_0.value;
	];

	val Supplier<String> enumerationBuiltin = Suppliers.memoize [
		return grammarAccess.BUILTIN_TYPEAccess.enumerationKeyword_5.value;
	];

	val Supplier<String> unionBuiltin = Suppliers.memoize [
		return grammarAccess.BUILTIN_TYPEAccess.unionKeyword_18.value;
	];

	val Supplier<String> bitsBuiltin = Suppliers.memoize [
		return grammarAccess.BUILTIN_TYPEAccess.bitsKeyword_1.value;
	];

	val Supplier<String> identityrefBuiltin = Suppliers.memoize [
		return grammarAccess.BUILTIN_TYPEAccess.identityrefKeyword_6.value;
	];
	
	/**
	 * Returns {@code true} if the argument equals with any of the built-in YANG type names, otherwise {@code false}.
	 */
	def boolean isBuiltinName(String it) {
		return builtinNames.get.contains(it);
	}

	/**
	 * Returns {@code true} if the type of the type definition argument is a YANG built-in type.
	 */
	def boolean isBuiltin(Typedef it) {
		return substatementsOfType(Type).head.builtin;
	}

	/**
	 * Returns {@code true} if the type argument is a YANG built-in type.
	 */
	def boolean isBuiltin(Type it) {
		return builtinNames.get.contains(typeRef?.builtin);
	}

	/**
	 * Returns {@code true} if the type argument is a direct subtype of the built-in integer.
	 */
	def boolean isInteger(Type it) {
		return integerBuiltins.get.keySet.contains(typeRef?.builtin);
	}

	/**
	 * Returns {@code true} if the type argument is a direct subtype of the built-in 64-bit decimal.
	 */
	def boolean isDecimal(Type it) {
		return decimalBuiltin.get == typeRef?.builtin;
	}

	/**
	 * Returns {@code true} if the type argument is a direct subtype of the built-in string YANG type.
	 */
	def boolean isString(Type it) {
		return stringBuiltin.get == typeRef?.builtin;
	}

	/**
	 * {@code true} if the argument is a direct subtype of the binary built-in YANG type.
	 */
	def boolean isBinary(Type it) {
		return binaryBuiltin.get == typeRef?.builtin;
	}

	/**
	 * Returns {@code true} if the type argument is a subtype of the built-in YANG enumeration type.
	 */
	def boolean isEnumeration(Type it) {
		return enumerationBuiltin.get == typeRef?.builtin;
	}

	/**
	 * {@code true} if the type is a direct subtype of the built-in union type, otherwise {@code false}.
	 */
	def boolean isUnion(Type it) {
		return unionBuiltin.get == typeRef?.builtin;
	}

	/**
	 * Returns {@code true} if the argument is a directly derived from the bits YANG type, otherwise {@code false}.
	 */
	def boolean isBits(Type it) {
		return bitsBuiltin.get == typeRef?.builtin;
	}

	/**
	 * {@code true} if the type is an identity reference built-in type, otherwise {@code false}.
	 */
	def boolean isIdentityref(Type it) {
		return identityrefBuiltin.get == typeRef?.builtin;
	}

	/**
	 * Sugar for {@code isSubtypeOfInteger(Type) || isSubtypeOfDecimal(Type)}.
	 */
	def boolean isSubtypeOfNumber(Type it) {
		return isSubtypeOf[isInteger || isDecimal];
	}

	/**
	 * Returns {@code true} if the argument is either a direct or a transitive subtype of the built-in string YANG type.
	 */
	def boolean isSubtypeOfString(Type it) {
		return isSubtypeOf[isString];
	}

	/**
	 * {@code true} if the argument is either a direct or derived subtype of the built-in binary type.
	 */
	def boolean isSubtypeOfBinary(Type it) {
		return isSubtypeOf[isBinary];
	}

	/**
	 * Returns {@code true} if the type argument is a subtype of any built-in integer types or derived from it.
	 */
	def boolean isSubtypeOfInteger(Type it) {
		return isSubtypeOf[isInteger];
	}

	/**
	 * Returns {@code true} if the type argument is a subtype of the built-in 64-bit decimal type or derived from it.
	 */
	def boolean isSubtypeOfDecimal(Type it) {
		return isSubtypeOf[isDecimal];
	}

	/**
	 * {@code true} if the argument is either a direct or transitive subtype of the YANG enumeration type, otherwise {@code false};
	 */
	def boolean isSubtypeOfEnumeration(Type it) {
		return isSubtypeOf[isEnumeration];
	}

	/**
	 * {@code true} if the argument is either a direct or transitive subtype of the YANG enumeration type, otherwise {@code false};
	 */
	def boolean isSubtypeOfBits(Type it) {
		return isSubtypeOf[isBits];
	}

	private def boolean isSubtypeOf(Type it, (Type)=>boolean subtypePredicate) {
		val recursionGuard = newHashSet();
		var type = it;
		while (type !== null) {
			if (subtypePredicate.apply(type)) {
				return true;
			}
			// Already visited type.
			if (!recursionGuard.add(type)) {
				return false;
			}
			type = type.superType;
		}
		return false;
	}

	/**
	 * Returns with the {@code type of t}
	 */
	def getType(Typedef it) {
		return substatementsOfType(Type).head;
	}

	/**
	 * Returns with the direct super type of type argument. If the argument is a built-in type, returns with the argument.
	 */
	def getSuperType(Type it) {
		if (builtin) {
			return it;
		}
		return typeRef?.type?.type;
	}

	/**
	 * Returns with the refinement kind for the type argument based on its built-in super type.
	 * <ul>
	 * <li>{@code range} for the decimal and all integer types.</li>
	 * <li>{@code length} for the string type.</li>
	 * <li>{@code null} otherwise.</li>
	 * <ul> 
	 */
	def getRefinementKind(Type it) {
		return switch (it) {
			case subtypeOfNumber: Range
			case subtypeOfString: Length
			case subtypeOfBinary: Length
			default: null
		};
	}

	/**
	 * Returns with the container type of the refinement argument.
	 */
	def Type getType(Refinable it) {
		return EcoreUtil2.getContainerOfType(it, Type);
	}

	/**
	 * Returns with the contained (sub-statement) refinement for the type.
	 */
	def getRefinement(Type it) {
		return firstSubstatementsOfType(Refinable);
	}

	/**
	 * Returns with the refinement which the argument refinement restricts.
	 * If the refinement does not have any restriction, returns with the built-in type refinement.
	 */
	def getSuperYangRefinement(Refinable refinable) {
		return refinable.type.superType;
	}

	/**
	 * {@code true} if the argument type is refinable. More formally, if any of the bellow conditions is {@code true}:
	 * <p>
	 * <ul>
	 * <li>subtype of integer or decimal,</li>
	 * <li>subtype of string or</li>
	 * <li>subtype of binary.</li>
	 * </ul>
	 */
	def isRefinable(Type it) {
		return subtypeOfNumber || subtypeOfString || subtypeOfBinary;
	}

	/**
	 * Transforms the AST refinement into a data model refinement and returns with it.  
	 * Returns with the {@link YangRefinable#NOOP NOOP} refinable if the given refinement 
	 * argument does not contained either in an integer, a decimal or in a string type.
	 */
	def getYangRefinable(Refinable it) {
		val type = type;
		if (!type.refinable) {
			return YangRefinable.NOOP;
		}

		// Calculate the type hierarchy from bottom to top. (Top element must be a built-in type.)
		val types = type.typeHierarchy;

		// Calculate the refinements from top to bottom. (Bottom refinements are built-in refinements.)
		val refinements = new Stack;
		while (!types.isEmpty) {
			val currentType = types.pop;
			val refinement = switch (currentType) {
				case currentType.subtypeOfDecimal: {
					val fractionDigits = currentType.fractionDigitsAsInt;
					val lowerBound = BuiltinRanges.MIN_64_BASE.movePointLeft(fractionDigits).toString;
					val upperBound = BuiltinRanges.MAX_64_BASE.movePointLeft(fractionDigits).toString;
					YangRefinable.createBuiltin(lowerBound, upperBound);
				}
				case currentType.subtypeOfInteger: {
					integerBuiltins.get.get(currentType?.typeRef?.builtin);
				}
				case currentType.subtypeOfString: {
					integerBuiltins.get.get(grammarAccess.BUILTIN_TYPEAccess.uint64Keyword_17.value);
				}
				case currentType.subtypeOfBinary: {
					integerBuiltins.get.get(grammarAccess.BUILTIN_TYPEAccess.uint64Keyword_17.value);
				}
				default: {
					null
				}
			}
			if (refinement !== null) {
				refinements.push(refinement);
			}
			val parentRange = refinements.peek;
			val candidate = currentType.refinement;
			if (candidate !== null) {
				refinements.add(YangRefinable.create(candidate, parentRange));
			}
		}

		return refinements.pop;
	}

	/**
	 * Calculate the type hierarchy from bottom to top and returns with a mutable stack.
	 * The top-most element is a built-in type. Includes the argument if not {@code null}.
	 */
	def getTypeHierarchy(Type it) {
		val hierarchy = new Stack;
		var superType = it;
		while (superType !== null) {
			hierarchy.push(superType);
			if (superType.builtin) {
				superType = null;
			} else {
				superType = superType.superType;
			}
		}
		return hierarchy;
	}

	/**
	 * Returns with the fraction digit of the given type as an integer.
	 * If the type is not a 64-bit decimal, but has a valid "fraction-digits" statement,
	 * this method will parse the value and returns with the integer.
	 * If the "fraction-digits" does not exist as a sub-statement on the type, or
	 * it cannot be parsed, this method returns with {@code 0} (zero) instead. 
	 */
	def getFractionDigitsAsInt(Type it) {
		val value = firstSubstatementsOfType(FractionDigits)?.range;
		return try {
			if(value === null) 0 else Integer.parseInt(value).intValue;
		} catch (NumberFormatException e) {
			0;
		}
	}

	/**
	 * Contains a couple of ranges for the YANG built-in types.
	 */
	static abstract class BuiltinRanges {

		static val MIN_64_LITERAL = "-9223372036854775808";
		static val MAX_64_LITERAL = "9223372036854775807";

		static val MIN_64_BASE = new BigDecimal(MIN_64_LITERAL);
		static val MAX_64_BASE = new BigDecimal(MAX_64_LITERAL);

		static val INT_8 = YangRefinable.createBuiltin("-128", "127");
		static val INT_16 = YangRefinable.createBuiltin("-32768", "32767");
		static val INT_32 = YangRefinable.createBuiltin("-2147483648", "2147483647");
		static val INT_64 = YangRefinable.createBuiltin(MIN_64_LITERAL, MAX_64_LITERAL);
		static val UINT_8 = YangRefinable.createBuiltin("0", "255");
		static val UINT_16 = YangRefinable.createBuiltin("0", "65535");
		static val UINT_32 = YangRefinable.createBuiltin("0", "4294967295");
		static val UINT_64 = YangRefinable.createBuiltin("0", "18446744073709551615");

	}

}
