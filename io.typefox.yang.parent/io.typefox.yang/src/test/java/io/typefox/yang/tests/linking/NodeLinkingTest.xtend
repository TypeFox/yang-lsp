package io.typefox.yang.tests.linking

import org.junit.Test
import io.typefox.yang.validation.IssueCodes

class NodeLinkingTest extends AbstractLinkingTest {
	
			
	@Test def void testDuplicateNodeNames_01() {
		val m2 = load('''
			module myModule {
				container foo {
				}
				container foo {
				}
			}
		''')
		assertError(m2.root.subStatements.get(1), IssueCodes.DUPLICATE_NAME)
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
		assertError(m2.root.subStatements.head.subStatements.head, IssueCodes.DUPLICATE_NAME)
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
		assertError(m2.root.subStatements.head.subStatements.head.subStatements.head, IssueCodes.DUPLICATE_NAME)
	}

}