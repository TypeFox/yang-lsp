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

	/**
	 * The <a href="https://tools.ietf.org/html/rfc7950#section-7.1.1">cardinalities</a> of the module's sub-statements.
	 */
	static val MODULE_CARDINALITIES = ImmutableMap.builder.put(ANYDATA, ANY).put(ANYXML, ANY).put(AUGMENT, ANY).put(
		CHOICE, ANY).put(CONTACT, OPTIONAL).put(DESCRIPTION, OPTIONAL).put(DEVIATION, ANY).put(EXTENSION, ANY).put(
		FEATURE, ANY).put(GROUPING, ANY).put(IDENTITY, ANY).put(IMPORT, ANY).put(INCLUDE, ANY).put(LEAF, ANY).put(
		LEAF_LIST, ANY).put(LIST, ANY).put(NAMESPACE, REQUIRED).put(NOTIFICATION, ANY).put(ORGANIZATION, OPTIONAL).put(
		PREFIX, REQUIRED).put(REFERENCE, OPTIONAL).put(REVISION, ANY).put(RPC, ANY).put(TYPEDEF, ANY).put(USES, ANY).
		put(YANG_VERSION, REQUIRED).build

	/**
	 * All cardinality constraints for all statements.
	 */
	static val Map<EClass, Map<EClass, Range<Integer>>> ALL_CARDINALITIES = ImmutableMap.builder.put(MODULE,
		MODULE_CARDINALITIES).build;

	/**
	 * Returns with the cardinalities for the given EClass.
	 */
	def Map<EClass, Range<Integer>> getCardinalitiesFor(EClass clazz) {
		return ALL_CARDINALITIES.getOrDefault(clazz, EMPTY);
	}

}
