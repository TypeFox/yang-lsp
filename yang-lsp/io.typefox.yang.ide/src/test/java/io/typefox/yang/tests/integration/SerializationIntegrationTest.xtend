package io.typefox.yang.tests.integration

import io.typefox.yang.YangStandaloneSetup
import io.typefox.yang.yang.XpathExpression
import io.typefox.yang.yang.YangFactory
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.Collection
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.junit.Assert
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameters
import static extension io.typefox.yang.utils.YangStringUtils.*

@FinalFieldsConstructor
@RunWith(Parameterized)
class SerializationIntegrationTest {
	
	@Parameters(name= "{0}")
	static def Collection<Object[]> getFiles() {
		val params = newArrayList
		scanRecursively(new File("./src/test/resources")) [
			val arr = <Object>newArrayOfSize(1)
			arr.set(0, it)
			params.add(arr)
		]
		return params
	}
	
	static ResourceSet rs
	
	@BeforeClass
	static def void beforeClass() {
		val injector = new YangStandaloneSetup().createInjectorAndDoEMFRegistration
		rs = injector.getInstance(XtextResourceSet)
		scanRecursively(new File("./src/test/resources")) [
			rs.getResource(URI.createFileURI(absolutePath), true)
		]
		EcoreUtil2.resolveAll(rs)
	}
	
	static def void scanRecursively(File file, (File)=>void acceptor) {
		if (file.isDirectory) {
			for (f : file.listFiles) {			
				scanRecursively(f, acceptor)
			}
		} else {
			if (file.name.endsWith('.yang')) {
				acceptor.apply(file)
			}
		}
	}
	
	val File file
	
	@Test def void testSerializing() {
		val resource = rs.getResource(URI.createFileURI(this.file.absolutePath), true) as XtextResource
		EcoreUtil.resolveAll(resource)
		Assert.assertTrue(resource.errors.empty)
		replaceXpathExpressions(resource)
		removeNodeModel(resource)
		val s0 = new ByteArrayOutputStream()
		resource.save(s0, null);
		s0.close();
		val text0 = new String(s0.toByteArray, resource.encoding)
		resource.reparse(text0)
		EcoreUtil.resolveAll(resource)
		if (!resource.errors.empty) {
			System.err.println(text0)
			Assert.fail(resource.errors.map[message].join('\n'))
		}
		replaceXpathExpressions(resource)
		removeNodeModel(resource)
		val s1 = new ByteArrayOutputStream()
		resource.save(s1, null);
		s1.close();
		val text1 = new String(s1.toByteArray, resource.encoding)
		Assert.assertEquals(text0, text1)
	}
	
	protected def void removeNodeModel(XtextResource resource) {
		resource.allContents.forEach [ object |
			val adapters = newArrayList 
			adapters += object.eAdapters.filter[it instanceof INode]
			object.eAdapters.removeAll(adapters)
		]
	}
	
	protected def void replaceXpathExpressions(XtextResource resource) {
		for(val i = resource.allContents; i.hasNext();) {
			val next = i.next
			if (next instanceof XpathExpression) {
				val text = NodeModelUtils.getNode(next).text.trim.fixQuotes
				val unparsed = YangFactory.eINSTANCE.createUnparsedXpath()
				unparsed.text = text
				i.prune()
				next.eContainer.eSet(next.eContainmentFeature, unparsed)
			}
		}
	}
	
	private def String fixQuotes(String s) {
		if(s.startsWith('"')) { 
			if(!s.endsWith('"'))
				return s + '"'
			else 
				return s
		}
		if(s.startsWith("'")) {
			if(!s.endsWith("'")) 
				return s + "'"
			else
				return s
		}
		return s.addQuotesIfNecessary
	}
}