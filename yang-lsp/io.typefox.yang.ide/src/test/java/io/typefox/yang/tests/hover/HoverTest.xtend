package io.typefox.yang.tests.hover

import io.typefox.yang.tests.AbstractYangLSPTest
import org.junit.Test

class HoverTest extends AbstractYangLSPTest {
	
	@Test def void testHover() {
		testHover[
			model = '''
				module foo {
					description "Hello
					             This is super.
					             
					             Bla blubb"
				}
			'''
			line = 0
			column = 8
			expectedHover = '''
				[[0, 7] .. [0, 10]]
				Hello
				This is super.
				
				Bla blubb
			'''
		]
	}
}