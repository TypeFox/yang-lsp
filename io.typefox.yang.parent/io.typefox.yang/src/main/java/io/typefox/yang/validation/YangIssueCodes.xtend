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
	 * Issues code that is used when a module has anything but {@code '1.1'} version.
	 */
	public static val INCORRECT_VERSION = 'incorrect.version';

}
