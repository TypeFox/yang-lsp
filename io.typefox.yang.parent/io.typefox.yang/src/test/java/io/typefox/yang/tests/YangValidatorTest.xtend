package io.typefox.yang.tests

import com.google.inject.Inject
import io.typefox.yang.yang.YangFile
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith

import static io.typefox.yang.validation.YangIssueCodes.*
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
	def void checkYangVersion() {
		val result = '''
			module example-system {
			  yang-version 1.2;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertError(YANG_VERSION, INCORRECT_VERSION, 39, 3);
	}

	@Test
	def void checkModule_Version_Missing() {
		val result = '''
			module example-system {
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 7, 14);
	}

	@Test
	def void checkModule_Version() {
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
	def void checkModule_Version_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 26, 17);
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 46, 17);
	}

	@Test
	def void checkModule_Namespace_Missing() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 7, 14);
	}

	@Test
	def void checkModule_Namespace() {
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
	def void checkModule_Namespace_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  namespace "urn:example:system";
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 46, 31);
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 80, 31);
	}

	@Test
	def void checkModule_Prefix_Missing() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			}
		'''.parse;
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 7, 14);
	}

	@Test
	def void checkModule_Prefix() {
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
	def void checkModule_Prefix_Order() {
		val result = '''
			module example-system {
			  namespace "urn:example:system";
			  yang-version 1.1;
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUBSTATEMENT_ORDERING, 60, 17);
	}

	@Test
	def void checkModule_Prefix_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  prefix "sys";
			}
		'''.parse;
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 80, 13);
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 96, 13);
	}

	@Test
	def void checkModule_Contact_Missing() {
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
	def void checkModule_Contact() {
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
	def void checkModule_Contact_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  contact "joe@example.com";
			  contact "joe@example.com";
			}
		'''.parse;
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 96, 26);
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 125, 26);
	}

	@Test
	def void checkModule_Description_Missing() {
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
	def void checkModule_Description() {
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
	def void checkModule_Description_Duplicate() {
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
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 96, 72);
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 171, 72);
	}

	@Test
	def void checkModule_Organization_Missing() {
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
	def void checkModule_Organization() {
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
	def void checkModule_Organization_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  organization "Example Inc.";
			  organization "Example Inc.";
			}
		'''.parse;
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 96, 28);
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 127, 28);
	}

	@Test
	def void checkModule_Reference_Missing() {
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
	def void checkModule_Reference() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  reference "RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkModule_Reference_Duplicate() {
		val result = '''
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  reference "RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			  reference "RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			}
		'''.parse;
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 96, 72);
		result.assertError(MODULE, SUBSTATEMENT_CARDINALITY, 171, 72);
	}

	@Test
	def void checkModule_Invalid() {
		val result = '''
			module foo-system {
			  yang-version 1.1;
			  namespace "urn:foo:system";
			  prefix "foo";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  belongs-to foo-system {
			    prefix "foo";
			  }
			}
		'''.parse;
		result.assertError(MODULE, UNEXPECTED_SUBSTATEMENT, 185, 45);
	}

	@Test
	def void checkImport_Prefix_Missing() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  }
			}
		'''.parse;
		result.assertError(IMPORT, SUBSTATEMENT_CARDINALITY, 198, 15);
	}

	@Test
	def void checkImport_Prefix() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  	prefix "yang";
			  }
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkImport_Duplicate() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  	prefix "yang";
			  	prefix "yang";
			  }
			}
		'''.parse;
		result.assertError(IMPORT, SUBSTATEMENT_CARDINALITY, 219, 14);
		result.assertError(IMPORT, SUBSTATEMENT_CARDINALITY, 237, 14);
	}

	@Test
	def void checkImport_Description_Missing() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  	prefix "yang";
			  }
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkImport_Description() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  	prefix "yang";
			  	description "Imported from YANG types.";
			  }
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkImport_Description_Duplicate() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
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
		'''.parse;
		result.assertError(IMPORT, SUBSTATEMENT_CARDINALITY, 237, 40);
		result.assertError(IMPORT, SUBSTATEMENT_CARDINALITY, 281, 40);
	}

	@Test
	def void checkImport_Reference_Missing() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  	prefix "yang";
			  }
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkImport_Reference() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  	prefix "yang";
			  	reference "RFC 3986: Uniform Resource Identifier (URI): Generic Syntax";
			  }
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkImport_Reference_Duplicate() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
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
		'''.parse;
		result.assertError(IMPORT, SUBSTATEMENT_CARDINALITY, 237, 72);
		result.assertError(IMPORT, SUBSTATEMENT_CARDINALITY, 313, 72);
	}

	@Test
	def void checkImport_Revision_Missing() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  	prefix "yang";
			  }
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkImport_Revision() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  	prefix "yang";
			  	revision-date 2008-01-01;
			  }
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkImport_Revision_Duplicate() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
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
		'''.parse;
		result.assertError(IMPORT, SUBSTATEMENT_CARDINALITY, 237, 25);
		result.assertError(IMPORT, SUBSTATEMENT_CARDINALITY, 266, 25);
	}

	@Test
	def void checkImport_Invalid() {
		val result = '''
			module ietf-yang-types {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			}
			
			module example-system {
			  yang-version 1.1;
			  namespace "urn:example:system";
			  prefix "sys";
			  import ietf-yang-types {
			  	prefix "yang";
			  	organization "Example Inc.";
			  }
			}
		'''.parse;
		result.assertError(IMPORT, UNEXPECTED_SUBSTATEMENT, 237, 28);
	}

	@Test
	def void checkRevision_Description_Missing() {
		val result = '''
			revision 2007-06-09 {
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkRevision_Description() {
		val result = '''
			revision 2007-06-09 {
			  description "Some description.";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkRevision_Description_Duplicate() {
		val result = '''
			revision 2007-06-09 {
			  description "Some description.";
			  description "Some description.";
			}
		'''.parse;
		result.assertError(REVISION, SUBSTATEMENT_CARDINALITY, 24, 32);
		result.assertError(REVISION, SUBSTATEMENT_CARDINALITY, 59, 32);
	}

	@Test
	def void checkRevision_Reference_Missing() {
		val result = '''
			revision 2007-06-09 {
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkRevision_Reference() {
		val result = '''
			revision 2007-06-09 {
			  reference "Some external reference.";
			}
		'''.parse;
		result.assertNoErrors;
	}

	@Test
	def void checkRevision_Reference_Duplicate() {
		val result = '''
			revision 2007-06-09 {
			  reference "Some external reference.";
			  reference "Some external reference.";
			}
		'''.parse;
		result.assertError(REVISION, SUBSTATEMENT_CARDINALITY, 24, 37);
		result.assertError(REVISION, SUBSTATEMENT_CARDINALITY, 64, 37);
	}

	@Test
	def void checkRevision_Invalid() {
		val result = '''
			revision 2007-06-09 {
			  organization "Example Inc.";
			}
		'''.parse;
		result.assertError(REVISION, UNEXPECTED_SUBSTATEMENT, 24, 28);
	}

}
