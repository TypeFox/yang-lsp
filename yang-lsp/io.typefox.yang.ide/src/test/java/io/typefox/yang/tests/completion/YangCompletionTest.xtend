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
				binary -> binary [[5, 13] .. [5, 13]]
				bits -> bits [[5, 13] .. [5, 13]]
				boolean -> boolean [[5, 13] .. [5, 13]]
				decimal64 -> decimal64 [[5, 13] .. [5, 13]]
				empty -> empty [[5, 13] .. [5, 13]]
				enumeration -> enumeration [[5, 13] .. [5, 13]]
				identityref -> identityref [[5, 13] .. [5, 13]]
				instance-identifier -> instance-identifier [[5, 13] .. [5, 13]]
				int16 -> int16 [[5, 13] .. [5, 13]]
				int32 -> int32 [[5, 13] .. [5, 13]]
				int64 -> int64 [[5, 13] .. [5, 13]]
				int8 -> int8 [[5, 13] .. [5, 13]]
				leafref -> leafref [[5, 13] .. [5, 13]]
				string -> string [[5, 13] .. [5, 13]]
				uint16 -> uint16 [[5, 13] .. [5, 13]]
				uint32 -> uint32 [[5, 13] .. [5, 13]]
				uint64 -> uint64 [[5, 13] .. [5, 13]]
				uint8 -> uint8 [[5, 13] .. [5, 13]]
				union -> union [[5, 13] .. [5, 13]]
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
				binary -> binary [[5, 13] .. [5, 13]]
				bits -> bits [[5, 13] .. [5, 13]]
				boolean -> boolean [[5, 13] .. [5, 13]]
				decimal64 -> decimal64 [[5, 13] .. [5, 13]]
				empty -> empty [[5, 13] .. [5, 13]]
				enumeration -> enumeration [[5, 13] .. [5, 13]]
				identityref -> identityref [[5, 13] .. [5, 13]]
				instance-identifier -> instance-identifier [[5, 13] .. [5, 13]]
				int16 -> int16 [[5, 13] .. [5, 13]]
				int32 -> int32 [[5, 13] .. [5, 13]]
				int64 -> int64 [[5, 13] .. [5, 13]]
				int8 -> int8 [[5, 13] .. [5, 13]]
				leafref -> leafref [[5, 13] .. [5, 13]]
				string -> string [[5, 13] .. [5, 13]]
				uint16 -> uint16 [[5, 13] .. [5, 13]]
				uint32 -> uint32 [[5, 13] .. [5, 13]]
				uint64 -> uint64 [[5, 13] .. [5, 13]]
				uint8 -> uint8 [[5, 13] .. [5, 13]]
				union -> union [[5, 13] .. [5, 13]]
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
				binary -> binary [[10, 13] .. [10, 13]]
				bits -> bits [[10, 13] .. [10, 13]]
				boolean -> boolean [[10, 13] .. [10, 13]]
				decimal64 -> decimal64 [[10, 13] .. [10, 13]]
				empty -> empty [[10, 13] .. [10, 13]]
				enumeration -> enumeration [[10, 13] .. [10, 13]]
				identityref -> identityref [[10, 13] .. [10, 13]]
				instance-identifier -> instance-identifier [[10, 13] .. [10, 13]]
				int16 -> int16 [[10, 13] .. [10, 13]]
				int32 -> int32 [[10, 13] .. [10, 13]]
				int64 -> int64 [[10, 13] .. [10, 13]]
				int8 -> int8 [[10, 13] .. [10, 13]]
				leafref -> leafref [[10, 13] .. [10, 13]]
				string -> string [[10, 13] .. [10, 13]]
				uint16 -> uint16 [[10, 13] .. [10, 13]]
				uint32 -> uint32 [[10, 13] .. [10, 13]]
				uint64 -> uint64 [[10, 13] .. [10, 13]]
				uint8 -> uint8 [[10, 13] .. [10, 13]]
				union -> union [[10, 13] .. [10, 13]]
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
				binary -> binary [[9, 8] .. [9, 8]]
				bits -> bits [[9, 8] .. [9, 8]]
				boolean -> boolean [[9, 8] .. [9, 8]]
				decimal64 -> decimal64 [[9, 8] .. [9, 8]]
				empty -> empty [[9, 8] .. [9, 8]]
				enumeration -> enumeration [[9, 8] .. [9, 8]]
				identityref -> identityref [[9, 8] .. [9, 8]]
				instance-identifier -> instance-identifier [[9, 8] .. [9, 8]]
				int16 -> int16 [[9, 8] .. [9, 8]]
				int32 -> int32 [[9, 8] .. [9, 8]]
				int64 -> int64 [[9, 8] .. [9, 8]]
				int8 -> int8 [[9, 8] .. [9, 8]]
				leafref -> leafref [[9, 8] .. [9, 8]]
				string -> string [[9, 8] .. [9, 8]]
				uint16 -> uint16 [[9, 8] .. [9, 8]]
				uint32 -> uint32 [[9, 8] .. [9, 8]]
				uint64 -> uint64 [[9, 8] .. [9, 8]]
				uint8 -> uint8 [[9, 8] .. [9, 8]]
				union -> union [[9, 8] .. [9, 8]]
			'''
		]
	}
	
	@Test def void testGroupingCompletion_01() {
		testCompletion [
			model = '''
			    	module foo {
			    		grouping A {
			    			container a{}
			    		}
			    		uses 
			    	}'''
			line = 4
			column = 6
			expectedCompletionItems = '''
				A (Grouping) -> A [[4, 6] .. [4, 6]]
			'''
		]
	}
	
	@Test def void testGroupingCompletion_02() {
		testCompletion [
			filesInScope = #{
				'submodule.yang' -> '''
					submodule subm {
						belongs-to foo {
							prefix foo;
						}
						grouping A {
							container a{}
						}
					}
				'''
			}
			model = '''
			    	module foo {
			    		prefix f;
			    		include subm;
			    		uses 
			    	}'''
			line = 3
			column = 6
			expectedCompletionItems = '''
				A (Grouping) -> A [[3, 6] .. [3, 6]]
			'''
		]
	}
	
	@Test def void testImportedGroupingCompletion() {
		testCompletion [
			filesInScope = #{
				'otherModule.yang' -> '''
					module otherModule {
						prefix other;
						grouping A {
							container a{}
						}
					}
				'''
			}
			model = '''
			    	module foo {
			    		prefix f;
			    		import otherModule {
			    			prefix bla;
			    		}
			    		uses 
			    	}'''
			line = 5
			column = 6
			expectedCompletionItems = '''
				bla:A (Grouping) -> bla:A [[5, 6] .. [5, 6]]
			'''
		]
	}
}