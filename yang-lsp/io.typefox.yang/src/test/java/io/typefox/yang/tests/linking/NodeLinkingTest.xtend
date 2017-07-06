package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.validation.IssueCodes
import org.junit.Test

class NodeLinkingTest extends AbstractYangTest {
	
			
	@Test def void testDuplicateNodeNames_01() {
		val m2 = load('''
			module myModule {
				container foo {
				}
				container foo {
				}
			}
		''')
		assertError(m2.root.substatements.get(1), IssueCodes.DUPLICATE_NAME)
	}
	
	@Test def void testDuplicateNodeNames_02() {
		val m2 = load('''
			module myModule {
				container foo {
					container foo {
					}
				}
			}
		''')
		this.validator.assertNoErrors(m2.root, IssueCodes.DUPLICATE_NAME)
	}
	
	@Test def void testDuplicateNodeNames_03() {
		val m2 = load('''
			module myModule {
				container foo {
					container bar {
						container foo {
						}
					}
				}
			}
		''')
		this.validator.assertNoErrors(m2.root, IssueCodes.DUPLICATE_NAME)
	}

	@Test def void testDuplicateNodeNames_04() {
		val m = load('''
			module amodule {
			  namespace "urn:test:amodule";
			  prefix "amodule";
			
			  organization "organização güi";
			  contact "àéïç¢ô";
			
			  grouping x {
			    leaf y { type string; }
			  }
			
			  rpc run {
			    input { uses x; }
			    output { uses x; }
			  }
			}
		''')
		this.validator.assertNoErrors(m.root, IssueCodes.DUPLICATE_NAME)
	}
}