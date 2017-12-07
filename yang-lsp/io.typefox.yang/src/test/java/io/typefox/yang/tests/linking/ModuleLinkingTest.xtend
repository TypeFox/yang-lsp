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
import io.typefox.yang.yang.Revision
import io.typefox.yang.yang.RevisionDate
import org.eclipse.xtext.diagnostics.Diagnostic

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
		val uses = m3.root.eAllContents.filter(Uses).head
		assertSame(m1.root.substatementsOfType(Grouping).head, uses.grouping.node)
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
		assertError(m1.root.substatements.head, IssueCodes.INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE)
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
		assertSame(m.root, m2.root.substatementsOfType(Include).head.module)
		assertSame(m2.root, m.root.substatementsOfType(BelongsTo).head.module)
	}
	
	@Test def void testMultiModuleRevisions() {
		val m = load('''
			module xt11 {
			  namespace "urn:xt11";
			  prefix "xt11";
			
			  import xt10 {
			    prefix x1;
			    revision-date 2009-01-01;
			  }
			
			  import xt10 {
			    prefix x2;
			    revision-date "2009-02-01";
			  }
			
			}
		''')
		val m2 = load('''
			module xt10 {
				revision "2009-01-01" {
				}
			}
		''')
		val m3 = load('''
			module xt10 {
				revision 2009-01-01 {
				}
				revision 2009-02-01 {
				}
			}
		''')
		assertSame(m2.root, m.root.substatementsOfType(Import).get(0).module)
		assertSame(m3.root, m.root.substatementsOfType(Import).get(1).module)
	}
	
	@Test def void testImportNoRevision() {
		val foo = load('''
			module foo {
			    namespace foo;
			    prefix foo;
				revision 2002-02-02;
				revision 2001-01-01;
			}
		''')
		val bar = load('''
			module bar {
				namespace bar;
				prefix bar;
				import foo {
					prefix foo;
			    }
			}
		''')
		validator.validate(foo)
		assertNoErrors(foo.root)
		validator.validate(bar)
		assertNoErrors(bar.root)
	}
	
	@Test def void testImportMaxRevision() {
		val foo = load('''
			module foo {
			    namespace foo;
			    prefix foo;
				revision 2002-02-02;
				revision 2001-01-01;
			}
		''')
		val bar = load('''
			module bar {
				namespace bar;
				prefix bar;
				import foo {
					prefix foo;
					revision-date 2002-02-02;
			    }
			}
		''')
		validator.validate(foo)
		assertNoErrors(foo.root)
		validator.validate(bar)
		assertNoErrors(bar.root)
		assertEquals(foo.allContents.filter(Revision).head, bar.allContents.filter(RevisionDate).head.date)
	}
	
	@Test def void testImportOlderRevision() {
		val foo = load('''
			module foo {
			    namespace foo;
			    prefix foo;
				revision 2002-02-02;
				revision 2001-01-01;
			}
		''')
		val bar = load('''
			module bar {
				namespace bar;
				prefix bar;
				import foo {
					prefix foo;
					revision-date 2001-01-01;
			    }
			}
		''')
		validator.validate(foo)
		assertNoErrors(foo.root)
		validator.validate(bar)
		assertNoErrors(bar.root)
		assertEquals(foo.allContents.filter(Revision).last, bar.allContents.filter(RevisionDate).head.date)
	}
	
	@Test def void testImportNonExistingRevision() {
		val foo = load('''
			module foo {
			    namespace foo;
			    prefix foo;
				revision 2002-02-02;
				revision 2001-01-01;
			}
		''')
		val bar = load('''
			module bar {
				namespace bar;
				prefix bar;
				import foo {
					prefix foo;
					revision-date 2003-03-03;
			    }
			}
		''')
		validator.validate(foo)
		assertNoErrors(foo.root)
		validator.validate(bar)
		assertError(bar.allContents.filter(RevisionDate).head, Diagnostic.LINKING_DIAGNOSTIC)
		assertEquals(foo.root, bar.allContents.filter(Import).head.module)
	}
	
	@Test def void testDuplicateRevision() {
		val foo = load('''
			module foo {
			    namespace foo;
			    prefix foo;
				revision 2002-02-02;
				revision 2001-01-01;
			}
		''')
		load('''
			module foo {
			    namespace foo;
			    prefix foo;
				revision 2002-02-02;
			}
		''')
		val bar = load('''
			module bar {
				namespace bar;
				prefix bar;
				import foo {
					prefix foo;
					revision-date 2002-02-02;
			    }
			}
		''')
		validator.validate(foo)
		assertNoErrors(foo.root)
		validator.validate(bar)
		assertError(bar.allContents.filter(Import).head, IssueCodes.AMBIGUOUS_IMPORT)
		assertEquals(foo.root.name, bar.allContents.filter(Import).head.module.name)
	}
	
	
}
