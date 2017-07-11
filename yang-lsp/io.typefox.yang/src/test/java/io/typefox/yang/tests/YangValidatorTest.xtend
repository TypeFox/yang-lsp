package io.typefox.yang.tests

import io.typefox.yang.yang.Bit
import io.typefox.yang.yang.Contact
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Enum
import io.typefox.yang.yang.Expression
import io.typefox.yang.yang.FractionDigits
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Literal
import io.typefox.yang.yang.Modifier
import io.typefox.yang.yang.Position
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Refinable
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Value
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, TYPE_ERROR, 'dupe');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Value).head, TYPE_ERROR, '''bb''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Value).head, TYPE_ERROR, '''-2147483649''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Value).head, TYPE_ERROR, '''2147483648''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Value).head, TYPE_ERROR, '''10''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, TYPE_ERROR, '''"b"''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, TYPE_ERROR, '''yellow''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Enum).head, TYPE_ERROR, '''black''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Bit).head, TYPE_ERROR, '''dupe''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Position).head, TYPE_ERROR, '''3''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Position).head, TYPE_ERROR, '''invalid''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Position).head, TYPE_ERROR, '''-1''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Position).head, TYPE_ERROR, '''4294967296''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Bit).head, TYPE_ERROR, '''cannotAssign''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Position).head, TYPE_ERROR, '''3''');
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
		assertError(EcoreUtil2.getAllContentsOfType(root, Bit).head, TYPE_ERROR, '''invalid''');
	}

}
