package io.typefox.yang.tests.linking

import com.google.inject.Inject
import com.google.inject.Provider
import io.typefox.yang.tests.YangInjectorProvider
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.BelongsTo
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Include
import io.typefox.yang.yang.YangFile
import java.util.ArrayList
import java.util.Collections
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.impl.ResourceDescriptionsData
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ResourceHelper
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(YangInjectorProvider)
class ModuleLinkingTest {
	
	@Inject Provider<XtextResourceSet> resourceSetProvider;
	@Inject ResourceHelper resourceHelper
	@Inject IResourceDescription.Manager mnr
	
	XtextResourceSet resourceSet
	
	@Before def void setup() {
		resourceSet = resourceSetProvider.get
		
	}
	
	private def Resource load(CharSequence contents) {
		val uri = URI.createURI("synthetic:///__synthetic"+resourceSet.resources.size+".yang")
		return resourceHelper.resource(contents.toString, uri, resourceSet)
	}
	
	private def AbstractModule root(Resource r) {
		return (r.contents.head as YangFile).statements.head as AbstractModule
	}
	
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
		assertSame(m.root, m2.root.subStatements.filter(Import).head.module)
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
		assertSame(m1.root, m2.root.subStatements.filter(Import).head.module)
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
		// no explicit revision => should link to any
		// TODO warning validation (multiple candidates)
		assertFalse(m2.root.subStatements.filter(Import).head.module.eIsProxy)
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
		assertFalse(m2.root.subStatements.filter(Import).head.module.eIsProxy)
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
		assertSame(m.root, m2.root.subStatements.filter(Include).head.module)
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
		// links to the module but should be erroneous
		assertFalse(m2.root.subStatements.filter(Import).head.module.eIsProxy)
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
		assertSame(m.root, m2.root.subStatements.filter(Include).head.module)
		assertSame(m2.root, m.root.subStatements.filter(BelongsTo).head.module)
	}
	
	private def void installIndex() {
		val index = new ResourceDescriptionsData(Collections.emptyList)
		val resources = new ArrayList(resourceSet.resources)
		for (resource : resources) {
			index(resource, resource.URI, index)
		}
		ResourceDescriptionsData.ResourceSetAdapter.installResourceDescriptionsData(resourceSet, index)
	}

	private def void index(Resource resource, URI uri, ResourceDescriptionsData index) {
		val serviceProvider = IResourceServiceProvider.Registry.INSTANCE.getResourceServiceProvider(uri)
		if (serviceProvider !== null) {
			val resourceDescription = serviceProvider.resourceDescriptionManager.getResourceDescription(resource)
			if (resourceDescription !== null) {
				index.addDescription(uri, resourceDescription)
			}
		}
	}
}
