package io.typefox.yang.tests

import io.typefox.yang.yang.BinaryOperation
import io.typefox.yang.yang.Contact
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Expression
import io.typefox.yang.yang.FractionDigits
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Range
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.YangVersion
import org.eclipse.xtext.EcoreUtil2
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
		assertError(root.firstSubstatementsOfType(YangVersion), INCORRECT_VERSION, "1.2");
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
		assertError(root.firstSubstatementsOfType(Prefix), SUBSTATEMENT_CARDINALITY);
		assertError(root.lastSubstatementsOfType(Prefix), SUBSTATEMENT_CARDINALITY);
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
		assertError(root.firstSubstatementsOfType(Prefix), SUBSTATEMENT_ORDERING, '''"asd"''');
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
		assertError(root.firstSubstatementsOfType(Contact), SUBSTATEMENT_CARDINALITY);
		assertError(root.lastSubstatementsOfType(Contact), SUBSTATEMENT_CARDINALITY);
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
		assertError(root.firstSubstatementsOfType(Import).firstSubstatementsOfType(Description),
			SUBSTATEMENT_CARDINALITY);
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
		assertError(root.firstSubstatementsOfType(Import).firstSubstatementsOfType(Description),
			SUBSTATEMENT_CARDINALITY);
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

	@Test
	def void checkRangeOperator_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-int32-type {
			    type int32 {
			      range "1 + 4";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, BinaryOperation).head, SYNTAX_ERROR, "+");
	}

	@Test
	def void checkRangeOperator_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-int32-type {
			    type int32 {
			      range "1 .. 4";
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkRangeOperator_03() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-int32-type {
			    type int32 {
			      range "1 | 4";
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkTypeRestriction() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-int32-type {
			    type string {
			      range "1 | 4";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Range).head, SYNTAX_ERROR, '''1 | 4''');
	}

	@Test
	def void checkRangeRestriction_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-int32-type {
			    type uint8 {
			      range -1;
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Expression).head, TYPE_ERROR, '''-1''');
	}
	
	@Test
	def void checkrangeOrder_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type int32 {
			      range "1 | 1 .. 2";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Expression).head, TYPE_ERROR, '''1 .. 2''');
	}
	
	@Test
	def void checkrangeOrder_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type int32 {
			      range "5 .. 10 | 1 .. 2";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Expression).head, TYPE_ERROR, '''1 .. 2''');
	}

	@Test
	def void checkFractionDigits_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type int32 {
			      range "1 | 4";
			      fraction-digits 2;
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Type).head, TYPE_ERROR, 'int32');
	}

	@Test
	def void checkFractionDigits_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type decimal64 {
			      range "1 | 4";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Type).head, TYPE_ERROR, 'decimal64');
	}
	
	@Test
	def void checkFractionDigits_03() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type decimal64 {
			      range "1 | 4";
			      fraction-digits bar;
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, FractionDigits).head, TYPE_ERROR, 'bar');
	}
	
	@Test
	def void checkFractionDigits_04() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type decimal64 {
			      range "1 | 4";
			      fraction-digits 19;
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, FractionDigits).head, TYPE_ERROR, '19');
	}
	
	@Test
	def void checkFractionDigits_05() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type decimal64 {
			      range "1 | 4";
			      fraction-digits 2;
			    }
			  }
			}
		''');
		assertNoErrors;
	}

}
