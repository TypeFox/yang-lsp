package io.typefox.yang.tests.validation

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Include
import org.junit.Test

import static io.typefox.yang.validation.IssueCodes.*
import io.typefox.yang.yang.BelongsTo

class ImportVersionConstraintTest extends AbstractYangTest {
	
	@Test def void testIncludeVersion_0() {
		val foo = load('''
			module foo {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:foo;
			    prefix foo;
			
			    include bar;
			}
		''')
		val bar = load('''
			submodule bar {
			    yang-version 1;
			
			    belongs-to foo {
			        prefix 'foo';
			    }
			}

		''')
		validator.validate(foo)
		assertError(foo.root.substatements.filter(Include).head, BAD_INCLUDE_YANG_VERSION)
		validator.validate(bar)
		assertError(bar.root.substatements.filter(BelongsTo).head, BAD_INCLUDE_YANG_VERSION)
	}
	
	@Test def void testIncludeVersion_1() {
		val foo = load('''
			module foo {
			    yang-version 1;
			    namespace urn:ietf:params:xml:ns:yang:foo;
			    prefix foo;
			
			    include bar;
			}
		''')
		val bar = load('''
			submodule bar {
			    yang-version 1.1;
			
			    belongs-to foo {
			        prefix 'foo';
			    }
			}

		''')
		validator.validate(foo)
		assertError(foo.root.substatements.filter(Include).head, BAD_INCLUDE_YANG_VERSION)
		validator.validate(bar)
		assertError(bar.root.substatements.filter(BelongsTo).head, BAD_INCLUDE_YANG_VERSION)
	}
	
	@Test def void testImportVersion() {
		val foo = load('''
			module foo {
			    yang-version 1;
			    namespace urn:ietf:params:xml:ns:yang:foo;
			    prefix foo;
			
			    import bar {
			    		prefix bar;
			    	}
			}
		''')
		load('''
			module bar {
			    yang-version 1.1;
				namespace urn:ietf:params:xml:ns:yang:bar;
				prefix bar;
			}
		''')
		validator.validate(foo.root.eResource)
		assertError(foo.root.substatements.filter(Import).head, BAD_IMPORT_YANG_VERSION)
	}
}