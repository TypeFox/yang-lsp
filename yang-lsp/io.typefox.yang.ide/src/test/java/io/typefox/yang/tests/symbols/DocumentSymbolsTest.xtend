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

	@Test def void testGH_149() {
		testDocumentSymbol[
			model = '''
				module abc {
					yang-version 1.1;
					namespace abc;
					prefix a;
					revision 2018-10-10 {	
						a:version 4;
						a:release 5;
						a:correction 6;
					}
					revision 2018-09-10 {
						a:version 1;
						a:release 2;
						a:correction 3;
					}
					extension version {
						argument value;
					}
					extension release {
						argument value;
					}
					extension correction {
						argument value;
					}
				}
			'''
			expectedSymbols = '''
				symbol "2018-10-10" {
					kind: 8
					location: MyModel.yang [[4, 1] .. [4, 9]]
				}
				symbol "abc.version.4" {
					kind: 8
					location: MyModel.yang [[5, 12] .. [5, 13]]
					container: "2018-10-10"
				}
				symbol "abc.release.5" {
					kind: 8
					location: MyModel.yang [[6, 12] .. [6, 13]]
					container: "2018-10-10"
				}
				symbol "abc.correction.6" {
					kind: 8
					location: MyModel.yang [[7, 15] .. [7, 16]]
					container: "2018-10-10"
				}
				symbol "2018-09-10" {
					kind: 8
					location: MyModel.yang [[9, 1] .. [9, 9]]
				}
				symbol "abc.version.1" {
					kind: 8
					location: MyModel.yang [[10, 12] .. [10, 13]]
					container: "2018-09-10"
				}
				symbol "abc.release.2" {
					kind: 8
					location: MyModel.yang [[11, 12] .. [11, 13]]
					container: "2018-09-10"
				}
				symbol "abc.correction.3" {
					kind: 8
					location: MyModel.yang [[12, 15] .. [12, 16]]
					container: "2018-09-10"
				}
				symbol "version" {
					kind: 2
					location: MyModel.yang [[14, 11] .. [14, 18]]
				}
				symbol "abc.version.value" {
					kind: 8
					location: MyModel.yang [[15, 11] .. [15, 16]]
					container: "version"
				}
				symbol "release" {
					kind: 2
					location: MyModel.yang [[17, 11] .. [17, 18]]
				}
				symbol "abc.release.value" {
					kind: 8
					location: MyModel.yang [[18, 11] .. [18, 16]]
					container: "release"
				}
				symbol "correction" {
					kind: 2
					location: MyModel.yang [[20, 11] .. [20, 21]]
				}
				symbol "abc.correction.value" {
					kind: 8
					location: MyModel.yang [[21, 11] .. [21, 16]]
					container: "correction"
				}
			'''
		]
	}

}