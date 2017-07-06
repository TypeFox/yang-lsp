package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import org.junit.Assert
import org.junit.Test

class TypeLinkingTest extends AbstractYangTest {
	
	@Test def void testTypeLinking() {
		val m = load('''
			module foo {
				prefix "yt4";
				leaf xx { type con1_typ1; }
				leaf xxx { type yt4:con1_typ1; }
				typedef con1_typ1 {
					type string;
				}
			}
		''')
		val leafs = m.root.substatementsOfType(Leaf).iterator
		val typeDef = m.root.substatementsOfType(Typedef).head
		Assert.assertSame(typeDef, leafs.next.substatementsOfType(Type).head.typeRef.type)
		Assert.assertSame(typeDef, leafs.next.substatementsOfType(Type).head.typeRef.type)
	}
	
	@Test def void testTypeLinking_02() {
		val m = load('''
			module foo {
			    yang-version 1.1;
			    namespace "foo:bar";
			    prefix x;
			
			    typedef foo {
			 type int32 {
			     range "1..40 | 60..100";
			 }
			    } 
			    typedef foo2 {
			 type foo {
			     range "4..20";
			 }
			    }
			    typedef foo3 {
			 type foo2 {
			     range "5..15";
			 }
			    }
			}
		''')
		validator.assertNoErrors(m.root)
	}
	
	@Test def void testNestTypeLinking_02() {
		val m = load('''
			module foo {
			    yang-version 1.1;
			    namespace "foo:bar";
			    prefix x;
				
				grouping bar {
				    typedef foo2 {
				 type foo {
				     range "4..20";
				 }
				    }
				    leaf x {
				    		type foo2;
				    	}
				}
				grouping bar2 {
				    typedef foo2 {
				 type foo {
				     range "4..20";
				 }
				    }
				    leaf x {
				    		type foo2;
				    	}
				}
			    typedef foo {
			 type int32 {
			     range "1..40 | 60..100";
			 }
			    }
			}
		''')
		validator.assertNoErrors(m.root)
	}
	
	@Test def void testNestTypeLinking_03() {
		val m = load('''
			module foo {
			    yang-version 1.1;
			    namespace "foo:bar";
			    prefix x;
				
				grouping G_one {
					typedef local_1 { type int32; units meters; default 0; }
					uses G_two;
					leaf test_leaf { type local_1; }
				}
			    grouping G_two {
					typedef local_1 { type string; default fred; }
					container G_ddd {
					}
					leaf test_leaf2 { type local_1; }
				}
			}
		''')
		validator.assertNoErrors(m.root)
	}
}