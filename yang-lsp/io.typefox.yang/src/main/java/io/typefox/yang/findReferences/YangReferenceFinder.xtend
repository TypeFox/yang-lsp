package io.typefox.yang.findReferences

import com.google.common.collect.HashMultimap
import com.google.common.collect.ImmutableMultimap
import com.google.common.collect.Multimap
import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.findReferences.IReferenceFinder
import org.eclipse.xtext.resource.IReferenceDescription
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.impl.ChunkedResourceDescriptions
import org.eclipse.xtext.util.CancelIndicator

class YangReferenceFinder {

	static val REFERENCES_KEY = 'statement-references';

	@Inject
	IReferenceFinder referenceFinder;

	def Multimap<URI, Pair<URI, EReference>> collectReferences(Resource resource) {
		collectReferences(resource, CancelIndicator.NullImpl);
	}

	def Multimap<URI, Pair<URI, EReference>> collectReferences(Resource resource, CancelIndicator indicator) {
		val Provider<Multimap<URI, Pair<URI, EReference>>> provider = [
			val acceptor = new YangReferenceAcceptor(resource.URI)

			referenceFinder.findAllReferences(resource, acceptor, new NullProgressMonitor() {
				override isCanceled() {
					indicator.canceled
				}
			})

			val index = ChunkedResourceDescriptions.findInEmfObject(resource.resourceSet)
			if (index !== null) {
				index.allResourceDescriptions.map[referenceDescriptions].forEach [
					forEach [
						acceptor.accept(it)
					]
				]
			}

			return ImmutableMultimap.copyOf(acceptor.references);
		];

		if (resource instanceof XtextResource) {
			return resource.cache.get(REFERENCES_KEY, resource, provider);
		} else {
			return provider.get;
		}
	}

	@FinalFieldsConstructor static class YangReferenceAcceptor implements IReferenceFinder.Acceptor {

		val URI uri
		@Accessors val Multimap<URI, Pair<URI, EReference>> references = HashMultimap.create

		override accept(IReferenceDescription description) {
			if (description.targetEObjectUri.trimFragment == uri)
				references.put(description.targetEObjectUri, description.sourceEObjectUri -> description.EReference)
		}

		override accept(EObject source, URI sourceURI, EReference eReference, int index, EObject targetOrProxy,
			URI targetURI) {
			if (targetURI.trimFragment == uri)
				references.put(targetURI, sourceURI -> eReference)
		}

	}

}
