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
				    kind: 7
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