package io.typefox.yang.tests.completion

import io.typefox.yang.tests.AbstractYangLSPTest
import org.junit.Test

class XpathCompletionTest extends AbstractYangLSPTest {
	
	private def void testXpath((XpathTest)=>void cb) {
		val d = new XpathTest
		cb.apply(d)
		var cursorIdx = d.expression.indexOf('|')
		if (cursorIdx >= 0) {
			d.expression = d.expression.substring(0, cursorIdx) + d.expression.substring(cursorIdx+1)	
		} else {
			cursorIdx = d.expression.length
		}
		val cursor = cursorIdx
		val fullModel = '''
			module foo {
				prefix foo;
				namespace urn:foo;
				container outer {
			when "«d.expression»";
					container middle {
						container inner {
							leaf inner-leaf {
								type string;
							}
						}
						leaf middle-leaf {
							type string;
						}
					}
					leaf outer-leaf {
						type string;
					}
				}
			}
		'''
		testCompletion[
			model = fullModel
			line = 4
			column = 6 + cursor
			expectedCompletionItems = d.expected.toString
		]
	}
	
	static class XpathTest {
		String expression
		CharSequence expected
	}
	
	@Test def void testAbsolute() {
		testXpath[
			expression = '/'
			expected = '''
				outer -> outer [[4, 7] .. [4, 7]]
			'''
		]
	}
	
	@Test def void testRelative() {
		testXpath[
			expression = ''
			expected = '''
				middle -> middle [[4, 6] .. [4, 6]]
				outer-leaf -> outer-leaf [[4, 6] .. [4, 6]]
			'''
		]
	}
	
	@Test def void testRelative_01() {
		testXpath[
			expression = './'
			expected = '''
				middle -> middle [[4, 8] .. [4, 8]]
				outer-leaf -> outer-leaf [[4, 8] .. [4, 8]]
			'''
		]
	}
	
	@Test def void testFilter() {
		testXpath[
			expression = './middle[middle-leaf != current()/|]'
			expected = '''
				middle -> middle [[4, 40] .. [4, 40]]
				outer-leaf -> outer-leaf [[4, 40] .. [4, 40]]
			'''
		]
	}
	
	@Test def void testFilter_01() {
		testXpath[
			expression = './middle[|]'
			expected = '''
				inner -> inner [[4, 15] .. [4, 15]]
				middle-leaf -> middle-leaf [[4, 15] .. [4, 15]]
			'''
		]
	}
	
	@Test def void testFunctionProposalsNeedPrefix() {
		testXpath[
			expression = './middle[c|]'
			expected = '''
				ceiling(number) -> ceiling(${number}) [[4, 15] .. [4, 16]]
				concat(string, string, string) -> concat(${string}, ${string}, ${string}) [[4, 15] .. [4, 16]]
				contains(string, string) -> contains(${string}, ${string}) [[4, 15] .. [4, 16]]
				count(node_set) -> count(${node_set}) [[4, 15] .. [4, 16]]
				current() -> current() [[4, 15] .. [4, 16]]
			'''
		]
	}
}