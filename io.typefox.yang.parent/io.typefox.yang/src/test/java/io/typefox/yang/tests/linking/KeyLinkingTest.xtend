package io.typefox.yang.tests.linking

import org.junit.Test
import io.typefox.yang.yang.Key
import io.typefox.yang.yang.Container
import org.junit.Assert

class KeyLinkingTest extends AbstractLinkingTest {

	@Test def void testLeafLinking() {
		val m = load('''
			module deepkey {
				namespace "urn:ietf:params:xml:ns:yang:deepkey";
				prefix "d";
				list myList {
					key "bar baz";
					container foo {
						leaf bar {
							type string;
						}
					}
					container foo2 {
						leaf bar {
							type string;
						}
						leaf baz {
							type string;
						}
					}
				}
			}
		''')
		val k = m.allContents.filter(Key).head
		Assert.assertTrue(k.references.get(0).node.eContainer instanceof Container)
		Assert.assertTrue(k.references.get(1).node.eContainer instanceof Container)
	}
}