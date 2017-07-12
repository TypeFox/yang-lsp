package io.typefox.yang.tests.completion

import org.eclipse.xtext.testing.AbstractLanguageServerTest
import org.junit.Test

class StatementCompletionTest extends AbstractLanguageServerTest {
	
	new() {
		super('yang')
	}
	
	@Test def void testStatement() {
		testCompletion [
			model = '''
			    	m'''
			line = 0
			column = 1
			expectedCompletionItems = '''
				module -> module [[0, 0] .. [0, 1]]
			'''
		]
	}
	
	@Test def void testStatement_02() {
		testCompletion [
			model = '''
			    	mo'''
			line = 0
			column = 2
			expectedCompletionItems = '''
				module -> module [[0, 0] .. [0, 2]]
			'''
		]
	}
}