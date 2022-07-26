package io.typefox.yang.tests.serializer

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.Path
import io.typefox.yang.yang.Type
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.EmfFormatter
import org.junit.Test

import static org.junit.Assert.assertEquals

class Bug224Test extends AbstractYangTest {
	val main_module = '''
		module test-module {
		    yang-version 1.1;
		    namespace urn:ietf:params:xml:ns:yang:test-module;
		    prefix ts-mod;
		
		    include sub-module0;
		    include sub-module1;
		    include sub-module2;
		}
	'''

	val augment_sub0 = '''
		submodule sub-module0 {
		    yang-version 1.1;
		    belongs-to test-module {
		        prefix ts-mod;
		    }
		    container "container" {
		    }
		}
	'''
	val augment_sub1 = '''
		submodule sub-module1 {
		    yang-version 1.1;
		    belongs-to test-module {
		        prefix ts-mod;
		    }
		    include "sub-module0";
		    augment /container {
		        leaf leaf_from_sub1 {
		            type int64;
		        }
		    }
		}
	'''
	val augment_sub2 = '''
		submodule sub-module2 {
		    yang-version 1.1;
		    belongs-to test-module {
		        prefix ts-mod;
		    }
		    include sub-module0;
		    // Normally need to import in order to reference augments from sub-module1
		    // But we should still be able to serialize
		    //include sub-module1;
		
		    augment /container {
		        leaf leaf_from_sub2 {
		            type leafref {
		                path "/container/leaf_from_sub1";
		            }
		        }
		    }
		}
		
	'''

	@Test
	def void testBelongsToIncludeLinking_01() {
		// path doesn't matter but better for debugging
		val superRes = main_module.load('super')
		val sub0Res = augment_sub0.load('sub0')
		val sub1Res = augment_sub1.load('sub1')
		val sub2Res = augment_sub2.load('sub2')
		superRes.assertNoErrors;
		sub0Res.assertNoErrors;
		sub1Res.assertNoErrors;
		sub2Res.assertNoErrors;

		val submodule2 = sub2Res.root
		val augment = submodule2.substatements.filter(Augment)?.head
		val augmentsLeafType = augment.substatements.head.substatements.head as Type
		val expectedResolvedPath = '''
		XpathLocation {
		    cref XpathExpression target AbsolutePath {
		        cref XpathStep step XpathStep {
		            cref XpathNodeTest node XpathNameTest {
		                ref SchemaNode ref ref: Container@synthetic://sub0/__synthetic1.yang#//@substatements.2
		            }
		        }
		    }
		    cref XpathStep step XpathStep {
		        cref XpathNodeTest node XpathNameTest {
		            ref SchemaNode ref ref: Leaf@synthetic://sub1/__synthetic2.yang#//@substatements.3/@substatements.0
		        }
		    }
		}'''
		assertEquals(expectedResolvedPath,
			EmfFormatter.objToStr((augmentsLeafType.substatements.head as Path).reference))

		val serializer = (sub2Res as XtextResource).getSerializer();
		val result = serializer.serialize(submodule2, SaveOptions.newBuilder().format().getOptions())
		assertEquals('''
			submodule sub-module2 {
			    yang-version 1.1;
			    belongs-to test-module {
			        prefix ts-mod;
			    }
			    include sub-module0;
			    // Normally need to import in order to reference augments from sub-module1
			    // But we should still be able to serialize
			    // include sub-module1;
			    augment /container {
			        leaf leaf_from_sub2 {
			            type leafref {
			                path "/container/leaf_from_sub1";
			            }
			        }
			    }
			}
			
		'''.toString, result)
	}

}
