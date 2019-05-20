package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test
import org.eclipse.xtext.EcoreUtil2
import io.typefox.yang.yang.Uses

import static io.typefox.yang.validation.IssueCodes.*

class GroupingLinkingTest extends AbstractYangTest {
	
	@Test def void testNestedUse() {
		val m = load('''
			module foo {
				namespace "foo:bar";
				prefix foo;
				
				uses A;
				
				grouping A {
					list mylist {
						uses B;
					}
				}
				
				grouping B {
					leaf myLeaf {
						type string;
					}
				}
				
			}
		''')
		assertNoErrors(m.root)
	}
	
	@Test def void testNestedUse_02() {
		val m = load('''
			module foo {
				namespace "foo:bar";
				prefix foo;
				
				uses A;
				
				grouping A {
					list mylist {
						uses B;
					}
					grouping B {
						leaf myLeaf {
							type string;
						}
					}
				}
			}
		''')
		assertNoErrors(m.root)
	}
	
	@Test def void testNestedUse_03() {
		val m = load('''
			module yt5 {
			
			    namespace "urn:ietf:params:xml:ns:yang:yt5";
			    prefix "yt5";
			
				uses AA;
				grouping AA {
				    container b {
				        uses AAA;
				        grouping AAA {
				        		uses AAAA;
				        }
				    }
				
				    grouping AAAA {
				        container bbbb {
				        }
				    }
				}
			}
		''')
		assertNoErrors(m.root)
	}
	
	@Test def void testUsesGrpSelf() {
		val it = load('''
			module yt6 {
			
			    namespace "urn:ietf:params:xml:ns:yang:yt6";
			    prefix "yt6";
			
				grouping AA {
					leaf a {
						type string;
					}
				    list b {
				        uses AA;
				    }
				}
			}
		''')
		assertError(EcoreUtil2.getAllContentsOfType(root, Uses).head, GROUPING_REFERENCE_TO_ITSELF)
	}
}