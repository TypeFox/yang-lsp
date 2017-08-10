package io.typefox.yang.validation

import com.google.common.collect.ImmutableMap
import com.google.inject.Singleton
import java.util.Map
import org.eclipse.xtext.preferences.PreferenceKey
import org.eclipse.xtext.validation.ConfigurableIssueCodesProvider
import org.eclipse.xtext.validation.SeverityConverter

@Singleton
class IssueCodes extends ConfigurableIssueCodesProvider {

	private static val BUILDER = ImmutableMap.<String, PreferenceKey>builder;

	/**
	 * Issue code that are entangled with cardinality problems of container statement's sub-statements.
	 */
	public static val SUBSTATEMENT_CARDINALITY = 'SUBSTATEMENT_CARDINALITY'.error;

	/**
	 * Issue code indicating an invalid sub-statement inside its parent statement container.
	 */
	public static val UNEXPECTED_SUBSTATEMENT = 'UNEXPECTED_SUBSTATEMENT'.error;

	/**
	 * Issue code for cases when a sub-statement incorrectly precedes another sub-statement.
	 */
	public static val SUBSTATEMENT_ORDERING = 'SUBSTATEMENT_ORDERING'.error;

	/**
	 * Issues code that is used when a module has anything but {@code '1.1'} version.
	 */
	public static val INCORRECT_VERSION = 'INCORRECT_VERSION'.error;

	/**
	 * Errors for types. Such as invalid type restriction, range error, fraction-digits issue.
	 */
	public static val TYPE_ERROR = 'TYPE_ERROR'.error;

	public static val UNKNOWN_REVISION = 'UNKNOWN_REVISION'.error;
	public static val DUPLICATE_NAME = 'DUPLICATE_NAME'.error;
	public static val MISSING_PREFIX = 'MISSING_PREFIX'.error;
	public static val MISSING_REVISION = 'MISSING_REVISION'.warn;
	public static val IMPORT_NOT_A_MODULE = 'IMPORT_NOT_A_MODULE'.error;
	public static val INCLUDE_NOT_A_SUB_MODULE = 'INCLUDE_NOT_A_SUB_MODULE'.error;
	public static val INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE = 'INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE'.
		error

	/**
	 * Issue code when the revision date does not conform the "YYYY-MM-DD" format.
	 */
	public static val INVALID_REVISION_FORMAT = 'INVALID_REVISION_FORMAT'.warn;

	/**
	 * Issue code that applies on a revision if that is not in a reverse chronological order.
	 */
	public static val REVISION_ORDER = 'REVISION_ORDER'.warn;

	/**
	 * Issue code when the name of a type does not conform with the existing constraints.
	 * For instance; the name contains any invalid characters, or equals to any YANG built-in type name.
	 */
	public static val BAD_TYPE_NAME = 'BAD_TYPE_NAME'.error;

	/**
	 * Issues code when there is an inconsistency between a module's version and the version of the included modules.
	 */
	public static val BAD_INCLUDE_YANG_VERSION = 'BAD_INCLUDE_YANG_VERSION'.error;

	/**
	 * Issues code when there is an inconsistency between a module's version and the version of the included modules.
	 */
	public static val BAD_IMPORT_YANG_VERSION = 'BAD_IMPORT_YANG_VERSION'.error;

	/**
	 * Issue code indicating that all assigned names in an enumerable must be unique.
	 */
	public static val DUPLICATE_ENUMERABLE_NAME = 'DUPLICATE_ENUMERABLE_NAME'.error;

	/**
	 * Issue code indicating that all assigned values in an enumerable must be unique.
	 */
	public static val DUPLICATE_ENUMERABLE_VALUE = 'DUPLICATE_ENUMERABLE_VALUE'.error;

	/**
	 * Issue code indicating that an enumerable introduces a new name that is not declared among the parent restriction.
	 */
	public static val ENUMERABLE_RESTRICTION_NAME = 'ENUMERABLE_RESTRICTION_NAME'.error;

	/**
	 * Issue code indicating that an enumerable introduces a new value that is not declared among the parent restriction.
	 */
	public static val ENUMERABLE_RESTRICTION_VALUE = 'ENUMERABLE_RESTRICTION_VALUE'.error;

	/**
	 * Issues code for indicating a duplicate leaf node name in a key. 
	 */
	public static val KEY_DUPLICATE_LEAF_NAME = 'KEY_DUPLICATE_LEAF_NAME'.error;

	/**
	 * Issue code when an ordinal value exceeds its limits.
	 */
	public static val ORDINAL_VALUE = 'ORDINAL_VALUE'.error;

	/**
	 * Issue code when a config=true is a child of a config=false (see https://tools.ietf.org/html/rfc7950#section-7.21.1)
	 */
	public static val INVALID_CONFIG = 'INVALID_CONFIG'.error;

	/**
	 * Issue code when an augmented node declares invalid sub-statements. For instance when an augmented leaf node has leaf nodes.
	 */
	public static val INVALID_AUGMENTATION = 'INVALID_AUGMENTATION'.error;
	
	/**
	 * Issue code for cases when the a choice has default value and the mandatory sub-statement is "true".
	 */
	public static val INVALID_DEFAULT = 'INVALID_DEFAULT'.error;
	
	/**
	 * Issue code when any mandatory nodes are declared after the default case in a "choice".
	 */
	public static val MANDATORY_AFTER_DEFAULT_CASE = 'MANDATORY_AFTER_DEFAULT_CASE'.error; 

	/**
	 * Issues code when an action has a "list" ancestor node without a "key" statement.
	 */
	public static val INVALID_ACTION_ANCESTOR = 'INVALID_ACTION_ANCESTOR'.error;

	private static val Map<String, PreferenceKey> CODES = BUILDER.build;

	override getConfigurableIssueCodes() {
		return CODES;
	}

	private static def error(String code) {
		BUILDER.put(code, new PreferenceKey(code, SeverityConverter.SEVERITY_ERROR));
		return code;
	}

	private static def warn(String code) {
		BUILDER.put(code, new PreferenceKey(code, SeverityConverter.SEVERITY_WARNING));
		return code;
	}

}
