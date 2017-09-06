package io.typefox.yang.tests.symbols

import io.typefox.yang.tests.AbstractYangLSPTest
import org.junit.Test

class DocumentSymbolsTest extends AbstractYangLSPTest {
	
	@Test def void testEmpty() {		
		testDocumentSymbol[
	            model = '''
	            '''
	    ]
	}
	
	@Test def void testInputOutput() {		
		testDocumentSymbol[
            model = '''
					module foo {
						rpc myAction {
							input {
								leaf x { type string; }
							}
							output {
								leaf x { type string; }
							}
						}
					}
            '''
            expectedSymbols = '''
            		symbol "myAction" {
            		    kind: 6
            		    location: MyModel.yang [[1, 1] .. [8, 2]]
            		}
            		symbol "input" {
            		    kind: 7
            		    location: MyModel.yang [[2, 2] .. [4, 3]]
            		    container: "myAction"
            		}
            		symbol "x" {
            		    kind: 8
            		    location: MyModel.yang [[3, 3] .. [3, 26]]
            		    container: "input"
            		}
            		symbol "output" {
            		    kind: 9
            		    location: MyModel.yang [[5, 2] .. [7, 3]]
            		    container: "myAction"
            		}
            		symbol "x" {
            		    kind: 8
            		    location: MyModel.yang [[6, 3] .. [6, 26]]
            		    container: "output"
            		}
            '''
	    ]
	}
	
	@Test def void testDocumentSymbols() {
		testDocumentSymbol[
			model = '''
				module foo {
					grouping x {
						
					}
					
					container bla {
						leaf test { type string; }
						container bla2 {
							leaf test2 { type string; }
						}
					}
					
					identity myIdentity;
					typedef myType {
						type string;
					}
					feature someFeature;
				}
			'''
			expectedSymbols = '''
				symbol "x" {
				    kind: 5
				    location: MyModel.yang [[1, 1] .. [3, 2]]
				}
				symbol "bla" {
				    kind: 8
				    location: MyModel.yang [[5, 1] .. [10, 2]]
				}
				symbol "test" {
				    kind: 8
				    location: MyModel.yang [[6, 2] .. [6, 28]]
				    container: "bla"
				}
				symbol "bla2" {
				    kind: 8
				    location: MyModel.yang [[7, 2] .. [9, 3]]
				    container: "bla"
				}
				symbol "test2" {
				    kind: 8
				    location: MyModel.yang [[8, 3] .. [8, 30]]
				    container: "bla2"
				}
				symbol "myIdentity" {
				    kind: 14
				    location: MyModel.yang [[12, 1] .. [12, 21]]
				}
				symbol "myType" {
				    kind: 10
				    location: MyModel.yang [[13, 1] .. [15, 2]]
				}
				symbol "someFeature" {
				    kind: 17
				    location: MyModel.yang [[16, 1] .. [16, 21]]
				}
			'''
		]	
	}
}