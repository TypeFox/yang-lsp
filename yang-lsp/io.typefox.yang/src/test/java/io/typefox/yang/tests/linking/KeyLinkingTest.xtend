package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Key
import org.junit.Assert
import org.junit.Test

class KeyLinkingTest extends AbstractYangTest {

	@Test def void testLeafLinking() {
		val m = load('''
			module deepkey {
				namespace "urn:ietf:params:xml:ns:yang:deepkey";
				prefix "d";
				list myList {
					key "bar d:baz";
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