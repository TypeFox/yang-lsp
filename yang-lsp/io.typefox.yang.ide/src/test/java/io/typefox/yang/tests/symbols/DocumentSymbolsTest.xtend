package io.typefox.yang.tests.symbols

import io.typefox.yang.tests.AbstractYangLSPTest
import org.junit.Test

class DocumentSymbolsTest extends AbstractYangLSPTest {
	
	@Test def void testDocumentSymbols() {
		testDocumentSymbol[
			model = '''
				module foo {
					grouping x {
						
					}
					
					container bla {
						leaf test { type string; }
						container bla {
							leaf test { type string; }
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
				symbol "myIdentity" {
				    kind: 14
				    location: MyModel.yang [[12, 10] .. [12, 20]]
				}
				symbol "someFeature" {
				    kind: 14
				    location: MyModel.yang [[16, 9] .. [16, 20]]
				}
				symbol "myType" {
				    kind: 11
				    location: MyModel.yang [[13, 9] .. [13, 15]]
				}
				symbol "bla" {
				    kind: 11
				    location: MyModel.yang [[5, 11] .. [5, 14]]
				    container: "/"
				}
				symbol "test" {
				    kind: 7
				    location: MyModel.yang [[8, 8] .. [8, 12]]
				    container: "/bla/bla"
				}
				symbol "test" {
				    kind: 7
				    location: MyModel.yang [[6, 7] .. [6, 11]]
				    container: "/bla"
				}
				symbol "bla" {
				    kind: 11
				    location: MyModel.yang [[7, 12] .. [7, 15]]
				    container: "/bla"
				}
			'''
		]	
	}
}