package io.typefox.yang.tests.symbols

import io.typefox.yang.tests.AbstractYangLSPTest
import org.junit.Test

class DefinitionTest extends AbstractYangLSPTest {
	
	@Test def void testDefinition() {
		testDefinition[
			model = '''
				module foo {
					typedef myType {
						type string;
					}
					leaf x {
						type myType;
					}
				}
			'''
			line = 5
			column = 7
			expectedDefinitions = '''
				MyModel.yang [[1, 1] .. [3, 2]]
			'''
		]
	}
		
	@Test def void testDefinition_01() {
		testDefinition[
			model = '''
				module foo {
					typedef myType {
						type string;
					}
					leaf x {
						type myType;
					}
				}
			'''
			line = 5
			column = 5
			expectedDefinitions = '''
			'''
		]
	}	
		
	@Test def void testDefinition_02() {
		testDefinition[
			model = '''
				module foo {
					typedef myType {
						type string;
					}
					leaf x {
						type myType;
					}
				}
			'''
			line = 1
			column = 10
			expectedDefinitions = '''
			'''
		]
	}	
}