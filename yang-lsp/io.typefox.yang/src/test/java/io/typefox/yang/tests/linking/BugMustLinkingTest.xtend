package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.XpathNameTest
import org.junit.Test

import static org.junit.Assert.*

class BugMustLinkingTest extends AbstractYangTest {
		
	@Test 
	def void testMustLinking() {
		val r = '''
			module bug_mustlinking {
			    prefix bug_mustlinking;
			    namespace bug_mustlinking;
			
			    container c1 {
			        choice co {
			            case cz1 {
			                container c2 {
			                    uses testgrp {
			                        refine a {
			                            must g1;
			                        }
			                    }
			                }
			            }
			        }
			    }
			
			    grouping testgrp {
			      list a {
			        leaf g1 { type string; }
			      }
			   }
			}
		'''.load()
		r.assertNoErrors()
		r.allContents.filter(XpathNameTest).forEach [
			assertFalse(ref.eIsProxy)
		]
	}
}