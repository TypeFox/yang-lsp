package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

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
}