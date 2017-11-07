package io.typefox.yang.tests.serializer

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Namespace
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.serializer.ISerializer
import org.junit.Assert
import org.junit.Test
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.YangFactory

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
		Assert.assertEquals('''
			module bar {
			    yang-version 1.1;
			    prefix f;
			    namespace 'bar something';
			    container x {
			        leaf 'my-leaf;TEST';
			    }
			}
		'''.toString,serializer.serialize(resource.contents.head));
	}

}
