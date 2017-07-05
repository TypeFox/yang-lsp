package io.typefox.yang.utils

import com.google.common.base.Supplier
import com.google.common.base.Suppliers
import com.google.inject.Inject
import com.google.inject.Singleton
import io.typefox.yang.services.YangGrammarAccess
import io.typefox.yang.types.YangRange
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import java.math.BigInteger
import java.util.Collection
import org.eclipse.xtext.Keyword

import static extension com.google.common.collect.ImmutableSet.copyOf
import io.typefox.yang.yang.Range
import java.math.BigDecimal

/**
 * Extensions for YANG <a href="https://tools.ietf.org/html/rfc7950#section-9.2">built-in types</a>.
 * 
 * @author akos.kitta
 */
@Singleton
class YangBuiltinExtensions {

	@Inject
	extension YangExtensions;

	@Inject
	YangGrammarAccess grammarAccess;

	val Supplier<Collection<String>> builtinNames = Suppliers.memoize [
		return grammarAccess.BUILTIN_TYPEAccess.alternatives.elements.filter(Keyword).map[value].copyOf;
	];

	val Supplier<Collection<String>> integerBuiltinNames = Suppliers.memoize [
		val it = grammarAccess.BUILTIN_TYPEAccess;
		return #[
			int8Keyword_8,
			int16Keyword_9,
			int32Keyword_10,
			int64Keyword_11,
			uint8Keyword_14,
			uint16Keyword_15,
			uint32Keyword_16,
			uint64Keyword_17
		].map[value].copyOf;
	];

	val Supplier<Collection<String>> decimalBuiltinNames = Suppliers.memoize [
		val it = grammarAccess.BUILTIN_TYPEAccess;
		return #[decimal64Keyword_3].map[value].copyOf;
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
		return integerBuiltinNames.get.contains((typeRef.builtin));
	}

	/**
	 * Returns {@code true} if the type argument is a direct subtype of the built-in 64-bit decimal.
	 */
	def boolean isDecimalBuiltin(Type it) {
		return decimalBuiltinNames.get.contains((typeRef.builtin));
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
			type = type.typeRef?.type?.type;
		}
		return false;
	}
	
	def getYangRange(Range range) {
		
	}

	/**
	 * Contains a couple of ranges for the YANG built-in types.
	 */
	abstract static class BuiltinRanges {

		public static val INT_8 = new YangRange(new BigInteger("-128"), new BigInteger("127"));

		public static val INT_16 = new YangRange(new BigInteger("-32768"), new BigInteger("32767"));

		public static val INT_32 = new YangRange(new BigInteger("-2147483648"), new BigInteger("2147483647"));

		public static val INT_64 = new YangRange(new BigInteger("-9223372036854775808"),
			new BigInteger("9223372036854775807"));

		public static val UINT_8 = new YangRange(BigInteger.ZERO, new BigInteger("255"));

		public static val UINT_16 = new YangRange(BigInteger.ZERO, new BigInteger("65535"));

		public static val UINT_32 = new YangRange(BigInteger.ZERO, new BigInteger("4294967295"));

		public static val UINT_64 = new YangRange(BigInteger.ZERO, new BigInteger("18446744073709551615"));

	}

	def static void main(String[] args) {
		println(new BigDecimal("18446744073709551615"))
	}

}
