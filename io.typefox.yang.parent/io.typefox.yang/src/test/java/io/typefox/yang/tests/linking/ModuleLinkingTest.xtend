package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.validation.IssueCodes
import io.typefox.yang.yang.BelongsTo
import io.typefox.yang.yang.Grouping
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Include
import io.typefox.yang.yang.Uses
import org.junit.Test

import static org.junit.Assert.*

class ModuleLinkingTest extends AbstractYangTest {
	
	@Test def void testModuleExport() {
		val m = load('''
			module ietf-foo {
			}
		''')
		val desc = mnr.getResourceDescription(m)
		assertEquals('ietf-foo', desc.exportedObjects.head.qualifiedName.toString)
	}
		
	@Test def void testModuleImport() {
		val m = load('''
			module ietf-foo {
			}
		''')
		val m2 = load('''
			module myModule {
				import ietf-foo {
				}
			}
		''')
		assertSame(m.root, m2.root.substatementsOfType(Import).head.module)
	}
	
	@Test def void testModuleImport_NoPefix() {
		load('''
			module a {
			}
		''')
		val m = load('''
			module b {
				import a;
			}
		''')
		assertError(m.root.substatements.head, IssueCodes.MISSING_PREFIX)
	}
	
	@Test def void testModuleImportWithRevision() {
		load('''
			module a {
				revision 2008-01-02 { }
				grouping a {
					leaf eh {  }
				}
			}
		''')
		val m1 = load('''
			module a {
				revision 2008-01-01 { }
				grouping a {
					leaf eh {  }
				}
			}
		''')
		val m2 = load('''
			module b {
				import a {
					prefix p;
					revision-date 2008-01-01;
				}
			
				container bee {
					uses p:a;
				}
			}
		''')
		installIndex
		assertSame(m1.root, m2.root.substatementsOfType(Import).head.module)
		val uses = m2.root.eAllContents.filter(Uses).head
		assertSame(m1.root.substatementsOfType(Grouping).head, uses.grouping.node)
	}
	
	@Test def void testModuleNamespace() {
		val m1 = load('''
			submodule asub {
				belongs-to a;
				grouping a {
					leaf eh {  }
				}
			}
		''')
		val m2 = load('''
			module a {
				include asub;
			
				container bee {
					uses a;
				}
			}
		''')
		installIndex
		assertSame(m1.root, m2.root.substatementsOfType(Include).head.module)
		val uses = m2.root.eAllContents.filter(Uses).head
		assertSame(m1.root.substatementsOfType(Grouping).head, uses.grouping.node)
	}
	
	@Test def void testImportGroupingFromSubModule() {
		val m1 = load('''
			submodule asub {
				belongs-to a;
				grouping a {
					leaf eh {  }
				}
			}
		''')
		load('''
			module a {
				include asub;
			}
		''')
		val m3 = load('''
			module b {
				import a {
					prefix apref;
				}
				container bee {
					uses apref:a;
				}
			}
		''')
		installIndex
		val uses = m3.root.eAllContents.filter(Uses).head
		assertSame(m1.root.substatementsOfType(Grouping).head, uses.grouping.node)
	}
	
	@Test def void testModuleImportWithRevision_01() {
		load('''
			module a {
				revision 2008-01-02 { }
				grouping a {
					leaf eh {  }
				}
			}
		''')
		load('''
			module a {
				revision 2008-01-01 { }
				grouping a {
					leaf eh {  }
				}
			}
		''')
		val m2 = load('''
			module b {
				import a {
					prefix p;
				}
			
				container bee {
					uses p:a;
				}
			}
		''')
		val imp = m2.root.substatementsOfType(Import).head
		assertWarning(imp, IssueCodes.MISSING_REVISION)
		assertFalse(m2.root.substatementsOfType(Import).head.module.eIsProxy)
	}
	
	@Test def void testModuleBelongsToAnotherOne() {
		load('''
			module a {
			}
		''')
		val m1 = load('''
			module b {
				include c;
			}
		''')
		load('''
			submodule c {
				belongs-to a;
			}
		''')
		installIndex
		assertError(m1.root.substatements.head, IssueCodes.INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE)
	}
	
	@Test def void testModuleImportWithRevision_02() {
		load('''
			module a {
				revision 2008-01-02 { }
				grouping a {
					leaf eh {  }
				}
			}
		''')
		load('''
			module a {
				revision 2008-01-01 { }
				grouping a {
					leaf eh {  }
				}
			}
		''')
		val m2 = load('''
			module b {
				import a {
					prefix p;
					revision-date 2008-01-03;
				}
			
				container bee {
					uses p:a;
				}
			}
		''')
		// no matching revision => should link to any
		// TODO error validation on unmatched revision
		assertFalse(m2.root.substatementsOfType(Import).head.module.eIsProxy)
	}
	
	@Test def void testSubModuleExport() {
		val m = load('''
			submodule my-submodule {
			}
		''')
		val desc = mnr.getResourceDescription(m)
		assertEquals('my-submodule', desc.exportedObjects.head.qualifiedName.toString)
	}
	
	@Test def void testSubModuleInclude() {
		val m = load('''
			submodule sub-module {
			}
		''')
		val m2 = load('''
			module myModule {
				include sub-module{
				}
			}
		''')
		assertSame(m.root, m2.root.substatementsOfType(Include).head.module)
	}
	
	@Test def void testSubModuleCannotbeImported() {
		load('''
			submodule sub-module {
			}
		''')
		val m2 = load('''
			module myModule {
				import sub-module{
				}
			}
		''')
		val imp = m2.root.substatementsOfType(Import).head
		assertError(imp, IssueCodes.IMPORT_NOT_A_MODULE)
		assertFalse(imp.module.eIsProxy)
	}
	
	@Test def void testSubModuleBelongsTo() {
		val m = load('''
			submodule sub-module {
				belongs-to myModule {
				}
			}
		''')
		val m2 = load('''
			module myModule {
				include sub-module{
				}
			}
		''')
		installIndex
		assertSame(m.root, m2.root.substatementsOfType(Include).head.module)
		assertSame(m2.root, m.root.substatementsOfType(BelongsTo).head.module)
	}
	
	
}
