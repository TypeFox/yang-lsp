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
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.serializer.ISerializer
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
		
		var ISerializer serializer = resource.getSerializer();
		assertEquals('''
			module bar {
			    yang-version 1.1;
			    prefix f;
			    namespace 'bar something';
			    container x {
			        leaf 'my-leaf;TEST';
			    }
			}
		'''.toString, serializer.serialize(resource.contents.head));
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
		
		var XtextResource moduleResource = resourceSet.createResource(URI.createFileURI("serialize-test.yang")) as XtextResource
		moduleResource.contents.add(targetModule)
		var ISerializer serializer = moduleResource.getSerializer();
		assertEquals('''
			module serialize-test {
			    yang-version 1.1;
			    namespace urn:rdns:com:foo:serialize-test;
			    prefix serialize-ann;
			    organization foo;
			    contact bar;
			    description 'This is a serialize test';
			}'''.toString, serializer.serialize(targetModule));
	}
	
	private def <T> create(Statement it, EClass substmtEClass, Class<T> clazz) {
		val Statement stmt = YangFactory.eINSTANCE.create(substmtEClass) as Statement
		it.substatements.add(stmt)
		stmt as T
	}
}
