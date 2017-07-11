package io.typefox.yang.tests.completion

import org.eclipse.xtext.testing.AbstractLanguageServerTest
import org.junit.Test

class YangCompletionTest extends AbstractLanguageServerTest {
	
	new() {
		super("yang")
	}
	
	@Test
	def void testTypeCompletion_01() {
		testCompletion [
		    model = '''
			    	module foo {
			    		typedef myType {
			    			type string;
			    		}
			    		leaf x {
			    	        type 
			    		}
			    	}'''
			line = 5
			column = 13
			expectedCompletionItems = '''
				myType (Typedef) -> myType [[5, 13] .. [5, 13]]
			'''
		]
	}
	
	@Test
	def void testTypeCompletion_02() {
		testCompletion [
			filesInScope = #{
				'otherModule.yang' -> '''
				module otherModule {
					prefix bla;
					typedef myType {
						type string;
					}
				}
				'''
			}
		    model = '''
			    	module foo {
			    		import otherModule {
			    			prefix other;
			    		}
			    		leaf x {
			    	        type 
			    		}
			    	}'''
			line = 5
			column = 13
			expectedCompletionItems = '''
				other:myType (Typedef) -> other:myType [[5, 13] .. [5, 13]]
			'''
		]
	}
	
	@Test
	def void testTypeCompletion_03() {
		testCompletion [
			model = '''
			    	module foo {
			    		typedef A {
			    			type string;
			    		}
			    		container bla {
			    			typedef B {
			    				type string;
			    			}
			    		}
			    		leaf x {
			    	        type 
			    		}
			    	}'''
			line = 10
			column = 13
			expectedCompletionItems = '''
				A (Typedef) -> A [[10, 13] .. [10, 13]]
			'''
		]
	}
	
	@Test
	def void testTypeCompletion_04() {
		testCompletion [
			model = '''
			    	module foo {
			    		typedef A {
			    			type string;
			    		}
			    		container bla {
			    			typedef B {
			    				type string;
			    			}
			    			leaf x {
			    				type 
			    			}
			    		}
			    	}'''
			line = 9
			column = 8
			expectedCompletionItems = '''
				A (Typedef) -> A [[9, 8] .. [9, 8]]
				B (Typedef) -> B [[9, 8] .. [9, 8]]
			'''
		]
	}
}