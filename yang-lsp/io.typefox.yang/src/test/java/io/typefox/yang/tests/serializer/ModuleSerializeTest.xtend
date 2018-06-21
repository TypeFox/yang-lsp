package io.typefox.yang.tests.serializer;

import com.google.inject.Inject
import com.google.inject.Provider
import io.typefox.yang.tests.YangInjectorProvider
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Contact
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Extension
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Organization
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Unknown
import io.typefox.yang.yang.YangFactory
import io.typefox.yang.yang.YangPackage
import io.typefox.yang.yang.YangVersion
import java.io.File
import java.util.Arrays
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(YangInjectorProvider)
class ModuleSerializeTest {

	@Inject
	protected Provider<XtextResourceSet> resourceSetProvider

	@Inject
	protected IResourceDescription.Manager manager;
	
	protected var XtextResourceSet resourceSet;

	var FileLoader loader
	var Module tCommon;

	@Before
	def void beforeTest() {
		resourceSet = resourceSetProvider.get
		loader = new FileLoader(resourceSet, Arrays.asList(new File("src/test/resources/").absolutePath), manager)
		tCommon = loadModuleFile("t-common.yang") as Module
	}
	
	@Test
	def void testTestgrp3() {
		val targetModule = loadModuleFile("testgrp3.yang")
		assertSerialized('''
			module testgrp {
			    namespace "http://netconfcentral.org/ns/testgrp";
			    prefix "tgrp";
			    revision 2010-05-27 {
			        description "Initial revision.";
			    }
			    grouping testgrp {
			      list a {
			        key g1;
			        leaf g1 { type string; }
			        leaf g2 { type string; }
			      }
			   }
			}
		''', targetModule)
	}

	@Test 
	def void testSerializeOriginalXPath() {
		val targetModule = loadModuleFile("xpath-serialize.yang")
		assertSerialized('''
			module xpath-serialize {
				namespace xpath;
				prefix xs;
				yang-version 1.1;
				import yangster-test {
					prefix ytest;
				}
				container cb {
				    list lb {
				        leaf lfb {
				            type leafref {
				                path "/ytest:c1/ytest:l1";
				            }
				        }
				        leaf lfb2 { 
				        	type leafref { 
				        		path "/ytest:c1" + "/ytest:l1";
				        	}
				        }
				        leaf lfb3 { 
				        	type leafref { 
				        		path "/ytest:c1/" + "ytest:l1";
				        	}
				        }
				        leaf lfb4 { 
				        	type leafref { 
				        		path "/ytest:" + "c1/ytest" + ":l1";
				        	}
				        }
				    }
				}
			}
		''', targetModule)
		EcoreUtil.resolveAll(targetModule)
		assertSerialized('''
			module xpath-serialize {
				namespace xpath;
				prefix xs;
				yang-version 1.1;
				import yangster-test {
					prefix ytest;
				}
				container cb {
				    list lb {
				        leaf lfb {
				            type leafref {
				                path "/ytest:c1/ytest:l1";
				            }
				        }
				        leaf lfb2 { 
				        	type leafref { 
				        		path "/ytest:c1" + "/ytest:l1";
				        	}
				        }
				        leaf lfb3 { 
				        	type leafref { 
				        		path "/ytest:c1/" + "ytest:l1";
				        	}
				        }
				        leaf lfb4 { 
				        	type leafref { 
				        		path "/ytest:" + "c1/ytest" + ":l1";
				        	}
				        }
				    }
				}
			}
		''', targetModule)
	}
	

	@Test
	def void testSerializeDeviationAction() {
		val targetModule = loadModuleFile("yangster-action-test.yang")
		val resource = targetModule.eResource as XtextResource
		resource.serializer.serialize(targetModule)
	}

	@Test
	def void testSerializeNewModule() {
		val targetModule = YangFactory.eINSTANCE.createModule

		targetModule.setName("serialize-test")
		targetModule.create(YangPackage.eINSTANCE.yangVersion, YangVersion).yangVersion = "1.1"
		targetModule.create(YangPackage.eINSTANCE.namespace, Namespace).uri = "urn:rdns:org:yangster:model:" +
			targetModule.name
		targetModule.create(YangPackage.eINSTANCE.prefix, Prefix).prefix = "y"
		targetModule.create(YangPackage.eINSTANCE.organization, Organization).organization = "Yangster Inc."
		targetModule.create(YangPackage.eINSTANCE.contact, Contact).contact = "yangster"
		targetModule.create(YangPackage.eINSTANCE.description, Description).description = "This is a serialize test"

		val tailfImport = targetModule.create(YangPackage.eINSTANCE.import, Import)
		tailfImport.module = loadModuleFile("t-common.yang")
		tailfImport.create(YangPackage.eINSTANCE.prefix, Prefix).prefix = "t"
		var XtextResource moduleResource = resourceSet.createResource(
			URI.createFileURI("serialize-test.yang")) as XtextResource
		moduleResource.contents.add(targetModule)
		assertSerialized('''
			module serialize-test {
				yang-version 1.1;
				namespace urn:rdns:org:yangster:model:serialize-test;
				prefix y;
				organization 'Yangster Inc.';
				contact yangster;
				description 'This is a serialize test';
				import t-common {
					prefix t;
				}
			}
		''', targetModule)
	}

	@Test
	def void testSerializeUpdatedModule() {
		val targetModule = loadModuleFile("yangster-test.yang")
		
		var ii = targetModule.substatements.indexOf(targetModule.substatements.filter(Import).head)
		val tImport = YangFactory.eINSTANCE.create(YangPackage.eINSTANCE.import) as Import
		tImport.module = tCommon
		tImport.create(YangPackage.eINSTANCE.prefix, Prefix).prefix = "t"
		targetModule.substatements.add(ii + 1, tImport)

		var c1 = targetModule.substatements.filter(Container).filter[name.equals('c1')].head
		c1.substatements.add(createTailfSuppressEchoProperty)

		var l1 = c1.substatements.filter(Leaf).filter[name.equals('l1')].head
		l1.substatements.add(createTailfMetaDataProperty("static-data", "true"))
		l1.substatements.add(createTailfCallpointProperty("static-data-cb"))

		var c2 = targetModule.substatements.filter(Container).filter[name.equals('c2')].head
		c2.substatements.add(createTailfCallpointProperty("is-system-created-cb"))
		assertSerialized('''
			module yangster-test {
			    yang-version 1.1;
				namespace urn:rdns:org:yangster:model:yangster-test;
				prefix ytest;
				
				import yang-dep {
					prefix ydep;
				}
				import t-common {
					prefix t;
				}
			
				organization 'Yangster Inc.';
				contact yangster;
				description 'This is a serialize test';
				
				// TODO: This is a test
				container c1 {
					ydep:e1;
					leaf l1 {
						type string;
					t:meta-data static-data {
							t:meta-value true;
						}
						t:callpoint static-data-cb {
							t:set-hook node;
						}
					}
					t:suppress-echo true;
				}
				
				container c2 {
				t:callpoint is-system-created-cb {
						t:set-hook node;
					}
				}
			}
		''', targetModule)
	}

	private def Unknown createTailfSuppressEchoProperty() {
		createTailfWithValueProperty("suppress-echo", "true", null, null)
	}

	private def Unknown createTailfMetaDataProperty(String name, String value) {
		createTailfWithValueProperty("meta-data", name, "meta-value", value)
	}

	private def Unknown createTailfCallpointProperty(String name) {
		createTailfWithValueProperty("callpoint", name, "set-hook", "node")
	}

	// t:meta-data "is-system-created";
	// t:meta-data "static-data" { t:meta-value true; }
	// t:callpoint is-system-created-cb { t:set-hook node; }
	// t:callpoint static-data-cb { t:set-hook node; }
	//	 n1		  v1				  n2	   v2
	private def Unknown createTailfWithValueProperty(String n1, String v1, String n2, String v2) {
		var Unknown property = createTailfNameProperty(n1);
		if (v2 !== null) {
			var Unknown valueProperty = createTailfValueProperty(n2, v2)
			property.substatements.add(valueProperty);
		}
		property.name = v1;
		return property;
	}

	private def Unknown createTailfNameProperty(String name) {
		var Unknown property = YangFactory.eINSTANCE.createUnknown();
		var Extension tailfExtension = name.getTailfCommonExtension
		property.extension = tailfExtension
		property
	}

	private def Unknown createTailfValueProperty(String name, String value) {
		var Unknown valueProperty = YangFactory.eINSTANCE.createUnknown();
		var Extension tailfExtension = name.getTailfCommonExtension
		valueProperty.extension = tailfExtension
		valueProperty.name = value;
		valueProperty
	}

	private def Extension getTailfCommonExtension(String extensionName) {
		tCommon.substatements?.filter(Extension)?.filter[name.equals(extensionName)]?.head;
	}
	private def AbstractModule loadModuleFile(String moduleFileName) {
		var File moduleFile = new File("src/test/resources/" + moduleFileName)
		loader.get(moduleFile)
	}

	private def <T> create(Statement it, EClass substmtEClass, Class<T> clazz) {
		val Statement stmt = YangFactory.eINSTANCE.create(substmtEClass) as Statement
		it.substatements.add(stmt)
		stmt as T
	}
	
	private def assertSerialized(CharSequence expected, AbstractModule targetModule) {
		val resource = targetModule.eResource as XtextResource
		val actual = resource.serializer.serialize(targetModule)
		assertEquals(expected.toString.trim.replaceAll('\\s+', ' '), actual.trim.replaceAll('\\s+', ' '))
	}
}
