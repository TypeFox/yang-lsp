package io.typefox.yang.tests

import com.google.inject.Inject
import io.typefox.yang.utils.YangTypeExtensions
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import org.junit.Assert
import org.junit.Test

import static extension org.junit.Assert.*

/**
 * Test for the YANG built-in type extensions.
 * 
 * @author akos.kitta
 */
class YangTypeExtensionsTest extends AbstractYangTest {

	@Inject
	extension YangTypeExtensions;

	@Test
	def void checkBuiltin_True() {
		'''
			module foo {
			  typedef my-base-int32-type {
			    type int32 {
			      range "1..4";
			    }
			  }
			}
		'''.load.root.firstSubstatementsOfType(Typedef).builtin.assertTrue;
	}

	@Test
	def void checkBuiltin_False() {
		'''
			module foo {
			  typedef my-type1 {
			    type my-base-int32-type {
			      range "11..max";
			    }
			  }
			}
		'''.load.root.firstSubstatementsOfType(Typedef).builtin.assertFalse;
	}

	@Test
	def void checkSubtypeOfInteger_01() {
		'''
			module foo {
			  typedef my-base-int32-type {
			    type int32 {
			      range "1..4";
			    }
			  }
			}
		'''.load.root.firstSubstatementsOfType(Typedef).firstSubstatementsOfType(Type).subtypeOfInteger.assertTrue;
	}

	@Test
	def void checkSubtypeOfInteger_02() {
		'''
			module foo {
			  typedef my-base-int32-type {
			    type decimal64 {
			      range "1..4";
			    }
			  }
			}
		'''.load.root.firstSubstatementsOfType(Typedef).firstSubstatementsOfType(Type).subtypeOfInteger.assertFalse;
	}

	@Test
	def void checkSubtypeOfInteger_03() {
		'''
			module foo {
			  typedef my-base-int32-type {
			    type int32 {
			      range "1..4 | 10..20";
			    }
			  }
			
			  typedef my-type1 {
			  type my-base-int32-type {
			    range "11..max";
			  }
			  }
			}
		'''.load.root.lastSubstatementsOfType(Typedef).firstSubstatementsOfType(Type).subtypeOfInteger.assertTrue;
	}

	@Test
	def void checkSubtypeOfInteger_04() {
		'''
			module foo {
			  typedef my-base-int32-type {
			    type decimal64 {
			      range "1..4 | 10..20";
			    }
			  }
			
			  typedef my-type1 {
			  type my-base-int32-type {
			    range "11..max";
			  }
			  }
			}
		'''.load.root.lastSubstatementsOfType(Typedef).firstSubstatementsOfType(Type).subtypeOfInteger.assertFalse;
	}

	@Test
	def void checkYangRange_01() {
		'''
			module foo {
			  typedef my-base-int32-type {
			    type int32 {
			      range "1..4";
			    }
			  }
			}
		'''.load.root.firstSubstatementsOfType(Typedef).firstSubstatementsOfType(Type).refinement.yangRefinable.toString.
			assertEquals('1..4');
	}

	@Test
	def void checkYangRange_02() {
		'''
			module foo {
			  typedef my-base-int32-type {
			    type int32 {
			      range "1 | 2 | 4..5 | 6";
			    }
			  }
			}
		'''.load.root.firstSubstatementsOfType(Typedef).firstSubstatementsOfType(Type).refinement.yangRefinable.toString.
			assertEquals('1 | 2 | 4..5 | 6');
	}

	@Test
	def void checkYangRange_03() {
		'''
			module c {
			  typedef my-base-int32-type {
			    type int32 {
			      range "1..4 | 10..200";
			    }
			  }
			  typedef my-type1 {
			    type my-base-int32-type {
			      range "2..max";
			    }
			  }
			  typedef my-type2 {
			    type my-type1 {
			      range "min..max";
			    }
			  }
			}
		'''.load.root.lastSubstatementsOfType(Typedef).firstSubstatementsOfType(Type).refinement.yangRefinable.toString.
			assertEquals('2..200')
	}

	private def assertEquals(CharSequence actual, CharSequence expected) {
		Assert.assertEquals(expected, actual);
	}

}
