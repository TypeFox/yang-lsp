package io.typefox.yang.tests

import com.google.inject.Inject
import io.typefox.yang.yang.YangFile
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith

import static io.typefox.yang.validation.YangValidator.YangIssueCodes.*
import static io.typefox.yang.yang.YangPackage.Literals.*

/**
 * Validation test for the YANG language.
 * 
 * @author akos.kitta
 */
@RunWith(XtextRunner)
@InjectWith(YangInjectorProvider)
class YangValidatorTest {

	@Inject
	extension ParseHelper<YangFile>;

	@Inject
	extension ValidationTestHelper;

	@Test
	def void checkVersion_Missing() {
		val result = '''
			module example-system {
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 7, 14);
	}

	@Test
	def void checkVersion() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkVersion_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 26, 17);
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 46, 17);
	}

	@Test
	def void checkNamespace_Missing() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 7, 14);
	}

	@Test
	def void checkNamespace() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkNamespace_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 46, 31);
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 80, 31);
	}

	@Test
	def void checkPrefix_Missing() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			}
		'''.parse;
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 7, 14);
	}

	@Test
	def void checkPrefix() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkPrefix_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 80, 13);
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 96, 13);
	}

	@Test
	def void checkContact_Missing() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkContact() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  contact "joe@example.com";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkContact_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  contact "joe@example.com";
			  contact "joe@example.com";
			}
		'''.parse;
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 96, 26);
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 125, 26);
	}

	@Test
	def void checkDescription_Missing() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkDescription() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  description
				"The module for entities implementing the Example system.";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkDescription_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  description
				"The module for entities implementing the Example system.";
				 description
				"The module for entities implementing the Example system.";
			}
		'''.parse;
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 96, 72);
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 171, 72);
	}

	@Test
	def void checkOrganization_Missing() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkOrganization() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  organization "Example Inc.";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkOrganization_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  organization "Example Inc.";
			  organization "Example Inc.";
			}
		'''.parse;
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 96, 28);
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 127, 28);
	}

	@Test
	def void checkReference_Missing() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkReference() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  reference
				"RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkReference_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  reference
				"RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			  reference
				"RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			}
		'''.parse;
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 96, 73);
		result.assertError(MODULE, SUB_STATEMENT_CARDINALITY, 172, 73);
	}

}
