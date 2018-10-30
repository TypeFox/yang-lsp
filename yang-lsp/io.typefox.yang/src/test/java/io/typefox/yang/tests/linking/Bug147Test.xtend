package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

class Bug147Test extends AbstractYangTest {

	@Test
	def void testBelongsToSubmoduleLinking() {
		'''
			module yang-dep {
			    yang-version 1.1;
			    namespace "http://yangster.org";
			    prefix ydep;
			
			    extension e1 {
			    }
			
			    rpc aio {
			       description  "action";
			       input {
			           leaf key {
			               type string;
			           }
			       }
			       output {
			           leaf value {
			              type string;
			           }
			       }
			    }
			
			    rpc ai {
			       description  "action";
			       input {
			           leaf key {
			               type string;
			           }
			       }
			    }
			
			}
			
		'''.load;
		'''
			module yangster-test {
			    yang-version 1.1;
			    namespace urn:rdns:org:yangster:model:yangster-test;
			    prefix ytest;
			    
			    import yang-dep {
			        prefix ydep;
			    }
			
			    organization 'Yangster Inc.';
			    contact yangster;
			    description 'This is a serialize test';

			    // TODO: This is a test
			    container c1 {
			        ydep:e1;
			        leaf l1 {
			            type string;
			        }
			    }

			    container c2 {
			    }
			}
		'''.load;
		'''
			submodule yangster-test-sub {
			    yang-version 1.1;
			    belongs-to yangster-test {
			        prefix ytest;
			    }
«««			    import yangster-test { prefix ytest; }
			    augment /ytest:c1 { }
			}
		'''.load.assertNoErrors;
	}

}
