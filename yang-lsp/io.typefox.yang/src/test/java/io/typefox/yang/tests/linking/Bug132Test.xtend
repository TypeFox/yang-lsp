package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.XpathNameTest
import org.junit.Test

import static org.junit.Assert.*

class Bug132Test extends AbstractYangTest {
		
	@Test 
	def void testDeviationLinking() {
		val r = '''
			module m1 { 
				prefix m;
				namespace m;
				container c1 { 
					leaf l1 { 
						type string;
					}
				} 
				grouping g1 { 
					leaf gl1 { 
						type leafref { 
							path "/m:c1/m:l1";
						}
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