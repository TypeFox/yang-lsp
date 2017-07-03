package io.typefox.yang.validation

import com.google.common.collect.ImmutableMap
import com.google.inject.Singleton
import java.util.Map
import org.eclipse.emf.ecore.EClass

import static io.typefox.yang.yang.YangPackage.Literals.*
import static io.typefox.yang.utils.YangExtensions.YANG_1_1

/**
 * Provides YANG sub-statement rules for a given statement given as an EClass.
 * 
 * @author akos.kitta
 */
@Singleton
class SubstatementRuleProvider {

	static def newRule() {
		return new SubstatementGroup(false);
	}

	static def newOrderedRule() {
		return new SubstatementGroup(true);
	}

	static val MODULE_HEADER_RULE = newRule()
		.optional(YANG_VERSION)
		.must(NAMESPACE)
		.must(PREFIX);

	static val SUBMODULE_HEADER_RULE = newOrderedRule()
		.must(YANG_VERSION)
		.must(BELONGS_TO);

	static val LINKAGE_RULE = newOrderedRule()
		.any(IMPORT)
		.any(INCLUDE);

	static val META_RULE = newOrderedRule()
		.optional(ORGANIZATION)
		.optional(CONTACT)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val DATA_RULE = newRule()
		.any(CONTAINER)
		.any(LEAF)
		.any(LEAF_LIST)
		.any(LIST)
		.any(CHOICE)
		.any(YANG_1_1, ANYDATA)
		.any(ANYXML)
		.any(USES);

	static val BODY_RULE = newRule()
		.any(EXTENSION)
		.any(FEATURE)
		.any(IDENTITY)
		.any(TYPEDEF)
		.any(GROUPING)
		.any(RPC)
		.any(NOTIFICATION)
		.any(DEVIATION)
		.any(AUGMENT)
		.with(DATA_RULE);

	static val REVISION_RULE = newRule()
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val MODULE_RULE = newOrderedRule()
		.with(MODULE_HEADER_RULE)
		.with(LINKAGE_RULE)
		.with(META_RULE)
		.any(REVISION)
		.with(BODY_RULE);

	static val SUBMODULE_RULE = newOrderedRule()
		.with(SUBMODULE_HEADER_RULE)
		.with(LINKAGE_RULE)
		.with(META_RULE)
		.any(REVISION)
		.with(BODY_RULE);

	static val IMPORT_RULE = newRule()
		.must(PREFIX)
		.optional(REVISION_DATE)
		.optional(YANG_1_1, DESCRIPTION)
		.optional(YANG_1_1, REFERENCE);

	static val INCLUDE_RULE = newRule()
		.optional(REVISION_DATE)
		.optional(YANG_1_1, DESCRIPTION)
		.optional(YANG_1_1, REFERENCE);

	static val BELONGS_TO_RULE = newRule()
		.must(PREFIX);

	static val EXTENSION_RULE = newRule()
		.optional(ARGUMENT)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val ARGUMENT_RULE = newRule()
		.optional(YIN_ELEMENT);

	static val FEATURE_RULE = newRule()
		.any(IF_FEATURE)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val IDENTITY_RULE = newRule()
		.any(YANG_1_1, IF_FEATURE)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val TYPEDEF_RULE = newRule()
		.must(TYPE)
		.optional(UNITS)
		.optional(DEFAULT)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val TYPE_RULE = newRule()
		.optional(FRACTION_DIGITS)
		.optional(RANGE)
		.optional(LENGTH)
		.any(PATTERN)
		.any(ENUM)
		.any(BIT)
		.optional(PATH)
		.optional(REQUIRE_INSTANCE)
		.optional(BASE)
		.any(TYPE); 

	static val RANGE_RULE = newRule()
		.optional(ERROR_MESSAGE)
		.optional(ERROR_APP_TAG)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val LENGTH_RULE = newRule()
		.optional(ERROR_MESSAGE)
		.optional(ERROR_APP_TAG)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val PATTERN_RULE = newRule()
		.optional(YANG_1_1, MODIFIER)
		.optional(ERROR_MESSAGE)
		.optional(ERROR_APP_TAG)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val ENUM_RULE = newRule()
		.optional(VALUE)
		.any(YANG_1_1, IF_FEATURE)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val BIT_RULE = newRule()
		.optional(POSITION)
		.any(YANG_1_1, IF_FEATURE)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val MUST_RULE = newRule()
		.optional(ERROR_MESSAGE)
		.optional(ERROR_APP_TAG)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val GROUPING_RULE = newRule()
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE)
		.any(TYPEDEF)
		.any(GROUPING)
		.with(DATA_RULE)
		.optional(YANG_1_1, ACTION)
		.optional(YANG_1_1, NOTIFICATION);

	static val CONTAINER_RULE = newRule()
		.optional(WHEN)
		.any(IF_FEATURE)
		.any(MUST)
		.optional(PRESENCE)
		.optional(CONFIG)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE)
		.any(TYPEDEF)
		.any(GROUPING)
		.with(DATA_RULE)
		.any(YANG_1_1, ACTION)
		.any(YANG_1_1, NOTIFICATION);

	static val LEAF_RULE = newRule()
		.optional(WHEN)
		.any(IF_FEATURE)
		.must(TYPE)
		.optional(UNITS)
		.any(MUST)
		.optional(DEFAULT)
		.optional(CONFIG)
		.optional(MANDATORY)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val LEAF_LIST_RULE = newRule()
		.optional(WHEN)
		.any(IF_FEATURE)
		.must(TYPE)
		.optional(UNITS)
		.any(MUST)
		.optional(DEFAULT)
		.optional(CONFIG)
		.optional(MIN_ELEMENTS)
		.optional(MAX_ELEMENTS)
		.optional(ORDERED_BY)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val LIST_RULE = newRule()
		.optional(WHEN)
		.any(MUST)
		.optional(KEY)
		.any(UNIQUE)
		.optional(CONFIG)
		.optional(MIN_ELEMENTS)
		.optional(MAX_ELEMENTS)
		.optional(ORDERED_BY)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE)
		.any(TYPEDEF)
		.any(GROUPING)
		.with(DATA_RULE)
		.any(YANG_1_1, ACTION)
		.any(YANG_1_1, NOTIFICATION);

	static val CHOICE_RULE = newRule()
		.optional(WHEN)
		.any(IF_FEATURE)
		.optional(DEFAULT)
		.any(MUST)
		.optional(CONFIG)
		.optional(MANDATORY)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE)
		.any(CASE)
		.any(YANG_1_1, CHOICE)
		.any(CONTAINER)
		.any(LEAF)
		.any(LEAF_LIST)
		.any(LIST)
		.any(YANG_1_1, ANYDATA)
		.any(ANYXML);

	static val CASE_RULE = newRule()
		.optional(WHEN)
		.any(IF_FEATURE)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE)
		.with(DATA_RULE);

	static val ANYDATA_RULE = newRule()
		.optional(WHEN)
		.any(IF_FEATURE)
		.any(MUST)
		.optional(CONFIG)
		.optional(MANDATORY)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val ANYXML_RULE = newRule()
		.optional(WHEN)
		.any(IF_FEATURE)
		.any(MUST)
		.optional(CONFIG)
		.optional(MANDATORY)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val USES_RULE = newRule()
		.optional(WHEN)
		.any(IF_FEATURE)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE)
 		.any(REFINE)
		.any(AUGMENT);

	static val REFINE_RULE = newRule()
		.any(MUST)
		.any(YANG_1_1, IF_FEATURE)
		.optional(PRESENCE)
		.optional(DEFAULT)
		.optional(CONFIG)
		.optional(MANDATORY)
		.optional(MIN_ELEMENTS)
		.optional(MAX_ELEMENTS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val AUGMENT_RULE = newRule()
		.optional(WHEN)
		.any(IF_FEATURE)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE)
		.any(CASE)
		.with(DATA_RULE)
		.any(YANG_1_1, ACTION)
		.any(YANG_1_1, NOTIFICATION);
	
	static val WHEN_RULE = newRule()
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	static val RPC_RULE = newRule()
		.any(IF_FEATURE)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE)
		.any(TYPEDEF)
		.any(GROUPING)
		.optional(INPUT)
		.optional(OUTPUT);

	static val ACTION_RULE = newRule()
		.any(IF_FEATURE)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE)
		.any(TYPEDEF)
		.any(GROUPING)
		.optional(INPUT)
		.optional(OUTPUT);

	static val INPUT_RULE = newRule()
		.any(YANG_1_1, MUST)
		.any(TYPEDEF)
		.any(GROUPING)
		.with(DATA_RULE);

	static val OUTPUT_RULE = newRule()
		.any(YANG_1_1, MUST)
		.any(TYPEDEF)
		.any(GROUPING)
		.with(DATA_RULE);

	static val NOTIFICATION_RULE = newRule()
		.any(IF_FEATURE)
		.any(YANG_1_1, MUST)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE)
		.any(TYPEDEF)
		.any(GROUPING)
		.with(DATA_RULE);

	static val DEVIATION_RULE = newRule()
		.optional(DESCRIPTION)
		.optional(REFERENCE)
		.atLeastOne(DEVIATE);

	static val DEVIATE_RULE = newRule()
		.optional(TYPE)
		.optional(UNITS)
		.any(MUST)
		.any(UNIQUE)
		.optional(DEFAULT)
		.optional(CONFIG)
		.optional(MANDATORY)
		.optional(MIN_ELEMENTS)
		.optional(MAX_ELEMENTS);
	
	val Map<EClass, SubstatementGroup> rules;

	new() {
		rules = ImmutableMap.builder
		.put(REVISION, REVISION_RULE)
		.put(MODULE, MODULE_RULE)
		.put(SUBMODULE, SUBMODULE_RULE)
		.put(IMPORT, IMPORT_RULE)
		.put(INCLUDE, INCLUDE_RULE)
		.put(BELONGS_TO, BELONGS_TO_RULE)
		.put(EXTENSION, EXTENSION_RULE)
		.put(ARGUMENT, ARGUMENT_RULE)
		.put(FEATURE, FEATURE_RULE)
		.put(IDENTITY, IDENTITY_RULE)
		.put(TYPEDEF, TYPEDEF_RULE)
		.put(TYPE, TYPE_RULE)
		.put(RANGE, RANGE_RULE)
		.put(LENGTH, LENGTH_RULE)
		.put(PATTERN, PATTERN_RULE)
		.put(ENUM, ENUM_RULE)
		.put(BIT, BIT_RULE)
		.put(MUST, MUST_RULE)
		.put(GROUPING, GROUPING_RULE)
		.put(CONTAINER, CONTAINER_RULE)
		.put(LEAF, LEAF_RULE)
		.put(LEAF_LIST, LEAF_LIST_RULE)
		.put(LIST, LIST_RULE)
		.put(CHOICE, CHOICE_RULE)
		.put(CASE, CASE_RULE)
		.put(ANYDATA, ANYDATA_RULE)
		.put(ANYXML, ANYXML_RULE)
		.put(USES, USES_RULE)
		.put(REFINE, REFINE_RULE)
		.put(AUGMENT, AUGMENT_RULE)
		.put(WHEN, WHEN_RULE)
		.put(RPC, RPC_RULE)
		.put(ACTION, ACTION_RULE)
		.put(INPUT, INPUT_RULE)
		.put(OUTPUT, OUTPUT_RULE)
		.put(NOTIFICATION, NOTIFICATION_RULE)
		.put(DEVIATION, DEVIATION_RULE)
		.put(DEVIATE, DEVIATE_RULE)
		.build;
	}

	def SubstatementGroup get(EClass clazz) {
		return rules.get(clazz);
	}

}