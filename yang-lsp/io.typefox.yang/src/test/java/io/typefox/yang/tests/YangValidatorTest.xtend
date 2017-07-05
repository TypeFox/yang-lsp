package io.typefox.yang.tests

import io.typefox.yang.yang.Contact
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.YangVersion
import org.junit.Test

import static io.typefox.yang.validation.IssueCodes.*

/**
 * Validation test for the YANG language.
 * 
 * @author akos.kitta
 */
class YangValidatorTest extends AbstractYangTest {

	@Test
	def void checkYangVersion() {
		val it = load('''
			module example-system {
			  yang-version 1.2;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''');
		assertError(root.substatementsOfType(YangVersion).head, INCORRECT_VERSION, "1.2");
	}

	@Test
	def void checkSubstatement_Cardinality_MissingMandatory() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, "example-system");
	}

	@Test
	def void checkSubstatement_RequiredCardinality_Duplicate() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  prefix "sys";
			}
		''');
		assertError(root.substatementsOfType(Prefix).head, SUBSTATEMENT_CARDINALITY);
		assertError(root.substatementsOfType(Prefix).last, SUBSTATEMENT_CARDINALITY);
	}

	@Test
	def void checkSubstatement_Order() {
		val it = load('''
			module example-system {
			  namespace "urn:example:system";
			  yang-version 1.1;
			  contact "joe@example.com";
			  prefix "asd";
			}
		''');
		assertError(root.substatementsOfType(Prefix).head, SUBSTATEMENT_ORDERING, '''"asd"''');
	}

	@Test
	def void checkSubstatement_OptionalCardinality_Duplicate() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  contact "joe@example.com";
			  contact "joe@example.com";
			}
		''');
		assertError(root.substatementsOfType(Contact).head, SUBSTATEMENT_CARDINALITY);
		assertError(root.substatementsOfType(Contact).last, SUBSTATEMENT_CARDINALITY);
	}

	@Test
	def void checkSubstatement_VersionAwareCardinality_Invalid_01() {
		load('''
			module ietf-yang-types {
			  namespace "urn:yang:types";
			  prefix "yang";
			}
		''');
		val it = load('''
			module example-system {
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			    prefix "yang";
			    description "Imported from YANG types.";
			  }
			}
		''');
		assertError(root.substatementsOfType(Import).head.substatementsOfType(Description).head, SUBSTATEMENT_CARDINALITY);
	}
	
	@Test
	def void checkSubstatement_VersionAwareCardinality_Invalid_02() {
		load('''
			module ietf-yang-types {
			  yang-version 1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
		''');
		val it = load('''
			module example-system {
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			    prefix "yang";
			    description "Imported from YANG types.";
			  }
			}
		''');
		assertError(root.substatementsOfType(Import).head.substatementsOfType(Description).head, SUBSTATEMENT_CARDINALITY);
	}
	
	@Test
	def void checkSubstatement_VersionAwareCardinality_Valid() {
		load('''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
		''');
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			    prefix "yang";
			    description "Imported from YANG types.";
			  }
			}
		''');
		assertNoErrors;
	}

}
