package io.typefox.yang.utils

import com.google.common.base.Supplier
import com.google.common.base.Suppliers
import com.google.common.collect.ImmutableMap
import com.google.common.collect.ImmutableSet
import com.google.inject.Inject
import com.google.inject.Singleton
import io.typefox.yang.services.YangGrammarAccess
import io.typefox.yang.types.YangRange
import io.typefox.yang.yang.Range
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
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
class YangTypeExtensions {

	@Inject
	extension YangExtensions;

	@Inject
	YangGrammarAccess grammarAccess;

	val Supplier<Collection<String>> builtinNames = Suppliers.memoize [
		return ImmutableSet.copyOf(grammarAccess.BUILTIN_TYPEAccess.alternatives.elements.filter(Keyword).map[value]);
	];

	val Supplier<Map<String, YangRange>> integerBuiltins = Suppliers.memoize [
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

	val Supplier<Map<String, YangRange>> decimalBuiltins = Suppliers.memoize [
		val it = grammarAccess.BUILTIN_TYPEAccess;
		println("TODO: io.typefox.yang.utils.YangTypeExtensions.decimalBuiltinNames");
		return newHashMap(#[
			decimal64Keyword_3 -> BuiltinRanges.INT_64
		].map[key.value -> value]).copyOf;
	];

	/**
	 * Disjunction (OR) of the integer and decimal built-in types.
	 */
	val Supplier<Map<String, YangRange>> numberBuiltinNames = Suppliers.memoize [
		return ImmutableMap.builder.putAll(integerBuiltins.get).putAll(decimalBuiltins.get).build;
	];

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
	def boolean isIntegerBuiltin(Type it) {
		return integerBuiltins.get.keySet.contains(typeRef.builtin);
	}

	/**
	 * Returns {@code true} if the type argument is a direct subtype of the built-in 64-bit decimal.
	 */
	def boolean isDecimalBuiltin(Type it) {
		return decimalBuiltins.get.keySet.contains(typeRef.builtin);
	}

	/**
	 * Returns {@code true} if the type argument is a subtype of any built-in integer types or derived from it.
	 */
	def boolean isSubtypeOfInteger(Type it) {
		return isSubtypeOf[integerBuiltin];
	}

	/**
	 * Returns {@code true} if the type argument is a subtype of the built-in 64-bit decimal type or derived from it.
	 */
	def boolean isSubtypeOfDecimal(Type it) {
		return isSubtypeOf[decimalBuiltin];
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
	def Type getType(Typedef it) {
		return substatementsOfType(Type).head;
	}

	/**
	 * Returns with the direct super type of type argument. If the argument is a built-in type, returns with the argument.
	 */
	def Type getSuperType(Type it) {
		if (builtin) {
			return it;
		}
		return typeRef?.type?.type;
	}

	/**
	 * Returns with the container type of the range argument.
	 */
	def Type getType(Range it) {
		return EcoreUtil2.getContainerOfType(it, Type);
	}

	/**
	 * Returns with the contained (sub-statement) range for the type.
	 */
	def Range getRange(Type it) {
		return firstSubstatementsOfType(Range);
	}

	/**
	 * Returns with the range which the argument range restricts.
	 * If the range does not have any restriction, returns with the built-in type range.
	 */
	def getSuperYangRange(Range range) {
		return range.type.superType;
	}

	/**
	 * Transforms the AST range into a data model range and returns with it.  
	 */
	def getYangRange(Range it) {
		val type = type;
		if (!type.subtypeOfInteger.xor(type.subtypeOfDecimal)) {
			return null;
		}

		// Calculate the type hierarchy from bottom to top. (Top element must be a built-in type.)
		val types = new Stack;
		types.push(type);
		var superType = type.superType;
		while (superType !== null) {
			types.push(superType);
			if (superType.builtin) {
				superType = null;
			} else {
				superType = superType.superType;
			}
		}

		// Calculate the ranges from top to bottom. (Bottom ranges are built-in ranges.)
		val ranges = new Stack;
		while (!types.isEmpty) {
			val currentType = types.pop;
			val range = numberBuiltinNames.get.get(currentType?.typeRef?.builtin);
			if (range !== null) {
				ranges.push(range);
			}
			val parentRange = ranges.peek;
			ranges.add(YangRange.create(currentType.range, parentRange));
		}

		return ranges.pop;
	}

	/**
	 * Contains a couple of ranges for the YANG built-in types.
	 */
	static abstract class BuiltinRanges {

		static val INT_8 = YangRange.createBuiltin("-128 .. 127");
		static val INT_16 = YangRange.createBuiltin("-32768 .. 32767");
		static val INT_32 = YangRange.createBuiltin("-2147483648 .. 2147483647");
		static val INT_64 = YangRange.createBuiltin("-9223372036854775808 .. 9223372036854775807");
		static val UINT_8 = YangRange.createBuiltin("0 .. 255");
		static val UINT_16 = YangRange.createBuiltin("0 .. 65535");
		static val UINT_32 = YangRange.createBuiltin("0 .. 4294967295");
		static val UINT_64 = YangRange.createBuiltin("0 .. 18446744073709551615");

	}

}
