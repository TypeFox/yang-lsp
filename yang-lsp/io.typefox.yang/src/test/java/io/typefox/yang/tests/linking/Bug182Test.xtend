package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

class Bug182Test extends AbstractYangTest {
	
	@Test
	def void test() {
		'''
			module certm-ext-mynode {
				yang-version 1.1;
				namespace "urn:rdns:com:certm:oammodel:certm-ext-mynode";
				prefix certmmynode;
			
				contact "eyoshao";
				description
				"test model for null pointer exception";
			
				revision "2019-04-20" {
				description
					"test model for null pointer exception";
				}
			
			    container certm {
			        description
					"The top class of the Certificate Management model.
					Certificate management encompasses management of node credentials and trusted certificates.";	
				}
			
			    extension obm-is-root {
			        description
			      "This is a root node.";
			    }	
			
				deviation certm {
					deviate add {
						certmmynode:obm-is-root;
					}
				}
			}
		'''.load().assertNoErrors()
	}

}