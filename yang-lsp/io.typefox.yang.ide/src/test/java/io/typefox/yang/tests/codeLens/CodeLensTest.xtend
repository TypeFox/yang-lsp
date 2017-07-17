package io.typefox.yang.tests.codeLens

import io.typefox.yang.tests.AbstractYangLSPTest
import org.junit.Test

class CodeLensTest extends AbstractYangLSPTest {
	
	@Test def void testCodeLens() {
		testCodeLens [
			model = '''
					module foo {
						prefix f;
						leaf x {
							type string;
						}
						augment x {
						}
					}
			'''
			expectedCodeLensItems = '''
				1 reference [[2, 1] .. [2, 5]]
			'''
		]
	}
}