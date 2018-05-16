package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

class Bug114Test extends AbstractYangTest {
	
	@Test 
	def void testDeviationLinking() {
		'''
			module bug_114 {
			    prefix bug_114;
			    namespace bug_114;
			    list l1 {
			        leaf lf1 {
			            type string;
			        }
			    }
			    deviation l1 {
			        deviate add {
			            unique lf1;
			        }
			    }
			}
		'''.load().assertNoErrors()
	}
	
}