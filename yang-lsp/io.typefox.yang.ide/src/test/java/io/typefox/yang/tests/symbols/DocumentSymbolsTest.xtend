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
					    location: MyModel.yang [[1, 5] .. [1, 13]]
					}
					symbol "input" {
					    kind: 7
					    location: MyModel.yang [[2, 2] .. [2, 7]]
					    container: "myAction"
					}
					symbol "x" {
					    kind: 13
					    location: MyModel.yang [[3, 8] .. [3, 9]]
					    container: "input"
					}
					symbol "output" {
					    kind: 9
					    location: MyModel.yang [[5, 2] .. [5, 8]]
					    container: "myAction"
					}
					symbol "x" {
					    kind: 13
					    location: MyModel.yang [[6, 8] .. [6, 9]]
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
				    location: MyModel.yang [[1, 10] .. [1, 11]]
				}
				symbol "bla" {
				    kind: 3
				    location: MyModel.yang [[5, 11] .. [5, 14]]
				}
				symbol "test" {
				    kind: 13
				    location: MyModel.yang [[6, 7] .. [6, 11]]
				    container: "bla"
				}
				symbol "bla2" {
				    kind: 3
				    location: MyModel.yang [[7, 12] .. [7, 16]]
				    container: "bla"
				}
				symbol "test2" {
				    kind: 13
				    location: MyModel.yang [[8, 8] .. [8, 13]]
				    container: "bla2"
				}
				symbol "myIdentity" {
				    kind: 14
				    location: MyModel.yang [[12, 10] .. [12, 20]]
				}
				symbol "myType" {
				    kind: 10
				    location: MyModel.yang [[13, 9] .. [13, 15]]
				}
				symbol "someFeature" {
				    kind: 17
				    location: MyModel.yang [[16, 9] .. [16, 20]]
				}
			'''
		]	
	}
}