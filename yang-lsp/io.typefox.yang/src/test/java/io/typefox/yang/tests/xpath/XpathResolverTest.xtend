package io.typefox.yang.tests.xpath

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Must
import io.typefox.yang.yang.ParentRef
import io.typefox.yang.yang.RelativePath
import io.typefox.yang.yang.XpathNameTest
import io.typefox.yang.yang.YangPackage
import java.io.File
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.workspace.FileProjectConfig
import org.eclipse.xtext.workspace.ProjectConfigAdapter
import org.junit.Assert
import org.junit.Test


class XpathResolverTest extends AbstractYangTest {
	
	/**
	 * XPATH_LINKING_ERRORS are enabled for these tests
	 */	
	override load(CharSequence txt) {
		val root = new File("./src/test/java/io/typefox/yang/tests/xpath/")
		ProjectConfigAdapter.install(resourceSet, new FileProjectConfig(root))
		return super.load(txt)
	}
	
	@Test def void testSimple() {
		val r = '''
			module foo {
				prefix foo;
				namespace urn:foo;
				container a {
					must ./b/../b/c;
					container b {
						leaf c {
							type string;
						}
					}
				}
			}
		'''.load
		val must = r.root.eAllContents.filter(Must).head
		val steps = must.eAllContents.filter(XpathNameTest).toList
		Assert.assertEquals(3, steps.size)
		for (e : steps) {
			val n = NodeModelUtils.findNodesForFeature(e, YangPackage.Literals.XPATH_NAME_TEST__REF)
			Assert.assertEquals(n.head.text, e.ref.name)
		}
	}
	
	@Test def void testSibling() {
		val r = '''
			module foo {
				prefix foo;
				namespace urn:foo;
				
				list foo-bar {
					must "../foo-bar[b = current()/preceding-sibling::foo-bar/b]";
					container b {
						leaf c {
							type string;
						}
					}
				}
			}
		'''.load
		assertNoErrors(r.root)
	}
	
	@Test def void testDescendant() {
		val r = '''
			module foo {
				prefix foo;
				namespace urn:foo;
				
				container a {
					must "//c";
«««					must '/*/*/c';
«««					must */c;
					
					container b {
						container c {
						}
					}
				}
			}
		'''.load
		assertNoErrors(r.root)
	}
	
	@Test def void testGrouping() {
		val r = '''
			module foo {
				prefix foo;
				namespace urn:foo;
				
				identity MyBase {}
				
				grouping ggg {
			       leaf XXX { type int32; }
			       container test-top {
			         typedef MyType { type uint16; }
			         must "foo:bar < 42";
			
			         must "bar = 142";
			         leaf bar { 
			           type uint8;
			           when "../../foo:XXX =  11";
			         }
			         leaf baz { 
			             must "../goo = 'my-identity'";
			             type MyType;
			         }
			         leaf goo { 
			            type identityref {
			               base MyBase;
			            }
			            default my-identity;
			         }
			         leaf AA { type MyType; }
			         leaf BB { type foo:MyType; }
			      }
			   }
			}
		'''.load
		assertNoErrors(r.root)
	}
	
	@Test def void testParents() {
		val r = '''
			module foo {
				prefix foo;
				namespace urn:foo;
			    leaf c5-leaf {
			      type string;
			    }
			
			    list c5-list {
			       key a;
			       leaf a { type string; }
			       leaf b { 
			          type leafref { 
			             path "../../c5-leaf"; 
			          }
			       }
			    }
			}
		'''.load
		val parentRef = r.root.eAllContents.filter(RelativePath).head
		Assert.assertEquals("c5-list", (parentRef.getStep as ParentRef).ref.name)
		val name = r.root.eAllContents.filter(XpathNameTest).head
		Assert.assertEquals("c5-leaf", name.ref.name)
		assertNoErrors(r)
	}
	
	@Test def void testMust() {
		val r = '''
			module foo {
				prefix foo;
				namespace urn:foo;
			    leaf c5-leaf {
			      type string;
			    }
			    container x {
			    	   must "child::*[self::chapter or self::appendix]" {
			    	      description "selects the chapter and appendix children of the context node.";
			    	   }
				   list a {
				       leaf chapter { type string; }
				   }
				   list b {
				       leaf appendix { type string; }
				   }
			    	}
			}
		'''.load
		assertNoErrors(r.root)
	}
	
	@Test def void testRootRef() {
		val r = '''
			module foo {
				prefix foo;
				namespace urn:foo;
			    
			    container test1 {
			    	   must "boolean(42) + boolean(/test1) + boolean  (  'test'  )";
				   
			    	}
			}
		'''.load
		assertNoErrors(r.root)
	}
	
}