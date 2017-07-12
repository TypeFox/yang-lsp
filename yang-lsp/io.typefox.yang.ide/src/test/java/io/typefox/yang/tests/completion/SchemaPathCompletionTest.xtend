package io.typefox.yang.tests.completion

import org.eclipse.xtext.testing.AbstractLanguageServerTest
import org.junit.Test

class SchemaPathCompletionTest extends AbstractLanguageServerTest {
	
	new() {
		super("yang")
	}
	
	@Test
	def void testTypeCompletion_01() {
		testCompletion [
		    model = '''
			    	module foo {
			    		prefix f;
			    		leaf x {
			    	        type string;
			    		}
			    		augment 
			    	}'''
			line = 5
			column = 9
			expectedCompletionItems = '''
				x -> x [[5, 9] .. [5, 9]]
				/ -> / [[5, 9] .. [5, 9]]
			'''
		]
	}
	
	@Test
	def void testTypeCompletion_02() {
		testCompletion [
		    model = '''
			    	module foo {
			    		prefix f;
			    		container bar {
			    			leaf x {
			    		        type string;
			    			}
			    		}
			    		augment "/bar/    "
			    	}'''
			line = 7
			column = 17
			expectedCompletionItems = '''
				x -> x [[7, 17] .. [7, 17]]
			'''
		]
	}
	
	@Test
	def void testTypeCompletion_03() {
		testCompletion [
		    model = '''
			    	module foo {
			    		prefix f;
			    		container bar {
			    			leaf x {
			    		        type string;
			    			}
			    		}
			    		augment "/bar/x" {
			    			container foo {
			    				leaf y {
			    					type string;
			    				}
			    			}
			    		}
			    		augment /bar/
			    	}'''
			line = 14
			column = 14
			expectedCompletionItems = '''
				x -> x [[14, 14] .. [14, 14]]
				x/foo -> x/foo [[14, 14] .. [14, 14]]
				x/foo/y -> x/foo/y [[14, 14] .. [14, 14]]
				/ -> / [[14, 13] .. [14, 14]]
			'''
		]
	}
	
}