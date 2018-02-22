package io.typefox.yang.tests.serializer;

import com.google.inject.Inject
import com.google.inject.Provider
import io.typefox.yang.tests.YangInjectorProvider
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Contact
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Organization
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.YangFactory
import io.typefox.yang.yang.YangPackage
import io.typefox.yang.yang.YangVersion
import java.io.File
import java.util.Arrays
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.serializer.ISerializer
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(YangInjectorProvider)
public class ModuleSerializeTest {

	@Inject
	protected Provider<XtextResourceSet> resourceSetProvider

	@Inject
	protected IResourceDescription.Manager manager;

	protected var XtextResourceSet resourceSet;

	@Before
	def void beforeTest() {
		resourceSet = resourceSetProvider.get
	}

	@Test
	def void testSerializeString() {
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
		tailfImport.module = loadReferenceModuleFile("t-common.yang")
		tailfImport.create(YangPackage.eINSTANCE.prefix, Prefix).prefix = "t"
		var XtextResource moduleResource = resourceSet.createResource(
			URI.createFileURI("serialize-test.yang")) as XtextResource
		moduleResource.contents.add(targetModule)
		var ISerializer serializer = moduleResource.getSerializer();
		assertEquals(serializer.serialize(targetModule), '''
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
		'''.toString.trim)
	}

	private def AbstractModule loadReferenceModuleFile(String moduleFileName) {
		var File moduleFile = new File("src/test/resources/" + moduleFileName)
		var FileLoader loader = new FileLoader(resourceSet, Arrays.asList(moduleFile.parentFile.absolutePath), manager)

		loader.get(moduleFile)
	}

	private def <T> create(Statement it, EClass substmtEClass, Class<T> clazz) {
		val Statement stmt = YangFactory.eINSTANCE.create(substmtEClass) as Statement
		it.substatements.add(stmt)
		stmt as T
	}
}
