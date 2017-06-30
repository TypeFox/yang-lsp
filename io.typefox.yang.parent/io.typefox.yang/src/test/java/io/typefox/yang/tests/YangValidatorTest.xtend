package io.typefox.yang.tests

import io.typefox.yang.yang.Import
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
		''')
		assertError(root.subStatements.filter(YangVersion).head, INCORRECT_VERSION, 39, 3);
	}

	@Test
	def void checkModule_Version_Missing() {
		val it = load('''
			module example-system {
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, 7, 14);
	}

	@Test
	def void checkModule_Version() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Version_Duplicate() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, 26, 17);
		assertError(root, SUBSTATEMENT_CARDINALITY, 46, 17);
	}

	@Test
	def void checkModule_Namespace_Missing() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  prefix "sys";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, 7, 14);
	}

	@Test
	def void checkModule_Namespace() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Namespace_Duplicate() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, 46, 31);
		assertError(root, SUBSTATEMENT_CARDINALITY, 80, 31);
	}

	@Test
	def void checkModule_Prefix_Missing() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, 7, 14);
	}

	@Test
	def void checkModule_Prefix() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Prefix_Order() {
		val it = load('''
			module example-system {
			  namespace "urn:example:system";
			  yang-version 1.1;
			  prefix "sys";
			}
		''');
		assertError(root, SUBSTATEMENT_ORDERING, 60, 17);
	}

	@Test
	def void checkModule_Prefix_Duplicate() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  prefix "sys";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, 80, 13);
		assertError(root, SUBSTATEMENT_CARDINALITY, 96, 13);
	}

	@Test
	def void checkModule_Contact_Missing() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Contact() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  contact "joe@example.com";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Contact_Duplicate() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  contact "joe@example.com";
			  contact "joe@example.com";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, 96, 26);
		assertError(root, SUBSTATEMENT_CARDINALITY, 125, 26);
	}

	@Test
	def void checkModule_Description_Missing() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Description() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  description
			    "The module for entities implementing the Example system.";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Description_Duplicate() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  description
			    "The module for entities implementing the Example system.";
			  description
			    "The module for entities implementing the Example system.";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, 96, 75);
		assertError(root, SUBSTATEMENT_CARDINALITY, 174, 75);
	}

	@Test
	def void checkModule_Organization_Missing() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Organization() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  organization "Example Inc.";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Organization_Duplicate() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  organization "Example Inc.";
			  organization "Example Inc.";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, 96, 28);
		assertError(root, SUBSTATEMENT_CARDINALITY, 127, 28);
	}

	@Test
	def void checkModule_Reference_Missing() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Reference() {
		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  reference "RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			}
		''').assertNoErrors;
	}

	@Test
	def void checkModule_Reference_Duplicate() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  reference "RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			  reference "RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			}
		''');
		assertError(root, SUBSTATEMENT_CARDINALITY, 96, 72);
		assertError(root, SUBSTATEMENT_CARDINALITY, 171, 72);
	}

	@Test
	def void checkModule_Invalid() {
		load('''
			module foo-system {
			  yang-version 1.1;
			  namespace "urn:foo:system";
			  prefix "foo";
			}
		''');

		val it = load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  belongs-to foo-system {
			    prefix "foo";
			  }
			}
		''');
		assertError(root, UNEXPECTED_SUBSTATEMENT, 96, 45);
	}

	@Test
	def void checkImport_Prefix_Missing() {
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
			  }
			}
		''');
		assertError(root.subStatements.filter(Import).head, SUBSTATEMENT_CARDINALITY, 103, 15);
	}

	@Test
	def void checkImport_Prefix() {
		load('''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
		''');

		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			    prefix "yang";
			  }
			}
		''').assertNoErrors;
	}

	@Test
	def void checkImport_Duplicate() {
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
			    prefix "yang";
			  }
			}
		''');
		assertError(root.subStatements.filter(Import).head, SUBSTATEMENT_CARDINALITY, 125, 14);
		assertError(root.subStatements.filter(Import).head, SUBSTATEMENT_CARDINALITY, 144, 14);
	}

	@Test
	def void checkImport_Description_Missing() {
		load('''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
		''');

		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			    prefix "yang";
			  }
			}
		''').assertNoErrors;
	}

	@Test
	def void checkImport_Description() {
		load('''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
		''');

		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			    prefix "yang";
			    description "Imported from YANG types.";
			  }
			}
		''').assertNoErrors;
	}

	@Test
	def void checkImport_Description_Duplicate() {
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
			    description "Imported from YANG types.";
			  }
			}
		''');
		assertError(root.subStatements.filter(Import).head, SUBSTATEMENT_CARDINALITY, 144, 40);
		assertError(root.subStatements.filter(Import).head, SUBSTATEMENT_CARDINALITY, 189, 40);
	}

	@Test
	def void checkImport_Reference_Missing() {
		load('''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
		''');

		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			    prefix "yang";
			  }
			}
		''').assertNoErrors;
	}

	@Test
	def void checkImport_Reference() {
		load('''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
		''');

		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			    prefix "yang";
			    reference "RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			  }
			}
		''').assertNoErrors;
	}

	@Test
	def void checkImport_Reference_Duplicate() {
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
			    reference "RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			    reference "RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			  }
			}
		''');
		assertError(root.subStatements.filter(Import).head, SUBSTATEMENT_CARDINALITY, 144, 72);
		assertError(root.subStatements.filter(Import).head, SUBSTATEMENT_CARDINALITY, 221, 72);
	}

	@Test
	def void checkImport_Revision_Missing() {
		load('''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
		''');

		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  	prefix "yang";
			  }
			}
		''').assertNoErrors;
	}

	@Test
	def void checkImport_Revision() {
		load('''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  revision 2008-01-01 {
			  }
			}
		''');

		load('''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			    prefix "yang";
			    revision-date 2008-01-01;
			  }
			}
		''').assertNoErrors;
	}

	@Test
	def void checkImport_Revision_Duplicate() {
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
			    revision-date 2008-01-01;
			    revision-date 2008-01-01;
			  }
			}
		''');
		assertError(root.subStatements.filter(Import).head, SUBSTATEMENT_CARDINALITY, 144, 25);
		assertError(root.subStatements.filter(Import).head, SUBSTATEMENT_CARDINALITY, 174, 25);
	}

	@Test
	def void checkImport_Invalid() {
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
			    organization "Example Inc.";
			  }
			}
		''');
		assertError(root.subStatements.filter(Import).head, UNEXPECTED_SUBSTATEMENT, 144, 28);
	}

}
