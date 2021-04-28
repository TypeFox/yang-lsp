package io.typefox.yang.tests.linking

import com.google.inject.Inject
import io.typefox.yang.scoping.ScopeContextProvider
import io.typefox.yang.tests.AbstractYangTest
import org.junit.Assert
import org.junit.Test

class SchemaNodeIdentifierLinkingTest extends AbstractYangTest {

	@Inject ScopeContextProvider ctxProvider

	@Test def void testLocalAugments() {
		val m1 = load('''
			module foo {
				namespace "foo:bar";
				prefix x;
				
				grouping g2 {
					container c12 {
					}
				}
				
				uses g2 {
					 augment "c12" {
					 container c22 {}
					 leaf lm1 {
					 	type string;
					 	mandatory true;
					 	 }
					 }
				}
				
				augment "/c12/c22" {
					container c32 {}
				}
			}
		''')
		val elements = ctxProvider.getScopeContext(m1.root).schemaNodeScope.localOnly.allElements.map[name].toList.sortBy[it]
		Assert.assertEquals('''
		foo.c12
		foo.c12.foo.c22
		foo.c12.foo.c22.foo.c32
		foo.c12.foo.lm1'''.toString, elements.join(System.lineSeparator))
		this.validator.assertNoErrors(m1)
	}

	@Test def void testMultiModuleAugments() {
		load('''
			module foo {
				namespace "foo:foo";
				prefix x;
				
				grouping g2 {
					container c12 {
					}
				}
				
				uses g2 {
					 augment "c12" {
					 container c22 {}
					 leaf lm1 {
					 	type string;
					 	mandatory true;
					 	 }
					 }
				}
				
			}
		''')
		val m2 = load('''
			module bar {
				namespace "foo:bar";
				prefix y;
				import foo {
					prefix f;
				}
				
				augment "/f:c12/f:c22" {
					container c32 {}
				}
			}
		''')
		val elements = ctxProvider.getScopeContext(m2.root).schemaNodeScope.localOnly.allElements.map[name].toList.sortBy[it]
		Assert.assertEquals('''
		foo.c12.foo.c22.bar.c32'''.toString, elements.join("\n"))
		this.validator.assertNoErrors(m2)
	}

	@Test def void testImplicitCase() {
		val m1 = load('''
			module foo {
				namespace "foo:foo";
				prefix f;
				
				uses baz {
					refine "leaves" {
						default cz;
					}
					refine "leaves/cz/lupen" {
						min-elements 0;
					}
					refine "leaves/dustbin/dustbin/hoja" {
						description "Refined description of hoja";
					} 
				}
				
				grouping baz {
					choice leaves {
						case cz {
							leaf-list lupen {
								description "Base desc. of lupen";
								type string;
								max-elements 3;
							}
						}
						list dustbin {
							key hoja;
							leaf hoja {
								description "Base desc. of hoja";
								type string;
							}
						}
					}
				}
			}
		''')
		this.validator.assertNoErrors(m1.root)
	}
	
	@Test def void testConcated_issue205() {
		val m1 = load('''
			module foo {
				namespace "foo:foo";
				prefix x;
				
				grouping g2 {
					container c12 {
					}
				}
				
				uses g2 {
					 augment "c12" {
					 container c22foo-bar {}
					 leaf lm1 {
					 	type string;
					 	mandatory true;
					 	 }
					 }
				}
				
			}
		''')
		val m2 = load('''
			module bar {
			    namespace "foo:bar";
			    prefix y;
			    import foo {
			        prefix f;
			    }
			
			    augment "/f:c12/f:c22foo-bar" {
			        container c32 {
			        }
			    }
			    augment "/f:c12" + "/f:c22foo-bar" {
			        container c33 {
			        }
			    }
			    augment "/f:c12/" + "f:c22foo-bar" {
			        container c34 {
			        }
			    }
			    augment "/f:c12/f" + ":c22foo-bar" {
			        container c35 {
			        }
			    }
			    augment "/f:c12/f:c2"+ "2foo-bar" {
			        container c36a {
			        }
			    }
			    augment "/f:c12/f:"  + "c22foo-bar" {
			        container c36 {
			        }
			    }
			    augment "/f:c12/f:c22foo-" + "bar" {
			        container c38 {
			        }
			    }
			    augment "/f:c12/f:c22foo" + "-bar" {
			        container c37 {
			        }
			    }
			}
		''')
		this.validator.assertNoErrors(m1)
		this.validator.assertNoErrors(m2)
	}
}
