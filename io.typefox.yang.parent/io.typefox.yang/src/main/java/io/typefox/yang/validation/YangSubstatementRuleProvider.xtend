package io.typefox.yang.validation

import com.google.common.collect.ImmutableMap
import com.google.inject.Singleton
import io.typefox.yang.validation.SubstatementRule.SubstatementGroup
import java.util.Map
import org.eclipse.emf.ecore.EClass

import static io.typefox.yang.yang.YangPackage.Literals.*

@Singleton
class YangSubstatementRuleProvider {
	
	static def newRule() {
		return new SubstatementGroup();
	}
	
	static val MODULE_HEADER_RULES = newRule()
		.must(YANG_VERSION)
		.must(NAMESPACE)
		.must(PREFIX);
		
	static val SUBMODULE_HEADER_RULES = newRule()
		.must(YANG_VERSION)
		.must(BELONGS_TO);
		
	static val LINKAGE_RULES = newRule()
		.any(IMPORT)
		.any(INCLUDE);
		
	static val META_RULES = newRule()
		.optional(ORGANIZATION)
		.optional(CONTACT)
		.optional(DESCRIPTION)
		.optional(REFERENCE);
		
	static val REVISION_RULES = newRule()
		.optional(DESCRIPTION)
		.optional(REFERENCE);
		
	static val DATA_RULES = newRule()
		.any(CONTAINER)
		.any(LEAF)
		.any(LEAF_LIST)
		.any(LIST)
		.any(CHOICE)
		.any(ANYDATA)
		.any(ANYXML)
		.any(USES);
	
	static val BODY_RULES = newRule()
		.any(EXTENSION)
		.any(FEATURE)
		.any(IDENTITY)
		.any(TYPEDEF)
		.any(GROUPING)
		.any(RPC)
		.any(NOTIFICATION)
		.any(DEVIATION)
		.any(AUGMENT)
		.with(DATA_RULES);
	
	static val MODULE_RULE = newRule()
		.with(MODULE_HEADER_RULES)
		.with(LINKAGE_RULES)
		.with(META_RULES)
		.with(REVISION_RULES)
		.with(BODY_RULES);
		
	static val SUBMODULE_RULE = newRule()
		.with(SUBMODULE_HEADER_RULES)
		.with(LINKAGE_RULES)
		.with(META_RULES)
		.with(REVISION_RULES)
		.with(BODY_RULES);
		
	static val IMPORT_RULE = newRule()
		.must(PREFIX)
		.optional(REVISION_DATE)
		.optional(DESCRIPTION)
		.optional(REFERENCE);
		
	static val INCLUDE_RULE = newRule()
		.optional(REVISION_DATE)
		.optional(DESCRIPTION)
		.optional(REFERENCE);
		
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
		.any(IF_FEATURE)
		.optional(STATUS)
		.optional(DESCRIPTION)
		.optional(REFERENCE);

	val Map<EClass, SubstatementGroup> rules;

	new() {
		rules = ImmutableMap.builder
		.put(MODULE, MODULE_RULE)
		.put(SUBMODULE, SUBMODULE_RULE)
		.put(REVISION, REVISION_RULES)
		.put(IMPORT, IMPORT_RULE)
		.put(INCLUDE, INCLUDE_RULE)
		.build;
	}
	
	def SubstatementGroup get(EClass clazz) {
		return rules.get(clazz);
	}
	
}