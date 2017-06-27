package io.typefox.yang.tests.linking

import com.google.inject.Inject
import io.typefox.yang.tests.YangInjectorProvider
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Include
import io.typefox.yang.yang.YangFile
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*
import io.typefox.yang.yang.BelongsTo

@RunWith(XtextRunner)
@InjectWith(YangInjectorProvider)
class ModuleLinkingTest {
	
	@Inject ParseHelper<YangFile> parser;
	@Inject IResourceDescription.Manager mnr;
	
	@Test def void testModuleExport() {
		val m = parser.parse('''
			module ietf-foo {
			}
		''')
		val desc = mnr.getResourceDescription(m.eResource)
		assertEquals('ietf-foo', desc.exportedObjects.head.qualifiedName.toString)
	}
		
	@Test def void testModuleImport() {
		val m = parser.parse('''
			module ietf-foo {
			}
		''')
		val m2 = parser.parse('''
			module myModule {
				import ietf-foo {
				}
			}
		''', m.eResource.resourceSet)
		assertSame(m.statements.head, m2.statements.head.subStatements.filter(Import).head.module)
	}
	
	@Test def void testModuleImportWithRevision() {
		val m = parser.parse('''
			module a {
				revision 2008-01-02 { }
				grouping a {
					leaf eh {  }
				}
			}
		''')
		val m1 = parser.parse('''
			module a {
				revision 2008-01-01 { }
				grouping a {
					leaf eh {  }
				}
			}
		''', m.eResource.resourceSet)
		val m2 = parser.parse('''
			module b {
				import a {
					prefix p;
					revision-date 2008-01-01;
				}
			
				container bee {
					uses p:a;
				}
			}
		''', m.eResource.resourceSet)
		assertSame(m1.statements.head, m2.statements.head.subStatements.filter(Import).head.module)
	}
	
	@Test def void testModuleImportWithRevision_01() {
		val m = parser.parse('''
			module a {
				revision 2008-01-02 { }
				grouping a {
					leaf eh {  }
				}
			}
		''')
		parser.parse('''
			module a {
				revision 2008-01-01 { }
				grouping a {
					leaf eh {  }
				}
			}
		''', m.eResource.resourceSet)
		val m2 = parser.parse('''
			module b {
				import a {
					prefix p;
				}
			
				container bee {
					uses p:a;
				}
			}
		''', m.eResource.resourceSet)
		// no explicit revision => should link to any
		// TODO warning validation (multiple candidates)
		assertFalse(m2.statements.head.subStatements.filter(Import).head.module.eIsProxy)
	}
	
	@Test def void testModuleImportWithRevision_02() {
		val m = parser.parse('''
			module a {
				revision 2008-01-02 { }
				grouping a {
					leaf eh {  }
				}
			}
		''')
		parser.parse('''
			module a {
				revision 2008-01-01 { }
				grouping a {
					leaf eh {  }
				}
			}
		''', m.eResource.resourceSet)
		val m2 = parser.parse('''
			module b {
				import a {
					prefix p;
					revision-date 2008-01-03;
				}
			
				container bee {
					uses p:a;
				}
			}
		''', m.eResource.resourceSet)
		// no matching revision => should link to any
		// TODO error validation on unmatched revision
		assertFalse(m2.statements.head.subStatements.filter(Import).head.module.eIsProxy)
	}
	
	@Test def void testSubModuleExport() {
		val m = parser.parse('''
			submodule my-submodule {
			}
		''')
		val desc = mnr.getResourceDescription(m.eResource)
		assertEquals('my-submodule', desc.exportedObjects.head.qualifiedName.toString)
	}
	
	@Test def void testSubModuleInclude() {
		val m = parser.parse('''
			submodule sub-module {
			}
		''')
		val m2 = parser.parse('''
			module myModule {
				include sub-module{
				}
			}
		''', m.eResource.resourceSet)
		assertSame(m.statements.head, m2.statements.head.subStatements.filter(Include).head.subModule)
	}
	
	@Test def void testSubModuleCannotbeImported() {
		val m = parser.parse('''
			submodule sub-module {
			}
		''')
		val m2 = parser.parse('''
			module myModule {
				import sub-module{
				}
			}
		''', m.eResource.resourceSet)
		assertTrue(m2.statements.head.subStatements.filter(Import).head.module.eIsProxy)
	}
	
	@Test def void testSubModuleBelongsTo() {
		val m = parser.parse('''
			submodule sub-module {
				belongs-to myModule {
				}
			}
		''')
		val m2 = parser.parse('''
			module myModule {
				include sub-module{
				}
			}
		''', m.eResource.resourceSet)
		assertSame(m.statements.head, m2.statements.head.subStatements.filter(Include).head.subModule)
		assertSame(m2.statements.head, m.statements.head.subStatements.filter(BelongsTo).head.belongsTo)
	}
}
