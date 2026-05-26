package io.typefox.yang.tests.validation

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Assert
import org.junit.Test

class FeatureToggleTest extends AbstractYangTest {

	@Test def void testValidationOnByDefault() {
		val m = load('''
			module foo {
				namespace urn:foo;
				prefix foo;
				revision 2999-99-99;
			}
		''')
		val issues = validator.validate(m.root)
		Assert.assertFalse('Expected validation issues', issues.isEmpty)
	}
}
