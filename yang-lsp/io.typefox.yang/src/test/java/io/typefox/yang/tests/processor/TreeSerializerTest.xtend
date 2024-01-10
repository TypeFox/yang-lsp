package io.typefox.yang.tests.processor

import io.typefox.yang.processor.YangProcessor
import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

import static org.junit.Assert.assertEquals
import io.typefox.yang.processor.DataTreeSerializer

class TreeSerializerTest extends AbstractYangTest {

	@Test
	def void testLeafSatatus() {

		val mainModule = '''
			module base-test-module {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:base-test-module;
			    prefix base-test-module;
			
			    container system {
			       leaf simple-leaf {
			         type string;
			       }
			       leaf deprecated-leaf {
			         type string;
			         config false;
			         status deprecated {
			           yexte:status-information "Some text";
			         }
			       }
			       leaf obsolete-leaf {
			         type string;
			         config false;
			         status obsolete {
			           yexte:status-information "Some text";
			         }
			       }
			    }
			}
		'''.load.root

		val processor = new YangProcessor()
		val processedData = processor.process(#[mainModule], null, null)
		val tree = new DataTreeSerializer().serialize(processedData.modules.get(0)).toString
		assertEquals('''
		module: base-test-module
		  +--rw system
		     +--rw simple-leaf?   string
		     x--ro deprecated-leaf?   string
		     o--ro obsolete-leaf?   string
		'''.toString, tree)
	}

	@Test
	def void testLeafList() {

		val mainModule = '''
			module base-test-module {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:base-test-module;
			    prefix base-test-module;
			
			    container system {
			       list sw-version {
			          key "product-number product-revision";
			          description "The administrative data.";
			          leaf product-number {
			             type string;
			             mandatory true;
			             description "Product number of the product.";
			          }
			          
			          leaf product-revision {
			             type string;
			             mandatory true;
			             description "Revision state of the product.";
			          }
			       }
			       list additional-info {
			           leaf name {
			               type string;
			               mandatory true;
			           }
			       
			           leaf value {
			               type string;
			               mandatory true;
			          }
			       }
			    }
			}
		'''.load.root

		val processor = new YangProcessor()
		val processedData = processor.process(#[mainModule], null, null)
		val tree = new DataTreeSerializer().serialize(processedData.modules.get(0)).toString
		assertEquals('''
		module: base-test-module
		  +--rw system
		     +--rw sw-version* [product-number product-revision]
		     |  +--rw product-number   string
		     |  +--rw product-revision   string
		     +--rw additional-info* []
		        +--rw name   string
		        +--rw value   string
		'''.toString, tree)
	}
	@Test
	def void testNotification() {

		val mainModule = '''
			module base-test-module {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:base-test-module;
			    prefix base-test-module;
			
			    container system {
			        notification certificate-expiration {
			            description "A notification indicating";
			            leaf expiration-date {
			               type string;
			               mandatory true;
			               description "Identifies the expiration date on the certificate.";
			            }
			        }
			    }
			}
		'''.load.root

		val processor = new YangProcessor()
		val processedData = processor.process(#[mainModule], null, null)
		val tree = new DataTreeSerializer().serialize(processedData.modules.get(0)).toString
		assertEquals('''
		module: base-test-module
		  +--rw system
		     +---n certificate-expiration
		        +-- expiration-date   string
		'''.toString, tree)
	}

}
