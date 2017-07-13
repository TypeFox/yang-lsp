package io.typefox.yang.tests.completion

import io.typefox.yang.tests.AbstractYangLSPTest
import org.junit.Test

class SchemaPathCompletionTest extends AbstractYangLSPTest {
	
	@Test
	def void testNodeCompletion_01() {
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
	def void testNodeCompletion_02() {
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
	def void testNodeCompletion_03() {
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
	
	@Test
	def void testNodeCompletion_04() {
		testCompletion [
			filesInScope = #{
				'other.yang' -> '''
				module other {
					container bla {}
				}
				'''
			}
		    model = '''
			    	module foo {
			    		prefix f;
			    		import other {
			    			prefix o;
			    		}
			    		augment "/o:bla" {
			    			container foo {
			    				leaf y {
			    					type string;
			    				}
			    			}
			    		}
			    		augment 
			    	}'''
			line = 12
			column = 9
			expectedCompletionItems = '''
				o:bla -> o:bla [[12, 9] .. [12, 9]]
				o:bla/foo -> o:bla/foo [[12, 9] .. [12, 9]]
				o:bla/foo/y -> o:bla/foo/y [[12, 9] .. [12, 9]]
				/ -> / [[12, 9] .. [12, 9]]
			'''
		]
	}
	
}