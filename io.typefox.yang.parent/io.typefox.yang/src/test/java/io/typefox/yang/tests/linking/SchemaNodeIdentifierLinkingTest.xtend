package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test
import io.typefox.yang.resource.ScopeContext
import io.typefox.yang.resource.ScopeContext.YangScopeKind
import org.junit.Assert

class SchemaNodeIdentifierLinkingTest extends AbstractYangTest {
	
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
		val elements = ScopeContext.findInEmfObject(m1.root).getLocal(YangScopeKind.NODE).allElements.map[name].toList.sortBy[it]
		Assert.assertEquals('''
			%groupings.g2
			%groupings.g2.foo.c12
			foo.c12
			foo.c12.foo.c22
			foo.c12.foo.c22.foo.c32
			foo.c12.foo.lm1'''.toString, 
			elements.join("\n"))
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
		val elements = ScopeContext.findInEmfObject(m2.root).getLocal(YangScopeKind.NODE).allElements.map[name].toList.sortBy[it]
		Assert.assertEquals('''
			foo.c12.foo.c22.bar.c32'''.toString, 
			elements.join("\n"))
		this.validator.assertNoErrors(m2)
	}
}