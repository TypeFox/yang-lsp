package io.typefox.yang.tests

import com.google.inject.Inject
import io.typefox.yang.utils.YangBuiltinExtensions
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import org.junit.Test

import static extension org.junit.Assert.*

/**
 * Test for the YANG built-in type extensions.
 * 
 * @author akos.kitta
 */
class YangBuiltinExtensionsTest extends AbstractYangTest {

	@Inject
	extension YangBuiltinExtensions;

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
		'''.load.root.substatementsOfType(Typedef).head.builtin.assertTrue;
	}

	@Test
	def void checkBuiltin_False() {
		'''
			module foo {
			  typedef my-type1 {
			    type my-base-int32-type {
			      range "11..max"; // 11..20
			    }
			  }
			}
		'''.load.root.substatementsOfType(Typedef).head.builtin.assertFalse;
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
		'''.load.root.substatementsOfType(Typedef).head.substatementsOfType(Type).head.subtypeOfInteger.assertTrue;
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
		'''.load.root.substatementsOfType(Typedef).head.substatementsOfType(Type).head.subtypeOfInteger.assertFalse;
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
		'''.load.root.substatementsOfType(Typedef).last.substatementsOfType(Type).head.subtypeOfInteger.assertTrue;
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
		'''.load.root.substatementsOfType(Typedef).last.substatementsOfType(Type).head.subtypeOfInteger.assertFalse;
	}

}
