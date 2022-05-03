package io.typefox.yang.tests.hover

import io.typefox.yang.tests.AbstractYangLSPTest
import org.junit.Test

class HoverTest extends AbstractYangLSPTest {
	
	@Test def void testHover() {
		testHover[
			model = '''
				module foo {
					description "   Hello
					             This is super.
					                test
					             Bla blubb"
				}
			'''
			line = 0
			column = 8
			expectedHover = '''
				[[0, 7] .. [0, 10]]
				kind: markdown
				value:    Hello
				This is super.
				   test
				Bla blubb
			'''
		]
	}
	
	@Test def void testHover_02() {
		testHover[
			model = '''
				module foo {
					description "   Hello
					        This is super.
					                test
					             Bla blubb"
				}
			'''
			line = 0
			column = 8
			expectedHover = '''
				[[0, 7] .. [0, 10]]
				kind: markdown
				value:    Hello
				This is super.
				   test
				Bla blubb
			'''
		]
	}
}