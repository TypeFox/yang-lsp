package io.typefox.yang.tests

import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.Bit
import io.typefox.yang.yang.Contact
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Deviate
import io.typefox.yang.yang.Enum
import io.typefox.yang.yang.Expression
import io.typefox.yang.yang.FractionDigits
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Key
import io.typefox.yang.yang.KeyReference
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.Literal
import io.typefox.yang.yang.Modifier
import io.typefox.yang.yang.Position
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Refinable
import io.typefox.yang.yang.Revision
import io.typefox.yang.yang.Status
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import io.typefox.yang.yang.Value
import io.typefox.yang.yang.YangVersion
import org.eclipse.xtext.EcoreUtil2
import org.junit.Test

import static io.typefox.yang.validation.IssueCodes.*
import org.junit.Assert

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
		assertError(root, SUBSTATEMENT_CARDINALITY);
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
	def void checkSubstatement_Order_01() {
		val it = load('''
			module example-system {
			  namespace "urn:example:system";
			  yang-version 1.1;
			  contact "joe@example.com";
			  prefix "asd";
			}
		''');
		assertError(root.firstSubstatementsOfType(Prefix), SUBSTATEMENT_ORDERING, 'prefix');
	}

	@Test
	def void checkSubstatement_Order_02() {
		load('''
			module d {
			  namespace "urn:yang:types";
			  prefix "yang";
			}
		''');
		val it = load('''
			module example-system {
			  namespace "urn:example:system";
			  yang-version 1.1;
			  prefix "asd";
			  organization "organização güi";
			  contact "àéïç¢ô";
			  import d {
			    prefix "test";
			  }
			}
		''');
		assertError(root.firstSubstatementsOfType(Import), SUBSTATEMENT_ORDERING,
			'import', '''Substatement 'import' must be declared before 'organization'.''');
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
			    type bits {
			      range "1 | 4";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Refinable).head, TYPE_ERROR, '''1 | 4''');
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
	def void checkRangeRestriction_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type decimal64 {
			      range "-10 | 9";
			      fraction-digits 18;
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Expression).head, TYPE_ERROR, '-10');
	}

	@Test
	def void checkRangeRestriction_03() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type decimal64 {
			      range "-10 | 9";
			      fraction-digits 17;
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkRangeRestriction_04() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-int32-type {
			    type string {
			      length -1;
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Expression).head, TYPE_ERROR, '''-1''');
	}

	@Test
	def void checkLengthRestriction_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type int32 {
			      length "-10 | 9";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Refinable).head, TYPE_ERROR, '''-10 | 9''');
	}

	@Test
	def void checkLengthRestriction_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type binary {
			      length "255";
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkLengthRestriction_03() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type binary {
			      length -1;
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Literal).head, TYPE_ERROR, '''-1''');
	}

	@Test
	def void checkRangeOrder_01() {
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
	def void checkRangeOrder_02() {
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

	@Test
	def void checkModifier_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type string {
			      pattern '[xX][mM][lL].*' {
			        modifier invert-match;
			      }
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkModifier_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type string {
			      pattern '[xX][mM][lL].*' {
			        modifier blablabla;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Modifier).head, TYPE_ERROR, 'blablabla');
	}

	@Test
	def void checkPattern_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type string {
			      pattern "[0-9a-fA-F]*";
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkPattern_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type string {
			      length "1..max";
			      pattern '[a-zA-Z_][a-zA-Z0-9\-_.]*';
			      pattern '[xX][mM][lL].*' {
			        modifier invert-match;
			      }
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkPattern_03() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type int32 {
			      pattern '[a-zA-Z_][a-zA-Z0-9\-_.]*';
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Type).head, TYPE_ERROR, 'int32');
	}

	@Test
	def void checkEnumStatements() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type int32 {
			      enum blabla;
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Type).head, TYPE_ERROR, 'int32');
	}

	@Test
	def void checkEnumerationUniqueness_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type enumeration {
			      enum zero;
			      enum one;
			      enum seven {
			        value 7;
			      }
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkEnumerationUniqueness_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type enumeration {
			      enum dupe;
			      enum zero;
			      enum one;
			      enum seven {
			        value 7;
			      }
			      enum dupe;
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, DUPLICATE_ENUMERABLE_NAME, 'dupe');
	}

	@Test
	def void checkEnumerationName_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type enumeration {
			      enum "";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, TYPE_ERROR, '''""''');
	}

	@Test
	def void checkEnumerationName_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type enumeration {
			      enum " 36";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, TYPE_ERROR, '''" 36"''');
	}

	@Test
	def void checkEnumerationName_03() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type enumeration {
			      enum "36 ";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, TYPE_ERROR, '''"36 "''');
	}

	@Test
	def void checkEnumerationValue_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type enumeration {
			      enum "a" {
			        value bb;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Value).head, ORDINAL_VALUE, '''bb''');
	}

	@Test
	def void checkEnumerationValue_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type enumeration {
			      enum "a" {
			        value -2147483649;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Value).head, ORDINAL_VALUE, '''-2147483649''');
	}

	@Test
	def void checkEnumerationValue_03() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type enumeration {
			      enum "a" {
			        value 2147483648;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Value).head, ORDINAL_VALUE, '''2147483648''');
	}

	@Test
	def void checkEnumerationValue_04() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type enumeration {
			      enum "a" {
			        value 10;
			      }
			      enum "b" {
			        value 10;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Value).head, DUPLICATE_ENUMERABLE_VALUE, '''10''');
	}

	@Test
	def void checkEnumerationValue_05() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			    type enumeration {
			      enum "a" {
			        value 2147483647;
			      }
			      enum "b";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, ORDINAL_VALUE, '''"b"''');
	}

	@Test
	def void checkEnumerationValue_06() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-sub-type {
			  	type my-base-enumeration-type {
			  	  enum yellow {
			  	    value 4; // illegal value change
			  	  }
			  	  enum red {
			  	    value 3;
			  	  }
			  	}
			  }
			  typedef my-base-enumeration-type {
			    type enumeration {
			      enum white {
			        value 1;
			      }
			      enum yellow {
			        value 2;
			      }
			      enum red {
			        value 3;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, ENUMERABLE_RESTRICTION_VALUE, '''yellow''');
	}

	@Test
	def void checkEnumerationValue_07() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-sub-type {
			  	type my-base-enumeration-type {
			  	  enum black;
			  	}
			  }
			  typedef my-base-enumeration-type {
			    type enumeration {
			      enum white {
			        value 1;
			      }
			      enum yellow {
			        value 2;
			      }
			      enum red {
			        value 3;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, ENUMERABLE_RESTRICTION_NAME, '''black''');
	}

	@Test
	def void checkUnionType_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef bar {
			    type union {
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Type).head, TYPE_ERROR, '''union''');
	}

	@Test
	def void checkUnionType_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef bar {
			    type union {
			      type string {
			        pattern "[0-9a-fA-F]*";
			      }
			      type enumeration {
			        enum default-filter;
			      }
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkBitsType_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef bar {
			    type bits {
			    	  bit disable-nagle {
			    	    position 0;
			      }
			      bit auto-sense-speed {
			        position 1;
			      }
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkBitsType_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef bar {
			    type bits {
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Type).head, TYPE_ERROR, '''bits''');
	}

	@Test
	def void checkBitsType_03() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef bar {
			    type bits {
			    	  bit dupe {
			    	    position 0;
			      }
			      bit dupe {
			        position 1;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Bit).head, DUPLICATE_ENUMERABLE_NAME, '''dupe''');
	}

	@Test
	def void checkBitsPosition_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef bar {
			    type bits {
			    	  bit a {
			    	    position 3;
			      }
			      bit b {
			        position 3;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Position).head, DUPLICATE_ENUMERABLE_VALUE, '''3''');
	}

	@Test
	def void checkBitsPosition_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef bar {
			    type bits {
			    	  bit a {
			    	    position invalid;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Position).head, ORDINAL_VALUE, '''invalid''');
	}

	@Test
	def void checkBitsPosition_03() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef bar {
			    type bits {
			    	  bit a {
			    	    position -1;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Position).head, ORDINAL_VALUE, '''-1''');
	}

	@Test
	def void checkBitsPosition_04() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef bar {
			    type bits {
			    	  bit a {
			    	    position 4294967296;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Position).head, ORDINAL_VALUE, '''4294967296''');
	}

	@Test
	def void checkBitsPosition_05() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef bar {
			    type bits {
			    	  bit canAssign;
			    	  bit a {
			    	    position 4294967295;
			      }
			      bit cannotAssign;
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Bit).head, ORDINAL_VALUE, '''cannotAssign''');
	}

	@Test
	def void checkBitsPosition_06() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef mybits-subtype {
			    type mybits-type {
			      bit disable-nagle {
			        position 0;
			      }
			      bit auto-sense-speed {
			        position 1;
			      }
			    }
			  }
			  typedef mybits-type {
			    type bits {
			      bit disable-nagle {
			        position 0;
			      }
			      bit auto-sense-speed {
			        position 1;
			      }
			      bit ten-mb-only {
			        position 2;
			      }
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkBitsPosition_07() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef mybits-subtype {
			    type mybits-type {
			      bit disable-nagle {
			        position 3;
			      }
			      bit auto-sense-speed {
			        position 1;
			      }
			    }
			  }
			  typedef mybits-type {
			    type bits {
			      bit disable-nagle {
			        position 0;
			      }
			      bit auto-sense-speed {
			        position 1;
			      }
			      bit ten-mb-only {
			        position 2;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Bit).head, ENUMERABLE_RESTRICTION_VALUE, '''disable-nagle''');
	}

	@Test
	def void checkBitsPosition_08() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef mybits-subtype {
			    type mybits-type {
			      bit invalid {
			        position 3;
			      }
			      bit auto-sense-speed {
			        position 1;
			      }
			    }
			  }
			  typedef mybits-type {
			    type bits {
			      bit disable-nagle {
			        position 0;
			      }
			      bit auto-sense-speed {
			        position 1;
			      }
			      bit ten-mb-only {
			        position 2;
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Bit).head, ENUMERABLE_RESTRICTION_NAME, '''invalid''');
	}

	@Test
	def void checkIdentityRef_01() {
		val it = load('''
			module example-my-crypto {
			  yang-version 1.1;
			  namespace "urn:example:my-crypto";
			  prefix mc;
			  identity eth-if-speed {
			  description 
			    "Representing the configured or negotiated speed of an Ethernet interface.  Definitions are only required for PHYs that can run at different speeds (e.g. BASE-T).";
			  }
			  leaf crypto {
			    type identityref {
			      base "eth-if-speed";
			    }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkIdentityRef_02() {
		val it = load('''
			module example-my-crypto {
			  yang-version 1.1;
			  namespace "urn:example:my-crypto";
			  prefix mc;
			  leaf crypto {
			    type identityref {
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Type).head, TYPE_ERROR, '''identityref''');
	}

	@Test
	def void checkRevisionFormat_01() {
		val it = load('''
			module example-my-crypto {
			  yang-version 1.1;
			  namespace "urn:example:my-crypto";
			  prefix mc;
			  revision 2017-01-10 {
			    description
			      "Updated to address CFC1 Review Comments.";
			    reference
			      "EVC Ethernet Services Definitions YANG Modules (MEF XX), TBD";
			  }
			}
		''');
		assertNoIssues;
	}

	@Test
	def void checkRevisionFormat_02() {
		val it = load('''
			module example-my-crypto {
			  yang-version 1.1;
			  namespace "urn:example:my-crypto";
			  prefix mc;
			  revision 10-01-2017 {
			    description
			      "Updated to address CFC1 Review Comments.";
			    reference
			      "EVC Ethernet Services Definitions YANG Modules (MEF XX), TBD";
			  }
			}
		''');
		assertWarning(EcoreUtil2.getAllContentsOfType(root, Revision).head, INVALID_REVISION_FORMAT, '10-01-2017');
	}

	@Test
	def void checkRevisionOrder_01() {
		val it = load('''
			module example-my-crypto {
			  yang-version 1.1;
			  namespace "urn:example:my-crypto";
			  prefix mc;
			  revision 2017-01-12;
			  revision 2017-01-12;
			  revision 2017-01-11;
			  revision 2017-01-10;
			}
		''');
		assertNoIssues;
	}

	@Test
	def void checkRevisionOrder_02() {
		val it = load('''
			module example-my-crypto {
			  yang-version 1.1;
			  namespace "urn:example:my-crypto";
			  prefix mc;
			  revision 2017-01-11;
			  revision 2017-01-12;
			  revision 2017-01-10;
			  revision 2017-01-10;
			}
		''');
		assertWarning(EcoreUtil2.getAllContentsOfType(root, Revision).head, REVISION_ORDER, '2017-01-12');
	}

	@Test
	def void checkTypedef_01() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef my-base-type {
			  }
			}
		''');
		assertError(root.firstSubstatementsOfType(Typedef), SUBSTATEMENT_CARDINALITY);
	}

	@Test
	def void checkTypedef_02() {
		val it = load('''
			module foo {
			  yang-version 1.1;
			  namespace "urn:yang:types";
			  prefix "yang";
			  typedef string {
			    type int32 {
			      range "1 .. 4";
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Typedef).head, BAD_TYPE_NAME, 'string');
	}

	@Test
	def void checkKey_01() {
		val it = load('''
			module deref {
			  yang-version 1.1;
			  namespace urn:deref;
			  prefix d;
			  list a {
			    key "ka1 ka2";
			    leaf ka1 { type string; }
			    leaf ka2 { type string; }
			    list b {
			      key kb;
			      leaf kb { type string; }
			      list c {
			        key kc;
			        leaf kc { type string; }
			      }
			      leaf lb { type string; }
			    }
			    leaf la { type string; }
			  }
			}
		''');
		assertNoErrors;
	}

	@Test
	def void checkKey_02() {
		val it = load('''
			module deref {
			  yang-version 1.1;
			  namespace urn:deref;
			  prefix d;
			  list a {
			    key "ka1 ka2 ka1";
			    leaf ka1 { type string; }
			    leaf ka2 { type string; }
			    list b {
			      key kb;
			      leaf kb { type string; }
			      list c {
			        key kc;
			        leaf kc { type string; }
			      }
			      leaf lb { type string; }
			    }
			    leaf la { type string; }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Key).head, KEY_DUPLICATE_LEAF_NAME, 'ka1');
	}

	@Test
	def void checkKey_Config() {
		val it = load('''
			module deref {
			  yang-version 1.1;
			  namespace urn:deref;
			  prefix d;
			  list a {
			    key "ka1";
			    leaf ka1 { type string; config false; }
			    leaf la { type string; }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, KeyReference).head, INVALID_CONFIG, 'ka1');
	}

	@Test
	def void checkConfig_01() {
		val it = load('''
			module deref {
			  yang-version 1.1;
			  namespace urn:deref;
			  prefix d;
			  container a {
			    config false;
			    choice c {
			      case a {
			        leaf myLeaf {
			          config true;
			        }
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Leaf).head.substatements.head, INVALID_CONFIG);
	}

	@Test
	def void checkConfig_02() {
		val it = load('''
			module deref {
			  yang-version 1.1;
			  namespace urn:deref;
			  prefix d;
			  container a {
			    config true;
			    choice c {
			      case a {
			        leaf myLeaf {
			          type string;
			          config false;
			        }
			      }
			    }
			  }
			}
		''');
		assertNoErrors(root);
	}

	@Test
	def void checkAugmentContent_01() {
		val it = load('''
			module amodule {
			  namespace "urn:test:amodule";
			  prefix "amodule";
			  grouping g {
			    leaf l { type string; }
			  }
			  rpc run {
			    input { uses g; }
			    output { 
			      uses g {
			        augment l {
			          leaf xxx {
			            type string;
			          }
			        }
			      }
			    }
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Augment).last, INVALID_AUGMENTATION);
	}

	@Test
	def void checkDeviateArgument_01() {
		#["not-supported", "add", "replace", "delete"].forEach [
			val it = load('''
				module d {
				  namespace urn:d;
				  prefix d;
				
				  container x {
				    choice c {
				      leaf d {
				        type string;
				      }
				    }
				  }
				
				  deviation /x/c/d {
				    deviate «it»;
				  }
				}
			''');
			assertNoErrors;
		];
	}

	@Test
	def void checkDeviateArgument_02() {
		val it = load('''
			module d {
			  namespace urn:d;
			  prefix d;
			
			  container x {
			    choice c {
			      leaf d {
			        type string;
			      }
			    }
			  }
			
			  deviation /x/c/d {
			    deviate blabla;
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Deviate).head, TYPE_ERROR);
	}

	@Test
	def void checkStatusArgument_01() {
		#["current", "deprecated", "obsolete"].forEach [
			val it = load('''
				module d {
				  namespace urn:d;
				  prefix d;
				
				  leaf Num1 {
				    type int32 {
				      range min..max;
				    }
				    description "test 1";
				    status «it»;
				  }
				}
			''');
			assertNoErrors;
		];
	}

	@Test
	def void checkStatusArgument_02() {
		val it = load('''
			module d {
			  namespace urn:d;
			  prefix d;
			
			  leaf Num1 {
			    type int32 {
			      range min..max;
			    }
			    description "test 1";
			    status blabla;
			  }
			}
		''');
		assertError(EcoreUtil2.getAllContentsOfType(root, Status).head, TYPE_ERROR);
	}
	
	@Test
	def void checkUriToProblem_01() {
		val model = loadWithSyntaxErrors('''
			module bug196 {
			    prefix bug196;
			    namespace bug196;
			    leaf key-id {
			        type string;
			
			        when "/ctxsr6k:contexts/ctxr6k:context/ctxr6k:context-"
			             + "name='local'" {
			                  description
			                  "";
			         }
			         }
			    }
			}
		''');
		
		val issues = validator.validate(model)
		val noUriIssues = issues.filter[it.uriToProblem === null].toList
		Assert.assertEquals("Some issues has no uriToProblem set", 0, noUriIssues.size)
		val eofError = issues.findFirst["extraneous input '}' expecting EOF" == message]
		Assert.assertEquals("Wrong URI to problem provided", "synthetic:///__synthetic0.yang", eofError.uriToProblem.toString)
	}

}
