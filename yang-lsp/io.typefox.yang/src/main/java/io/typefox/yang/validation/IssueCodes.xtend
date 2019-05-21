package io.typefox.yang.validation

import com.google.common.collect.ImmutableMap
import com.google.inject.Singleton
import java.util.Map
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.preferences.PreferenceKey
import org.eclipse.xtext.validation.SeverityConverter
import org.eclipse.xtext.validation.ConfigurableIssueCodesProvider

@Singleton
class IssueCodes extends ConfigurableIssueCodesProvider {
	static val BUILDER = ImmutableMap.<String, PreferenceKey>builder
	
	public static val SUBSTATEMENT_CARDINALITY = 'substatement-cardinality'.error('''
		Issue code that are entangled with cardinality problems of container statement's sub-statements.
	''')

	public static val UNEXPECTED_SUBSTATEMENT = 'unexpected-statement'.error('''
		Issue code indicating an invalid sub-statement inside its parent statement container.
	''')

	public static val SUBSTATEMENT_ORDERING = 'substatement-ordering'.error('''
		Issue code for cases when a sub-statement incorrectly precedes another sub-statement.
	''')

	public static val INCORRECT_VERSION = 'incorrect-version'.error('''
		Issues code that is used when a module has anything but {@code '1.1'} version.
	''')

	public static val TYPE_ERROR = 'type-error'.error('''
		Errors for types. Such as invalid type restriction, range error, fraction-digits issue.
	''')

	public static val DUPLICATE_NAME = 'duplicate-name'.error('''
		A duplicate local name.
	''')
	public static val MISSING_PREFIX = 'missing-prefix'.error('''
	''')
	public static val AMBIGUOUS_IMPORT = 'ambiguous-import'.warn('''
		Diagnostic that indicates a module import is ambiguous.
	''')
	public static val IMPORT_NOT_A_MODULE = 'import-not-a-module'.error('''
		Diagnostic indicating that an `import` statement is not pointing to a module.
	''')
	public static val INCLUDE_NOT_A_SUB_MODULE = 'include-not-a-submodule'.error('''
		Diagnostic indicating that an `include` statement is not pointing to a submodule.
	''')
	public static val INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE = 'included-submodule-belongs-to-different-module'.error('''
		Indicating that an included module belongs to a different module.
	''')

	public static val INVALID_REVISION_FORMAT = 'invalid-revision-format'.warn('''
		Issue code when the revision date does not conform the "YYYY-MM-DD" format.
	''')

	public static val REVISION_ORDER = 'revision-order'.warn('''
		Issue code that applies on a revision if that is not in a reverse chronological order.
	''')

	public static val REVISION_MISMATCH = 'revision-mismatch'.warn('''
		Issue code that applies when the leading revision does not match the revision in the file name.
	''')

	public static val BAD_TYPE_NAME = 'bad-type-name'.error('''
		Issue code when the name of a type does not conform with the existing constraints.
		For instance the name contains any invalid characters, or equals to any YANG built-in type name.
	''')

	public static val BAD_INCLUDE_YANG_VERSION = 'bad-include-yang-version'.error('''
		Issues code when there is an inconsistency between a module's version and the version of the included modules.
	''')

	public static val BAD_IMPORT_YANG_VERSION = 'bad-import-yang-version'.error('''
		Issues code when there is an inconsistency between a module's version and the version of the included modules.
	''')

	public static val DUPLICATE_ENUMERABLE_NAME = 'duplicate-enumerable-name'.error('''
		Issue code indicating that all assigned names in an enumerable must be unique.
	''')

	public static val DUPLICATE_ENUMERABLE_VALUE = 'duplicate-enumerable-value'.error('''
		Issue code indicating that all assigned values in an enumerable must be unique.
	''')

	public static val ENUMERABLE_RESTRICTION_NAME = 'enumerable-restriction-name'.error('''
		Issue code indicating that an enumerable introduces a new name that is not declared among the parent restriction.
	''')

	public static val ENUMERABLE_RESTRICTION_VALUE = 'enumerable-restriction-value'.error('''
		Issue code indicating that an enumerable introduces a new value that is not declared among the parent restriction.
	''')

	public static val KEY_DUPLICATE_LEAF_NAME = 'key-duplicate-leaf-name'.error('''
		Issues code for indicating a duplicate leaf node name in a key.
	''')

	public static val ORDINAL_VALUE = 'ordinal-value'.error('''
		Issue code when an ordinal value exceeds its limits.
	''')

	public static val INVALID_CONFIG = 'invalid-config'.error('''
		Issue code when a `config=true` is a child of a `config=false` (see https://tools.ietf.org/html/rfc7950#section-7.21.1)
	''')

	public static val INVALID_AUGMENTATION = 'invalid-augmentation'.error('''
		Issue code when an augmented node declares invalid sub-statements. For instance when an augmented leaf node has leaf nodes.
	''')

	public static val INVALID_DEFAULT = 'invalid-default'.error('''
		Issue code for cases when the a choice has default value and the mandatory sub-statement is "true".
	''')

	public static val MANDATORY_AFTER_DEFAULT_CASE = 'mandatory-after-default-case'.error('''
		Issue code when any mandatory nodes are declared after the default case in a "choice".
	''')

	public static val INVALID_ANCESTOR = 'invalid-action-ancestor'.error('''
		Issue code when an action (or notification) has a "list" ancestor node without a "key" statement.
		Also applies, when an action (or notification) is declared within another action, rpc or notification.
	''')

	public static val IDENTITY_CYCLE = 'identity-cycle'.error('''
		Issue code when an identity references itself, either directly or indirectly through a chain of other identities.
	''')

	public static val LEAF_KEY_WITH_IF_FEATURE = 'leaf-key-with-if-feature'.error('''
		This issue code is used when a leaf node is declared as a list key and have any "if-feature" statements.
	''')
	
	public static val INVALID_TYPE = 'xpath-invalid-type'.error('''
		Invalid type in Xpath expression
	''')
	
	public static val UNKNOWN_VARIABLE = 'xpath-unknown-variable'.error('''
		Xpath expressions in YANG don't have variables in context
	''')
	
	public static val UNKNOWN_FUNCTION = 'xpath-unknown-function'.warn('''
		An unknown function is called
	''')
	
	public static val FUNCTION_ARITY = 'xpath-function-arity'.error('''
		Wrong argument arity for an Xpath function call.
	''')
	
	public static val XPATH_LINK_ERROR = 'xpath-linking-error'.ignore('''
		Diagnostic for unresolvable Xpath expressions.
	''')
	
	public static val GROUPING_REFERENCE_TO_ITSELF = 'grouping-reference-to-itself'.error('''
		Issues code indicate that a grouping reference to itself.
	''')
	
	static val Map<String, PreferenceKey> CODES = BUILDER.build

	override getConfigurableIssueCodes() {
		return CODES
	}
	
	@Data static class DocumentedPreferenceKey extends PreferenceKey {
		String documentation
	}

	private static def error(String code, CharSequence doc) {
		BUILDER.put(code, new DocumentedPreferenceKey(code, SeverityConverter.SEVERITY_ERROR, doc.toString))
		return code
	}

	private static def warn(String code, CharSequence doc) {
		BUILDER.put(code, new DocumentedPreferenceKey(code, SeverityConverter.SEVERITY_WARNING, doc.toString))
		return code
	}
	
	private static def ignore(String code, CharSequence doc) {
		BUILDER.put(code, new DocumentedPreferenceKey(code, SeverityConverter.SEVERITY_IGNORE, doc.toString))
		return code
	}

	def static void main(String[] args) {
		CODES.values.filter(DocumentedPreferenceKey).forEach[ 
			println('''
				#### `«id»`
				
				«documentation»
				
				 (default severity: «defaultValue»)
			''')
		]
	}
}
