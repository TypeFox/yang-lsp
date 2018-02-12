package io.typefox.yang.tests.integration

import io.typefox.yang.YangStandaloneSetup
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.Collection
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.resource.XtextResourceSet
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameters

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
		val resource = rs.getResource(URI.createFileURI(this.file.absolutePath), true)
		resource.allContents.forEach [ object |
			val adapters = newArrayList 
			adapters += object.eAdapters.filter[it instanceof INode]
			object.eAdapters.removeAll(adapters)
		]
		val s = new ByteArrayOutputStream()
		resource.save(s, null);
	}
}