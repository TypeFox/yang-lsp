package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

class FeatureLinkingTest extends AbstractYangTest {

	@Test def void testLinking() {
		val m = load('''
			module u {
			  yang-version 1.1;
			  namespace urn:u;
			  prefix u;
			
			  feature foo;
			  feature bar;
			
			  container a {
			    if-feature "foo and not bar";
			  }
			
			}
		''')
		assertNoErrors(m.root)
	}	
}