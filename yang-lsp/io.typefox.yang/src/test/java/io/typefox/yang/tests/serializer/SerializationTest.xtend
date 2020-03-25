package io.typefox.yang.tests.serializer

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Contact
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Organization
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.YangFactory
import io.typefox.yang.yang.YangPackage
import io.typefox.yang.yang.YangVersion
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.resource.XtextResource
import org.junit.Test

import static io.typefox.yang.yang.YangPackage.Literals.*
import static org.junit.Assert.*

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
	
	private def <T extends Statement> create(Statement it, EClass substmtEClass, Class<T> clazz) {
		val Statement stmt = YangFactory.eINSTANCE.create(substmtEClass) as Statement
		it.substatements.add(stmt)
		stmt as T
	}
}
