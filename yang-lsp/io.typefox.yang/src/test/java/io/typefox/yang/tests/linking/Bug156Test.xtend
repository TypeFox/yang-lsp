package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

class Bug156Test extends AbstractYangTest {

	@Test 
	def void testUniqueLink() {
		val mod1 = '''
			module yang-test {
			    yang-version 1.1;
			    namespace urn:rdns:org:yangster:model:yang-test;
			    prefix ygtest;
			    list l1 {
			        leaf lf1 {
			            type string;
			        }
			    }
			}
		'''.load()
		val mod2 = '''
			module bug_114_ext {
			    yang-version 1.1;
			    prefix bug_114_ext;
			    namespace bug_114_ext;
			    import yang-test {
			        prefix ygtest;
			    }
			    deviation ygtest:l1 {
			        deviate add {
			            unique lf1;
			        }
			    }
			}
		'''.load()
		mod1.assertNoErrors()
		mod2.assertNoErrors()
	}

}