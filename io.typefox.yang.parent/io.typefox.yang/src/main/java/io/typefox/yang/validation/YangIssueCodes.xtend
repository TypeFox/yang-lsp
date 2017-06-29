package io.typefox.yang.validation

/**
 * Validation issues codes for the YANG language.
 * 
 * @author akos.kitta
 */
class YangIssueCodes {

	/**
	 * Issue code that are entangled with cardinality problems of container statement's sub-statements.
	 */
	public static val SUBSTATEMENT_CARDINALITY = 'substatement.cardinality';
	
	/**
	 * Issue code indicating an invalid sub-statement inside its parent statement container.
	 */
	public static val UNEXPECTED_SUBSTATEMENT = 'unexpected.substatement';
	
	/**
	 * Issue code for cases when a sub-statement incorrectly precedes another sub-statement.
	 */
	public static val SUBSTATEMENT_ORDERING = 'substatement.ordering';

	/**
	 * Issues code that is used when a module has anything but {@code '1.1'} version.
	 */
	public static val INCORRECT_VERSION = 'incorrect.version';

}
