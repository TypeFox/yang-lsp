package io.typefox.yang.tests.validation

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test
import org.junit.Assert

class DuplicateNameTest extends AbstractYangTest {
	
	@Test def void testBug75() {
		val m  = load('''
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
		val validate = this.validator.validate(m.root.eResource)
		Assert.assertTrue(validate.join('\n'), validate.empty)
	}
}