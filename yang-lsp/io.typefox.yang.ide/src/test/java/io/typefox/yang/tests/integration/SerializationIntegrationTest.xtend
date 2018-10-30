package io.typefox.yang.tests.integration

import com.google.inject.Injector
import io.typefox.yang.YangStandaloneSetup
import io.typefox.yang.yang.XpathExpression
import io.typefox.yang.yang.YangFactory
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.Collection
import java.util.Set
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.IResourceDescriptions
import org.eclipse.xtext.resource.IResourceDescriptionsProvider
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
	
	static Injector injector
	static IResourceDescriptions descriptions
	
	@BeforeClass
	static def void beforeClass() {
		injector = new YangStandaloneSetup().createInjectorAndDoEMFRegistration
		val rs = injector.getInstance(XtextResourceSet)
		scanRecursively(new File("./src/test/resources")) [
			rs.getResource(URI.createFileURI(absolutePath), true)
		]
		EcoreUtil.resolveAll(rs)
		descriptions = injector.getInstance(IResourceDescriptionsProvider).getResourceDescriptions(rs)
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
		val resource = loadResources(URI.createFileURI(this.file.absolutePath))
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
	
	private def loadResources(URI uri) {
		val uris = newHashSet
		uri.addReferencedURIs(uris)
		val newRs = injector.getInstance(XtextResourceSet)
		uris.forEach [
			newRs.getResource(it, true)
		] 
		EcoreUtil.resolveAll(newRs)
		val xtextResource = newRs.getResource(uri, false) as XtextResource
		if (!xtextResource.errors.empty) {
			System.err.println(xtextResource.parseResult.rootNode.text)
			Assert.fail(xtextResource.errors.map[message].join('\n'))
		}

		return xtextResource
	}
	
	private def void addReferencedURIs(URI uri, Set<URI> uris) {
		if (uris.add(uri)) {
			descriptions.getResourceDescription(uri).referenceDescriptions.forEach [
				targetEObjectUri.trimFragment.addReferencedURIs(uris)
			]
		}
	}
}