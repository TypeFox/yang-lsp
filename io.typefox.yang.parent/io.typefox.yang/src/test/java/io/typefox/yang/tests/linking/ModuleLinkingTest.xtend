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
}
