package io.typefox.yang

import com.google.common.collect.ImmutableMap
import com.google.common.collect.Range
import com.google.inject.Singleton
import java.util.Map
import org.eclipse.emf.ecore.EClass

import static com.google.common.collect.Range.*
import static io.typefox.yang.yang.YangPackage.Literals.*
import static java.lang.Integer.MAX_VALUE

/**
 * Stateless helper for the sub-statement cardinalities in YANG.
 * 
 * @author akos.kitta 
 */
@Singleton
class YangCardinalitiesHelper {

	static val Map<EClass, Range<Integer>> EMPTY = emptyMap;

	static val REQUIRED = closed(1, 1);
	static val OPTIONAL = closed(0, 1);
	static val ANY = closed(0, MAX_VALUE);

	private static def <K, V> Map<K, V> mapOf(Pair<K, V>... entries) {
		val builder = ImmutableMap.builder;
		entries.forEach[builder.put(key, value)];
		return builder.build;
	}

	/**
	 * The cardinalities of the <a href="https://tools.ietf.org/html/rfc7950#section-7.1.1">module</a>'s sub-statements.
	 */
	static val MODULE_SUB_STATEMENT_CARDINALITIES = mapOf(ANYDATA -> ANY, ANYXML -> ANY, AUGMENT -> ANY, CHOICE -> ANY,
		CONTACT -> OPTIONAL, DESCRIPTION -> OPTIONAL, DEVIATION -> ANY, EXTENSION -> ANY, FEATURE -> ANY,
		GROUPING -> ANY, IDENTITY -> ANY, IMPORT -> ANY, INCLUDE -> ANY, LEAF -> ANY, LEAF_LIST -> ANY, LIST -> ANY,
		NAMESPACE -> REQUIRED, NOTIFICATION -> ANY, ORGANIZATION -> OPTIONAL, PREFIX -> REQUIRED, REFERENCE -> OPTIONAL,
		REVISION -> ANY, RPC -> ANY, TYPEDEF -> ANY, USES -> ANY, YANG_VERSION -> REQUIRED);

	/**
	 * The cardinalities of the <a href="https://tools.ietf.org/html/rfc7950#section-7.1.5">import</a>'s sub-statements.
	 */
	static val IMPORT_SUB_STATEMENT_CARDINALITIES = mapOf(DESCRIPTION -> OPTIONAL, PREFIX -> REQUIRED,
		REFERENCE -> OPTIONAL, REVISION_DATE -> OPTIONAL);

	/**
	 * All cardinality constraints for all statements.
	 */
	static val ALL_CARDINALITIES = mapOf(MODULE -> MODULE_SUB_STATEMENT_CARDINALITIES,
		IMPORT -> IMPORT_SUB_STATEMENT_CARDINALITIES);

	/**
	 * Returns with the cardinalities for the given EClass.
	 */
	def Map<EClass, Range<Integer>> getCardinalitiesFor(EClass clazz) {
		return ALL_CARDINALITIES.getOrDefault(clazz, EMPTY);
	}

}
