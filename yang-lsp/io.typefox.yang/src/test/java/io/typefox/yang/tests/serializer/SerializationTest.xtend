package io.typefox.yang.tests.serializer

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Contact
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Grouping
import io.typefox.yang.yang.KeyReference
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.List
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Organization
import io.typefox.yang.yang.Pattern
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import io.typefox.yang.yang.Uses
import io.typefox.yang.yang.YangFactory
import io.typefox.yang.yang.YangPackage
import io.typefox.yang.yang.YangVersion
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.InternalEObject
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.resource.XtextResource
import org.junit.Test

import static io.typefox.yang.yang.YangPackage.Literals.*
import static org.junit.Assert.*
import org.junit.Ignore

class SerializationTest extends AbstractYangTest {
	
	@Test
	def void testSerializeString() {
		val resource = load('''
			module foo {
			    yang-version 1.1;
			    prefix f;
			    namespace urn:foo;
			    container x {
			        action a {
			            input {}
			        }
			        action b {
			            input {}
			        }
			    }
			}
		''') as XtextResource
		
		val m = resource.contents.filter(Module).head
		m.name = 'bar';
		m.substatements.filter(Namespace).head.uri = 'bar something';
		val s = m.substatements.filter(Container).head
		val node = YangFactory.eINSTANCE.createLeaf => [
			name = 'my-leaf;TEST'
		]
		s.substatements.clear
		s.substatements.add(node)
		
		val serialized = resource.serializer.serialize(resource.contents.head)
		assertEquals('''
			module bar {
			    yang-version 1.1;
			    prefix f;
			    namespace 'bar something';
			    container x {
			        leaf 'my-leaf;TEST';
			    }
			}
		'''.toString, serialized)
	}
	
	@Test
	def void testSerializeCompletely() {
		val	targetModule = YangFactory.eINSTANCE.createModule
		targetModule.setName("serialize-test")
		targetModule.create(YANG_VERSION, YangVersion).yangVersion = "1.1"
		targetModule.create(NAMESPACE, Namespace).uri = "urn:rdns:com:foo:" + targetModule.name
		targetModule.create(PREFIX, Prefix).prefix = "serialize-ann"
		targetModule.create(YangPackage.eINSTANCE.organization, Organization).organization = "foo"
		targetModule.create(YangPackage.eINSTANCE.contact, Contact).contact = "bar"
		targetModule.create(YangPackage.eINSTANCE.description, Description).description = "This is a serialize test"
		
		val moduleResource = resourceSet.createResource(URI.createFileURI("serialize-test.yang")) as XtextResource
		moduleResource.contents.add(targetModule)
		val serialized = moduleResource.serializer.serialize(targetModule)
		assertEquals('''
			module serialize-test {
			    yang-version 1.1;
			    namespace urn:rdns:com:foo:serialize-test;
			    prefix serialize-ann;
			    organization foo;
			    contact bar;
			    description 'This is a serialize test';
			}'''.toString, serialized)
	}
	
	@Test
	def void testIssue160() {
		val resource = load('''
			module xpath-asterisk {
			  namespace xa;
			  prefix xa;
			  container routings {
			    list routing {
			    	key "name";
			        leaf name {
			            type string;
			        }
			        list api {
			       	  key "name";
			          leaf name {
			       	    type string;
			       	    must "count(/xa:routings/xa:routing[*]/xa:api[xa:name = current()]) = 1";
			          }
			       }
			    }
			  }
			}
		''') as XtextResource
		
		val serialized = resource.serializer.serialize(resource.contents.head)
		assertEquals('''
			module xpath-asterisk {
			  namespace xa;
			  prefix xa;
			  container routings {
			    list routing {
			    	key "name";
			        leaf name {
			            type string;
			        }
			        list api {
			       	  key "name";
			          leaf name {
			       	    type string;
			       	    must "count(/xa:routings/xa:routing[*]/xa:api[xa:name = current()]) = 1";
			          }
			       }
			    }
			  }
			}
			'''.toString, serialized)
	}
	
	@Test
	def void testIssue164a() {
		val resource = load('''
			module serialize-test {
			    grouping foo;
			    feature bar;
			    feature baz;
			    uses "foo" {
			        if-feature "bar or baz";
			    }
			}
		''') as XtextResource
		
		val serialized = resource.serializer.serialize(resource.contents.head)
		assertEquals('''
			module serialize-test {
			    grouping foo;
			    feature bar;
			    feature baz;
			    uses "foo" {
			        if-feature "bar or baz";
			    }
			}
			'''.toString, serialized)
	}
	
	@Test
	def void testIssue164b() {
		val resource = load('''
			module serialize-test {
				identity symmetric-key-format {
				    base " key-format-base";
				    description "Base key-format identity for symmetric keys.";
				}
			}
		''') as XtextResource
		
		val serialized = resource.serializer.serialize(resource.contents.head)
		assertEquals('''
			module serialize-test {
				identity symmetric-key-format {
				    base " key-format-base";
				    description "Base key-format identity for symmetric keys.";
				}
			}
			'''.toString, serialized)
	}
	
	@Test
	def void testIssue166a() {
		val resource = load('''
			module serialize-test {
			    container second-tag {
			        must
			            '../outer-tag/tag-type = "dot1q-types:s-vlan" and ' +
			            'tag-type = "dot1q-types:c-vlan"' {
			        }
			    }
			}
		''') as XtextResource
		
		val serialized = resource.serializer.serialize(resource.contents.head)
		assertEquals('''
			module serialize-test {
			    container second-tag {
			        must
			            '../outer-tag/tag-type = "dot1q-types:s-vlan" and ' +
			            'tag-type = "dot1q-types:c-vlan"' {
			        }
			    }
			}
			'''.toString, serialized)
	}
	
	@Test
	def void testIssue166b() {
		val resource = load('''
			module spaceremoved {
			  yang-version 1.1;
			  namespace "urn:ietf:params:xml:ns:yang:spaceremoved";
			  prefix removespace;
			
			  revision 2020-03-24 {
			    description "expose space remove problem";
			  }
			
			  container outer-tag {
			    must
			      'tag-type = "s-vlan" or ' +
			      'tag-type = "c-vlan"' {
			
			      error-message
			          "Only C-VLAN and S-VLAN tags can be matched";
			    }
			    uses dot1q-tag-classifier-grouping;  
			  }
			
			  container second-tag {
			    must
			      '../outer-tag/tag-type = "s-vlan" and ' +
			      'tag-type = "c-vlan"' {
			
			      error-message
			        "When matching two tags, the outermost tag must be
			          specified and of S-VLAN type and the second outermost
			          tag must be of C-VLAN tag type";
			    }
			    uses dot1q-tag-classifier-grouping;	 		  
			  }
			
			  grouping dot1q-tag-classifier-grouping {
			    leaf tag-type {
			      type string;
			      description
			        "VLAN type";
			    }
			  }
			}
		''') as XtextResource
		
		val saveOptions = SaveOptions.newBuilder.format.options
		val serialized = resource.serializer.serialize(resource.contents.head, saveOptions)
		assertEquals('''
			module spaceremoved {
			    yang-version 1.1;
			    namespace "urn:ietf:params:xml:ns:yang:spaceremoved";
			    prefix removespace;
			
			    revision 2020-03-24 {
			        description "expose space remove problem";
			    }
			
			    container outer-tag {
			        must 'tag-type = "s-vlan" or ' +
			      'tag-type = "c-vlan"' {
			
			            error-message
			          "Only C-VLAN and S-VLAN tags can be matched";
			        }
			        uses dot1q-tag-classifier-grouping;
			    }
			
			    container second-tag {
			        must '../outer-tag/tag-type = "s-vlan" and ' +
			      'tag-type = "c-vlan"' {
			
			            error-message
			        "When matching two tags, the outermost tag must be
			          specified and of S-VLAN type and the second outermost
			          tag must be of C-VLAN tag type";
			        }
			        uses dot1q-tag-classifier-grouping;
			    }
			
			    grouping dot1q-tag-classifier-grouping {
			        leaf tag-type {
			            type string;
			            description
			        "VLAN type";
			        }
			    }
			}
			'''.toString, serialized)
	}
	
	@Test
	def void testIssue181() {
		load('''
			module nef {
				yang-version 1.1;
			}
		''')
		val resource = load('''
			submodule nef-submodule-eventexposure {
			    yang-version 1.1;
			    belongs-to nef {
			        prefix "nefe";
			    }
			    grouping nnef-eventexposure {
			        container problem-type-uris {
			            description "URI to identifies the problem type.";
			                list problem-type-uri {
			                    key error-code;
			                    unique uri;
			                    leaf error-code {
			                        type int32;
			                    }
			                    leaf uri {
			                        type inet:uri;
			                        mandatory true;
			                    }
			                }
			            }
			   }
			}
		''') as XtextResource
		
		val saveOptions = SaveOptions.newBuilder.format.options
		val serialized = resource.serializer.serialize(resource.contents.head, saveOptions)
		assertEquals('''
			submodule nef-submodule-eventexposure {
			    yang-version 1.1;
			    belongs-to nef {
			        prefix "nefe";
			    }
			    grouping nnef-eventexposure {
			        container problem-type-uris {
			            description "URI to identifies the problem type.";
			            list problem-type-uri {
			                key error-code;
			                unique uri;
			                leaf error-code {
			                    type int32;
			                }
			                leaf uri {
			                    type inet:uri;
			                    mandatory true;
			                }
			            }
			        }
			    }
			}
			'''.toString, serialized)
	}
	
	@Test
	def void testIssue188() {
		val resource = load('''
			module _3gpp-common-fm2 {
			    yang-version 1.1;
			    namespace "urn:3gpp:sa5:_3gpp-common-fm2";
			    prefix "fm3gpp2";
			
			    revision 2020-10-08;
			
			    grouping AlarmRecordGrp {
			
			        leaf alarmId {
			            type string;
			        }
			
			        grouping ThresholdPackGrp {
			            leaf thresholdLevel {
			                type string;
			            }
			            leaf thresholdValue {
			                type string;
			            }
			        }
			
			        grouping ThresholdInfoGrp {
			            leaf measurementType {
			                type string;
			            }
			
			            uses ThresholdPackGrp;
			        }
			
			        list thresholdInfo {
			            uses ThresholdInfoGrp;
			        }
			    }
			}
		''') as XtextResource
		resource.assertNoErrors()
		val module = resource.contents.head as Module
		val uses = module.substatements.get(4).substatements.get(2).substatements.get(1) as Uses
		assertTrue(uses.grouping.node instanceof Grouping)
		assertFalse((uses.grouping.node as InternalEObject).eIsProxy)
		
		val serialized = resource.serializer.serialize(resource.contents.head)
		assertEquals('''
			module _3gpp-common-fm2 {
			    yang-version 1.1;
			    namespace "urn:3gpp:sa5:_3gpp-common-fm2";
			    prefix "fm3gpp2";
			
			    revision 2020-10-08;
			
			    grouping AlarmRecordGrp {
			
			        leaf alarmId {
			            type string;
			        }
			
			        grouping ThresholdPackGrp {
			            leaf thresholdLevel {
			                type string;
			            }
			            leaf thresholdValue {
			                type string;
			            }
			        }
			
			        grouping ThresholdInfoGrp {
			            leaf measurementType {
			                type string;
			            }
			
			            uses ThresholdPackGrp;
			        }
			
			        list thresholdInfo {
			            uses ThresholdInfoGrp;
			        }
			    }
			}
			'''.toString, serialized)
	}
	@Test
	def void testIssue_202() {
		val resource = load('''
			module  testKeys {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang: testKeys;
			    prefix  testKeys;
			
			    container container-name {
			        list list-name {
			            leaf leaf-name1 {
			                type int32 {}
			            }
			            leaf leaf-name2 {
			                type int32 {}
			            }
			        }
			        list list-name2 {
			            key "leaf-name10 leaf-name20";
			            leaf leaf-name10 {
			                type int32 {}
			            }
			            leaf leaf-name20 {
			                type int32 {}
			            }
			        }
			        list list-name3 {
			            key 	'  
			             leaf-name100 
			             leaf-name200  ';
			            leaf leaf-name100 {
			                type int32 {}
			            }
			            leaf leaf-name200 {
			                type int32 {}
			            }
			        }
			    }
			}
		''') as XtextResource
		val list = (resource.contents.head as Module).substatementsOfType(Container).head.substatementsOfType(List).head
		val key = YangFactory.eINSTANCE.createKey();
		list.substatements.add(0, key)
		list.substatementsOfType(Leaf).forEach [ keyLeaf |
			val KeyReference keyRef = YangFactory.eINSTANCE.createKeyReference();
			keyRef.setNode(keyLeaf);
			key.getReferences().add(keyRef);
		]
		val saveOptions = SaveOptions.newBuilder.format.options
		val serialized = resource.serializer.serialize(resource.contents.head, saveOptions)
		assertEquals('''
		module testKeys {
		    yang-version 1.1;
		    namespace urn:ietf:params:xml:ns:yang: testKeys;
		    prefix testKeys;
		
		    container container-name {
		        list list-name {
		            key "leaf-name1 leaf-name2";
		            leaf leaf-name1 {
		                type int32 {
		                }
		            }
		            leaf leaf-name2 {
		                type int32 {
		                }
		            }
		        }
		        list list-name2 {
		            key "leaf-name10 leaf-name20";
		            leaf leaf-name10 {
		                type int32 {
		                }
		            }
		            leaf leaf-name20 {
		                type int32 {
		                }
		            }
		        }
		        list list-name3 {
		            key '  
		             leaf-name100 
		             leaf-name200';
		            leaf leaf-name100 {
		                type int32 {
		                }
		            }
		            leaf leaf-name200 {
		                type int32 {
		                }
		            }
		        }
		    }
		}
		'''.toString, serialized)
	}
	
	@Test
	def void testIssue_205() {
		load('''
		module foo {
			namespace "foo:foo";
			prefix x;
			
			grouping g2 {
				container c12 {
				}
			}
			
			uses g2 {
				 augment "c12" {
				 container c22foo-bar {}
				 leaf lm1 {
				 	type string;
				 	mandatory true;
				 	 }
				 }
			}
			
		}
		''')
		val resource = load('''
			module bar {
			    namespace "foo:bar";
			    prefix y;
			    import foo {
			        prefix f;
			    }
			
			    augment "/f:c12/f:c22foo-bar" {
			        container c32 {
			        }
			    }
			    augment "/f:c12" + "/f:c22foo-bar" {
			        container c33 {
			        }
			    }
			    augment "/f:c12/" + "f:c22foo-bar" {
			        container c34 {
			        }
			    }
			    augment "/f:c12/f" + ":c22foo-bar" {
			        container c35 {
			        }
			    }
			    augment "/f:c12/f:c2"+ "2foo-bar" {
			        container c36a {
			        }
			    }
			    augment "/f:c12/f:"  + "c22foo-bar" {
			        container c36 {
			        }
			    }
			    augment "/f:c12/f:c22foo-" + "bar" {
			        container c38 {
			        }
			    }
			    augment "/f:c12/f:c22foo" + "-bar" {
			        container c37 {
			        }
			    }
			}
		''') as XtextResource
		
		val serialized = resource.serializer.serialize(resource.contents.head)
		assertEquals('''
		module bar {
		    namespace "foo:bar";
		    prefix y;
		    import foo {
		        prefix f;
		    }
		
		    augment "/f:c12/f:c22foo-bar" {
		        container c32 {
		        }
		    }
		    augment "/f:c12" + "/f:c22foo-bar" {
		        container c33 {
		        }
		    }
		    augment "/f:c12/" + "f:c22foo-bar" {
		        container c34 {
		        }
		    }
		    augment "/f:c12/f:c22foo-bar" {
		        container c35 {
		        }
		    }
		    augment "/f:c12/f:c22foo-bar" {
		        container c36a {
		        }
		    }
		    augment "/f:c12/f:c22foo-bar" {
		        container c36 {
		        }
		    }
		    augment "/f:c12/f:c22foo-bar" {
		        container c38 {
		        }
		    }
		    augment "/f:c12/f:c22foo-bar" {
		        container c37 {
		        }
		    }
		}
		'''.toString, serialized)
	}
	
	@Test
	def void testIssue220() {
		val module = YangFactory.eINSTANCE.createModule
		module.setName("serialize-test")
		val typeDef = module.create(YangPackage.eINSTANCE.typedef, Typedef)
		typeDef.setName("my-dt")
		val type = typeDef.create(YangPackage.eINSTANCE.type, Type)
		type.typeRef = YangFactory.eINSTANCE.createTypeReference => [builtin = "string"]
		val pattern = type.create(YangPackage.eINSTANCE.pattern, Pattern)
		val resource = resourceSet.createResource(URI.createFileURI("serialize-test.yang")) as XtextResource
		resource.contents.add(module)

		pattern.regexp = "(/.*/i?)"

		assertEquals('''
		module serialize-test {
		    typedef my-dt {
		        type string {
		            pattern '(/.*/i?)';
		        }
		    }
		}'''.toString, resource.serializer.serialize(module))

	}

	@Test @Ignore
	def void testIssue209() {
		val resource = load('''
			module test-module {
			    yang-version 1.1;
			    namespace urn:ietf:params:xml:ns:yang:test-module;
			    prefix ts-mod;
			    container "container" {
			        must "x > y" + " and x * y < 100";
			    }
			    container "container2" {
			        must "x > y" + /* some ml comment */ " and x * y < 100";
			    }
			}
		''') as XtextResource
		
		val serialized = resource.serializer.serialize(resource.contents.head)
		assertEquals('''
		module test-module {
		    yang-version 1.1;
		    namespace urn:ietf:params:xml:ns:yang:test-module;
		    prefix ts-mod;
		    container "container" {
		        must "x > y" + " and x * y < 100";
		    }
		    container "container2" {
		        must "x > y" + /* some ml comment */ " and x * y < 100";
		    }
		}
		'''.toString, serialized)

	}
	
	private def <T extends Statement> create(Statement it, EClass substmtEClass, Class<T> clazz) {
		val Statement stmt = YangFactory.eINSTANCE.create(substmtEClass) as Statement
		it.substatements.add(stmt)
		stmt as T
	}
}
