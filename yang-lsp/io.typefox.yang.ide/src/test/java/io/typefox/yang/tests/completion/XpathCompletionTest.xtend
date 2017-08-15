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
	
	@Test def void testAxis_01() {
		testXpath[
			expression = 'following-sibling::'
			expected = '''
				outer -> outer [[4, 25] .. [4, 25]]
			'''
		]
	}
	
	@Test def void testAxis_02() {
		testXpath[
			expression = '//inner-leaf/ancestor::'
			expected = '''
				inner -> inner [[4, 29] .. [4, 29]]
				middle -> middle [[4, 29] .. [4, 29]]
				outer -> outer [[4, 29] .. [4, 29]]
			'''
		]
	}
	
	@Test def void testAxis_03() {
		testXpath[
			expression = '//inner-leaf/ancestor-or-self::'
			expected = '''
				inner -> inner [[4, 37] .. [4, 37]]
				inner-leaf -> inner-leaf [[4, 37] .. [4, 37]]
				middle -> middle [[4, 37] .. [4, 37]]
				outer -> outer [[4, 37] .. [4, 37]]
			'''
		]
	}
	
	@Test def void testAxis_04() {
		testXpath[
			expression = 'descendant-or-self::'
			expected = '''
				inner -> inner [[4, 26] .. [4, 26]]
				inner-leaf -> inner-leaf [[4, 26] .. [4, 26]]
				middle -> middle [[4, 26] .. [4, 26]]
				middle-leaf -> middle-leaf [[4, 26] .. [4, 26]]
				outer -> outer [[4, 26] .. [4, 26]]
				outer-leaf -> outer-leaf [[4, 26] .. [4, 26]]
			'''
		]
	}
	
	@Test def void testAxis_05() {
		testXpath[
			expression = 'descendant::'
			expected = '''
				inner -> inner [[4, 18] .. [4, 18]]
				inner-leaf -> inner-leaf [[4, 18] .. [4, 18]]
				middle -> middle [[4, 18] .. [4, 18]]
				middle-leaf -> middle-leaf [[4, 18] .. [4, 18]]
				outer-leaf -> outer-leaf [[4, 18] .. [4, 18]]
			'''
		]
	}
	
	@Test def void testAxis_06() {
		testXpath[
			expression = '//'
			expected = '''
				inner -> inner [[4, 8] .. [4, 8]]
				inner-leaf -> inner-leaf [[4, 8] .. [4, 8]]
				middle -> middle [[4, 8] .. [4, 8]]
				middle-leaf -> middle-leaf [[4, 8] .. [4, 8]]
				outer -> outer [[4, 8] .. [4, 8]]
				outer-leaf -> outer-leaf [[4, 8] .. [4, 8]]
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