package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Key
import io.typefox.yang.yang.List
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
					leaf bar {
						type string;
					}
					container foo {
					}
					leaf baz {
						type string;
					}
					container foo2 {
						leaf bar {
							type string;
						}
					}
				}
			}
		''')
		val k = m.root.eAllContents.filter(Key).head
		Assert.assertTrue(k.references.get(0).node.eContainer instanceof List)
		Assert.assertTrue(k.references.get(1).node.eContainer instanceof List)
	}
	
	@Test def void testLeafLinking_02() {
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
						leaf baz {
							type string;
						}
						leaf bar {
							type string;
						}
					}
				}
			}
		''')
		val k = m.root.eAllContents.filter(Key).head
		Assert.assertTrue(k.references.get(0).node.eIsProxy)
		Assert.assertTrue(k.references.get(1).node.eIsProxy)
	}
}