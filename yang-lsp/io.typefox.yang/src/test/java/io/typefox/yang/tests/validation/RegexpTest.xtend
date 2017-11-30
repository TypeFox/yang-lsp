package io.typefox.yang.tests.validation

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Pattern
import org.junit.Test

import static io.typefox.yang.validation.IssueCodes.*

class RegexpTest extends AbstractYangTest {
	
	@Test def void testLegalPattern_0() {
		val foo = load('''
			module foo {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:foo;
			    prefix foo;
			
			    	typedef foo {
					type string  {
						pattern [a-z0-9];
					}
				}
			}
		''')
		
		validator.validate(foo)
		assertNoErrors(foo.allContents.filter(Pattern).head, TYPE_ERROR)
	}
	
	@Test def void testLegalPattern_1() {
		val foo = load('''
			module foo {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:foo;
			    prefix foo;
			
			    	typedef foo {
					type string {
						pattern [a-zA-_];
					}
				}
			}
		''')
		
		validator.validate(foo)
		assertNoErrors(foo.allContents.filter(Pattern).head, TYPE_ERROR)
	}
	
	@Test def void testIllegalPattern_0() {
		val foo = load('''
			module foo {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:foo;
			    prefix foo;
			
			    	typedef foo {
					type string  {
						pattern [a-z-0];
					}
				}
			}
		''')
		
		validator.validate(foo)
		assertError(foo.allContents.filter(Pattern).head, TYPE_ERROR)
	}
	
	@Test def void testIllegalPattern_1() {
		val foo = load('''
			module foo {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:foo;
			    prefix foo;
			
			    	typedef foo {
					type string  {
						pattern [a-z-_];
					}
				}
			}
		''')
		
		validator.validate(foo)
		assertError(foo.allContents.filter(Pattern).head, TYPE_ERROR)
	}
	
}