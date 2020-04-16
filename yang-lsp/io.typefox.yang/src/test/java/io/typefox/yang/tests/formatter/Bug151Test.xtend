package io.typefox.yang.tests.formatter

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.YangFactory
import org.eclipse.xtext.resource.XtextResource
import org.junit.Test

import static org.junit.Assert.*

class Bug151Test extends AbstractYangTest {
	
	@Test
	def void testBinaryOp1() {
		assertFormatted[
			expectation = '''
				module ma {
				    yang-version 1.1;
				    prefix ma;
				    description "Test";
				    container c1 {
				        leaf l1 {
				            type string {
				                length 1..255;
				            }
				        }
				    }
				}
			'''
			toBeFormatted = '''
				module ma {
					yang-version 1.1;
					prefix ma;
					description "Test";
				    container c1 {
				         leaf l1 {
				             type string {
				                 length 1..255;
				             }
				         }
				    }
				}
			'''
			useNodeModel = false
		]
	}
	
	@Test
	def void testBinaryOp2() {
		val resource = '''
			module ma {
				yang-version 1.1;
				prefix ma;
				description "Test";
			    container c1 {
			        leaf l1 {
			            type string;
			        }
			    }
			}
		'''.load() as XtextResource

		val module = resource.contents.head as Module
		val c1 = module.substatements.filter(Container).findFirst[name == 'c1']
		val l1 = c1.substatements.filter(Leaf).findFirst[name == 'l1']
		val strType = l1.substatements.filter(Type).head
		val factory = YangFactory.eINSTANCE
		val start = factory.createLiteral()
		start.value = '1'
		val end = factory.createLiteral()
		end.value = '255'
		val bopt = factory.createBinaryOperation()
		bopt.operator = '..'
		bopt.left = start
		bopt.right = end
		val length = factory.createLength()
		length.expression = bopt
		strType.substatements.add(length)
		
		val serialized = resource.serializer.serialize(module)
		assertEquals('''
			module ma {
				yang-version 1.1;
				prefix ma;
				description "Test";
			    container c1 {
			        leaf l1 {
			            type string {
			                length 1..255;
			            }
			        }
			    }
			}
		'''.toString, serialized)
	}
	
}