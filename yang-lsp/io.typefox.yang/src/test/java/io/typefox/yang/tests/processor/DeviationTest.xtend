package io.typefox.yang.tests.processor

import io.typefox.yang.processor.JsonSerializer
import io.typefox.yang.processor.YangProcessor
import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

import static org.junit.Assert.assertEquals

class DeviationTest extends AbstractYangTest {

	@Test
	def void testDeviationProcessing() {

		val mainModule = '''
			module base-test-module {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:base-test-module;
			    prefix base-test-module;
			
			    container system {
			        must "daytime or time";
			        must "user";
			
			        container daytime {
			            leaf date {
			                type string;
			            }
			        }
			
			        leaf time {
			            type string;
			        }
			
			        container user {
			            leaf type {
			                type string {
			                    length "1..10";
			                }
			            }
			        }
			        leaf-list name-server {
			            type string;
			            max-elements 10;
			        }
			    }
			}
		'''.load().root

		val deviateModule = '''
			 module example-deviations {
			 yang-version 1.1;
			 namespace "urn:example:deviations";
			 prefix md;
			
			    import base-test-module {
			        prefix base;
			    }
			
			    deviation /base:system/base:daytime {
			        // server  does not support the "daytime" service
			        deviate not-supported;
			    }
			
			    deviation /base:system/base:user/base:type {
			        deviate add {
			            // the users are admin by default
			            default "admin";
			        }
			    }
			
			    deviation /base:system/base:name-server {
			        deviate replace {
			            // the server limits the number of name servers to 3
			            max-elements 3;
			        }
			    }
			
			    deviation /base:system {
			        deviate delete {
			            // remove this "must" constraint
			            must "daytime or time";
			        }
			        deviate add {
			            // add this "must" constraint
			            must "time";
			        }
			    }
			}
		'''.load().root
		mainModule.assertNoErrors;
		deviateModule.assertNoErrors;
		val processor = new YangProcessor()
		val processedData = processor.process(#[mainModule, deviateModule], null, null)

		var asJson = new JsonSerializer().serialize(processedData.getModules.head)
		assertEquals('''
		{
		  "children": [
		    {
		      "elementKind": "Container",
		      "accessKind": "rw",
		      "cardinality": "not_set",
		      "mustConstraint": [
		        "user",
		        "time"
		      ],
		      "children": [
		        {
		          "elementKind": "Leaf",
		          "type": {
		            "name": "string"
		          },
		          "accessKind": "rw",
		          "cardinality": "optional",
		          "id": {
		            "name": "time"
		          }
		        },
		        {
		          "elementKind": "Container",
		          "accessKind": "rw",
		          "cardinality": "not_set",
		          "children": [
		            {
		              "elementKind": "Leaf",
		              "type": {
		                "name": "string"
		              },
		              "accessKind": "rw",
		              "cardinality": "optional",
		              "defaultValue": "admin",
		              "id": {
		                "name": "type"
		              }
		            }
		          ],
		          "id": {
		            "name": "user"
		          }
		        },
		        {
		          "elementKind": "LeafList",
		          "type": {
		            "name": "string"
		          },
		          "accessKind": "rw",
		          "cardinality": "many",
		          "maxElements": "3",
		          "id": {
		            "name": "name-server"
		          }
		        }
		      ],
		      "id": {
		        "name": "system"
		      }
		    }
		  ],
		  "id": {
		    "name": "base-test-module",
		    "prefix": "base-test-module"
		  }
		}'''.toString(), asJson.toString())
	}

	@Test
	def void testDeviationErrorsProcessing() {

		val mainModule = '''
			module base-test-module {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:base-test-module;
			    prefix base-test-module;
			
			    container system {
			        must "user";
			
			        container daytime {
			            leaf date {
			                type string;
			            }
			        }
			
			        leaf time {
			            type string;
			        }
			
			        container user {
			            leaf type {
			                default "normal"; // error on "add" cause already exists
			                type string {
			                    length "1..10";
			                }
			            }
			        }
			        leaf-list name-server {
			            type string;
			        }
			    }
			}
		'''.load().root

		val deviateModule = '''
			module example-deviations {
			yang-version 1.1;
			namespace "urn:example:deviations";
			prefix md;
			
			    import base-test-module {
			        prefix base;
			    }
			
			    deviation /base:system/base:daytime {
			        // server  does not support the "daytime" service
			        deviate not-supported;
			    }
			
			    deviation /base:system/base:user/base:type {
			        deviate add {
			            // the users are admin by default
			            default "admin";
			        }
			    }
			
			    deviation /base:system/base:name-server {
			        deviate replace {
			            // the server limits the number of name servers to 3
			            max-elements 3;
			        }
			    }
			
			    deviation /base:system {
			        deviate delete {
			            // remove this "must" constraint
			            must "daytime or time";
			        }
			        deviate add {
			            // add this "must" constraint
			            must "time";
			        }
			    }
			
			    // missing target node
			    deviation /base:system/base:missing {
			        deviate not-supported;
			    }
			}
		'''.load().root

		val processor = new YangProcessor()
		val processedData = processor.process(#[mainModule, deviateModule], null, null)
		assertEquals(4, processedData.messages.size)
		assertEquals('__synthetic1.yang:18: Error: the "default" property already exists in node "base-test-module:system:user:type"',
			processedData.messages.head.toString)
		assertEquals('__synthetic1.yang:25: Error: the "max-elements" property does not exist in node "base-test-module:system:name-server"',
			processedData.messages.get(1).toString)
		assertEquals('__synthetic1.yang:32: Error: the "must" property does not exist in node "base-test-module:system"',
			processedData.messages.get(2).toString)
		assertEquals('__synthetic1.yang:41: Error: Deviation target node not found',
			processedData.messages.get(3).toString)
	}

}
