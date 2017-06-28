package io.typefox.yang.tests.linking

import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.YangFile
import java.util.ArrayList
import java.util.Collections
import javax.inject.Inject
import javax.inject.Provider
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.impl.ResourceDescriptionsData
import org.eclipse.xtext.testing.util.ResourceHelper
import org.junit.Before
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.eclipse.emf.ecore.EObject

class AbstractLinkingTest {
	@Inject Provider<XtextResourceSet> resourceSetProvider;
	@Inject ResourceHelper resourceHelper
	@Inject protected IResourceDescription.Manager mnr
	@Inject protected ValidationTestHelper validator
	
	XtextResourceSet resourceSet
	
	@Before def void setup() {
		resourceSet = resourceSetProvider.get
	}
	
	protected def assertError(EObject obj, String code) {
		validator.assertError(obj, obj.eClass, code)
	}
	
	protected def Resource load(CharSequence contents) {
		val uri = URI.createURI("synthetic:///__synthetic"+resourceSet.resources.size+".yang")
		return resourceHelper.resource(contents.toString, uri, resourceSet)
	}
	
	protected def AbstractModule root(Resource r) {
		return (r.contents.head as YangFile).statements.head as AbstractModule
	}
	
	protected def void installIndex() {
		val index = new ResourceDescriptionsData(Collections.emptyList)
		val resources = new ArrayList(resourceSet.resources)
		for (resource : resources) {
			index(resource, resource.URI, index)
		}
		ResourceDescriptionsData.ResourceSetAdapter.installResourceDescriptionsData(resourceSet, index)
	}

	private def void index(Resource resource, URI uri, ResourceDescriptionsData index) {
		val resourceDescription = mnr.getResourceDescription(resource)
		if (resourceDescription !== null) {
			index.addDescription(uri, resourceDescription)
		}
	}
}
