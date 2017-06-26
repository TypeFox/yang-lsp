package io.typefox.yang.validation

/**
 * Validation issues codes for the YANG language.
 * 
 * @author akos.kitta
 */
class YangIssueCodes {

	/**
	 * Issue code that are entangled with cardinality problems of module's sub-statements.
	 */
	public static val MODULE_SUB_STATEMENT_CARDINALITY = 'module.substatement.cardinality';
	
	/**
	 * Issue code associated with cardinality problems of import's sub-statements.
	 */
	public static val IMPORT_SUB_STATEMENT_CARDINALITY = 'import.substatement.cardinality';
	
	/**
	 * Issue code indicating an invalid sub-statement inside its parent statement container.
	 */
	public static val INVALID_SUB_STATEMENT = 'invalid.substatement';

	/**
	 * Issues code that is used when a module has anything but {@code '1.1'} version.
	 */
	public static val INCORRECT_VERSION = 'incorrect.version';

}
