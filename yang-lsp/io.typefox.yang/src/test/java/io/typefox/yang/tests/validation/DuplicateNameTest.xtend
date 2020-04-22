package io.typefox.yang.tests.validation

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test
import org.junit.Assert

class DuplicateNameTest extends AbstractYangTest {
	
	@Test def void testBug75() {
		val foo = load('''
			module foo {
				yang-version 1.1;
				prefix f;
				namespace urn:foo;
				container x {
					
					action a {
						input {}
					}
					action b {
						input {}
					}
				}
			}
		''')
		val validateFoo = validator.validate(foo)
		Assert.assertTrue(validateFoo.join('\n'), validateFoo.empty)
	}
	
	@Test def void testBug147a() {
		val foo = load('''
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
			    
			    container c12 {
			        container cool {}
			    }
			}
		''')
		val foosub2 = load('''
			submodule foosub2 {
			    yang-version 1.1;
			    belongs-to foo {
			        prefix "fooprefix";
			    }
			    grouping mygrouping2 {
			        container c12 {
			        }
			    }
			    uses "fooprefix:mygrouping2" {
			        augment "c12" {
			            container augmented {}
			        }
			    }
			}
		''')
		
		val validateFoo = validator.validate(foo)
		Assert.assertTrue(validateFoo.join('\n'), validateFoo.empty)
		
		val validateFoosub2 = validator.validate(foosub2)
		Assert.assertEquals('''
			WARNING:A schema node with the name 'foo.c12' already exists. (synthetic:///__synthetic1.yang line : 7 column : 19)'''.toString,
			validateFoosub2.join('\n'))
	}
	
	@Test def void testBug147b() {
		val foo = load('''
			module foo {
			    yang-version 1.1;
			    namespace "foo:bar";
			    prefix x;
			    include foosub2;
			    
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
			    
			    container c12 {
			        container cool {}
			    }
			}
		''')
		load('''
			submodule foosub2 {
			    yang-version 1.1;
			    belongs-to foo {
			        prefix "fooprefix";
			    }
			    grouping mygrouping2 {
			        container c12 {
			        }
			    }
			    uses "fooprefix:mygrouping2" {
			        augment "c12" {
			            container augmented {}
			        }
			    }
			}
		''')
		
		val validateFoo = validator.validate(foo)
		Assert.assertEquals('''
			ERROR:A schema node with the name 'foo.c12' already exists. (synthetic:///__synthetic0.yang line : 23 column : 15)'''.toString,
			validateFoo.join('\n'))
	}

}