package io.typefox.yang.tests

import io.typefox.yang.yang.Contact
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.YangVersion
import org.junit.Test

import static io.typefox.yang.validation.IssueCodes.*
import org.junit.Ignore

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
		''')
		assertError(root.subStatementsOfType(YangVersion).head, INCORRECT_VERSION, "1.2");
	}

	@Ignore("TODO")
	@Test
	def void checkSubstatement_Cardinality_MissingMandatory() {
		val it = load('''
			module example-system {
			  namespace "urn:example:system";
			  prefix "sys";
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
		assertError(root.subStatementsOfType(Prefix).head, SUBSTATEMENT_CARDINALITY);
		assertError(root.subStatementsOfType(Prefix).last, SUBSTATEMENT_CARDINALITY);
	}

	@Test
	def void checkSubstatement_Order() {
		val it = load('''
			module example-system {
			  namespace "urn:example:system";
			  yang-version 1.1;
			  prefix "sys";
			}
		''');
		assertError(root.subStatementsOfType(YangVersion).head, SUBSTATEMENT_ORDERING, "1.1");
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
		assertError(root.subStatementsOfType(Contact).head, SUBSTATEMENT_CARDINALITY);
		assertError(root.subStatementsOfType(Contact).last, SUBSTATEMENT_CARDINALITY);
	}

}
