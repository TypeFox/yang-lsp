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
				/x -> /x [[5, 9] .. [5, 9]]
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
			    		augment "/bar/"
			    	}'''
			line = 7
			column = 15
			expectedCompletionItems = '''
				x -> x [[7, 15] .. [7, 15]]
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
				/o:bla -> /o:bla [[12, 9] .. [12, 9]]
				/o:bla/foo -> /o:bla/foo [[12, 9] .. [12, 9]]
				/o:bla/foo/y -> /o:bla/foo/y [[12, 9] .. [12, 9]]
			'''
		]
	}
	
	@Test def void testRelativeCompletion() {
		testCompletion [
			model = '''
				module augtest {
				  namespace "http://example.com/augtest";
				  prefix "at";
				  grouping foobar {
				    container outer {
				      container inner {
				        leaf foo {
				          type uint8;
				        }
				      }
				    }
				  }
				  rpc agoj {
				    input {
				      uses foobar {
				        augment "outer/inner" {
				          when "foo!=42";
				          leaf bar {
				            type string;
				          }
				        }
				      }
				    }
				  }
				}
			'''
			line = 15
			column = 17
			expectedCompletionItems = '''
				outer -> outer [[15, 17] .. [15, 17]]
				outer/inner -> outer/inner [[15, 17] .. [15, 17]]
				outer/inner/bar -> outer/inner/bar [[15, 17] .. [15, 17]]
				outer/inner/foo -> outer/inner/foo [[15, 17] .. [15, 17]]
				/agoj -> /agoj [[15, 17] .. [15, 17]]
				/agoj/input -> /agoj/input [[15, 17] .. [15, 17]]
				/agoj/input/outer -> /agoj/input/outer [[15, 17] .. [15, 17]]
				/agoj/input/outer/inner -> /agoj/input/outer/inner [[15, 17] .. [15, 17]]
				/agoj/input/outer/inner/bar -> /agoj/input/outer/inner/bar [[15, 17] .. [15, 17]]
				/agoj/input/outer/inner/foo -> /agoj/input/outer/inner/foo [[15, 17] .. [15, 17]]
				/agoj/output -> /agoj/output [[15, 17] .. [15, 17]]
			'''
		]
	}
	
}