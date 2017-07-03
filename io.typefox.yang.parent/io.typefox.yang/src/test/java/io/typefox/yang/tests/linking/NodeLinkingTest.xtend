package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.validation.IssueCodes
import org.junit.Test

class NodeLinkingTest extends AbstractYangTest {
	
			
	@Test def void testDuplicateNodeNames_01() {
		val m2 = load('''
			module myModule {
				container foo {
				}
				container foo {
				}
			}
		''')
		assertError(m2.root.substatements.get(1), IssueCodes.DUPLICATE_NAME)
	}
	
	@Test def void testDuplicateNodeNames_02() {
		val m2 = load('''
			module myModule {
				container foo {
					container foo {
					}
				}
			}
		''')
		assertError(m2.root.substatements.head.substatements.head, IssueCodes.DUPLICATE_NAME)
	}
	
	@Test def void testDuplicateNodeNames_03() {
		val m2 = load('''
			module myModule {
				container foo {
					container bar {
						container foo {
						}
					}
				}
			}
		''')
		assertError(m2.root.substatements.head.substatements.head.substatements.head, IssueCodes.DUPLICATE_NAME)
	}

}