package io.typefox.yang.tests

import com.google.common.base.Preconditions
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.yang.AbstractModule
import java.util.ArrayList
import java.util.Collections
import javax.inject.Inject
import javax.inject.Provider
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.impl.ResourceDescriptionsData
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ResourceHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.Assert
import org.junit.Before
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(YangInjectorProvider)
abstract class AbstractYangTest {

	@Inject Provider<XtextResourceSet> resourceSetProvider
	@Inject ResourceHelper resourceHelper
	@Inject protected IResourceDescription.Manager mnr
	@Inject protected ValidationTestHelper validator
	@Inject extension protected YangExtensions
	
	XtextResourceSet resourceSet
	
	@Before def void setup() {
		resourceSet = resourceSetProvider.get
	}
	
	protected def assertError(EObject obj, String code) {
		validator.assertError(obj, obj.eClass, code)
	}
	
	protected def assertError(EObject obj, String code, String searchTerm, String... messageParts) {
		val parsedText = (obj.eResource as XtextResource).parseResult?.rootNode?.text;
		val offset = parsedText.indexOf(searchTerm);
		Preconditions.checkArgument(offset >= 0, '''The '«searchTerm»' is not conatined in '«parsedText»'.''');
		validator.assertError(obj, obj.eClass, code, offset, searchTerm.length, messageParts);
	}
	
	protected def assertWarning(EObject obj, String code) {
		validator.assertWarning(obj, obj.eClass, code)
	}
	
	protected def assertWarning(EObject obj, String code, String searchTerm, String... messageParts) {
		val parsedText = (obj.eResource as XtextResource).parseResult?.rootNode?.text;
		val offset = parsedText.indexOf(searchTerm);
		Preconditions.checkArgument(offset >= 0, '''The '«searchTerm»' is not conatined in '«parsedText»'.''');
		validator.assertWarning(obj, obj.eClass, code, offset, searchTerm.length, messageParts);
	}
	
	protected def assertNoErrors(Resource resource) {
		validator.assertNoErrors(resource)
	}
	
	protected def assertNoErrors(EObject eObject) {
		validator.assertNoErrors(eObject)
	}
	
	protected def Resource load(CharSequence contents) {
		val uri = URI.createURI("synthetic:///__synthetic"+resourceSet.resources.size+".yang")
		val resource = resourceHelper.resource(contents.toString, uri, resourceSet)
		resource.load(emptyMap)
		Assert.assertTrue(resource.errors.join('\n')[message], resource.errors.empty)
		return resource
	}
	
	protected def AbstractModule root(Resource r) {
		fullyResolve
		return r.contents.head as AbstractModule
	}
	
	var isFullyResolved = false
	
	private def void fullyResolve() {
		if (isFullyResolved)
			return;
		isFullyResolved = true
		installIndex
		this.resourceSet.resources.forEach [
			this.validator.validate(it)
		]
	}
	
	private def void installIndex() {
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
