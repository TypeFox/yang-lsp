package io.typefox.yang.validation

import com.google.inject.Singleton
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.xbase.lib.Functions.Function1

import static io.typefox.yang.yang.YangPackage.Literals.*

/**
 * Maps the EClass of a YANG statement to the corresponding structural feature which
 * will be used to reveal validation issues.
 * 
 * @author akos.kitta
 */
@Singleton
class SubstatementFeatureMapper implements Function1<EClass, EStructuralFeature> {
	
	val Map<EClass, EStructuralFeature> mapping;
	
	new() {
		mapping = #{
			MODULE -> ABSTRACT_MODULE__NAME,
			YANG_VERSION -> YANG_VERSION__YANG_VERSION,
			NAMESPACE -> NAMESPACE__URI,
			PREFIX -> PREFIX__PREFIX,
			IMPORT -> ABSTRACT_IMPORT__MODULE,
			REVISION_DATE -> REVISION_DATE__DATE,
			INCLUDE -> ABSTRACT_MODULE__NAME,
			ORGANIZATION -> ORGANIZATION__ORGANIZATION,
			CONTACT -> CONTACT__CONTACT,
			REVISION -> REVISION__REVISION,
			SUBMODULE -> ABSTRACT_MODULE__NAME,
			BELONGS_TO -> ABSTRACT_MODULE__NAME,
			TYPEDEF -> SCHEMA_NODE__NAME,
			UNITS -> UNITS__DEFINITION,
			DEFAULT -> DEFAULT__DEFAULT_STRING_VALUE,
			TYPE -> TYPE__TYPE_REF,
			CONTAINER -> SCHEMA_NODE__NAME,
			MUST -> MUST__CONSTRAINT,
			ERROR_MESSAGE -> ERROR_MESSAGE__MESSAGE,
			ERROR_APP_TAG -> ERROR_APP_TAG__TAG,
			PRESENCE -> PRESENCE__DESCRIPTION,
			LEAF -> SCHEMA_NODE__NAME,
			MANDATORY -> MANDATORY__IS_MANDATORY,
			LEAF_LIST -> SCHEMA_NODE__NAME,
			MIN_ELEMENTS -> MIN_ELEMENTS__MIN_ELEMENTS,
			MAX_ELEMENTS -> MAX_ELEMENTS__MAX_ELEMENTS,
			ORDERED_BY -> ORDERED_BY__ORDERED_BY,
			LIST -> SCHEMA_NODE__NAME,
<<<<<<< Upstream, based on branch 'GH-12' of https://github.com/yang-tools/yang-lsp.git
=======
			KEY -> KEY__REFERENCES,
>>>>>>> 2b286b5 some minor fixes for substatement validation
			UNIQUE -> DESCENDANT_SCHEMA_NODE_IDENTIFIER_REFERENCES__REFERENCES,
			CHOICE -> SCHEMA_NODE__NAME,
			CASE -> SCHEMA_NODE__NAME,
<<<<<<< Upstream, based on branch 'GH-12' of https://github.com/yang-tools/yang-lsp.git
=======
			ANYDATA -> ANYDATA__NAME,
>>>>>>> 1df3039 Fixed invalid test case. Fixed feature mapping for any-data.
			ANYXML -> SCHEMA_NODE__NAME,
			GROUPING -> SCHEMA_NODE__NAME,
			USES -> USES__GROUPING,
			REFINE -> REFINE__NODE,
			RPC -> SCHEMA_NODE__NAME,
			ACTION -> ACTION__NAME,
			NOTIFICATION -> SCHEMA_NODE__NAME,
			AUGMENT -> AUGMENT__PATH,
			IDENTITY -> SCHEMA_NODE__NAME,
			BASE -> BASE__REFERENCE,
			EXTENSION -> SCHEMA_NODE__NAME,
			ARGUMENT -> ARGUMENT__NAME,
			YIN_ELEMENT -> YIN_ELEMENT__IS_YIN_ELEMENT,
			FEATURE -> SCHEMA_NODE__NAME,
			IF_FEATURE -> IF_FEATURE__CONDITION,
			DEVIATION -> DEVIATION__REFERENCE,
			DEVIATE -> DEVIATE__ARGUMENT,
			CONFIG -> CONFIG__IS_CONFIG,
			STATUS -> STATUS__ARGUMENT,
			DESCRIPTION -> DESCRIPTION__DESCRIPTION,
			REFERENCE -> REFERENCE__REFERENCE,
			WHEN -> WHEN__CONDITION,
			RANGE -> RANGE__RANGE,
			FRACTION_DIGITS -> FRACTION_DIGITS__RANGE,
			LENGTH -> LENGTH__LENGTH,
			PATTERN -> PATTERN__REGEXP,
			ENUM -> ENUM__NAME,
			VALUE -> VALUE__VALUE,
			BIT -> BIT__NAME,
			POSITION -> POSITION__POSITION,
			PATH -> PATH__REFERENCE,
			REQUIRE_INSTANCE -> REQUIRE_INSTANCE__IS_REQUIRE_INSTANCE,
			UNKNOWN -> UNKNOWN__EXTENSION
		};
	}
	
	override apply(EClass clazz) {
		return mapping.get(clazz);
	}
	
}