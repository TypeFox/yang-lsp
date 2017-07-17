package io.typefox.yang.ide.codelens

import com.google.common.collect.HashMultimap
import com.google.common.collect.Multimap
import com.google.inject.Inject
import io.typefox.yang.yang.Statement
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.lsp4j.CodeLens
import org.eclipse.lsp4j.CodeLensParams
import org.eclipse.lsp4j.Command
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.findReferences.IReferenceFinder
import org.eclipse.xtext.ide.server.Document
import org.eclipse.xtext.ide.server.DocumentExtensions
import org.eclipse.xtext.ide.server.codelens.ICodeLensService
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.IReferenceDescription
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.resource.impl.ChunkedResourceDescriptions
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

class CodeLensService implements ICodeLensService {
	
	@Inject IReferenceFinder referenceFinder
	@Inject DocumentExtensions documentExtensions
	
	override computeCodeLenses(Document document, XtextResource resource, CodeLensParams params, CancelIndicator indicator) {
		val acceptor = new MyAcceptor(resource.URI)
		 
		referenceFinder.findAllReferences(resource, acceptor, new NullProgressMonitor() {
			override isCanceled() {
				indicator.canceled
			}
		})
		
		val index = ChunkedResourceDescriptions.findInEmfObject(resource.resourceSet)
		if (index !== null) {
			index.allResourceDescriptions.map[referenceDescriptions].forEach[
				forEach[
					acceptor.accept(it)
				]
			]
		}
		
		val result = newArrayList
		for (uri : acceptor.references.keySet) {
			if (uri.trimFragment == resource.URI) {
				val eObject = resource.getEObject(uri.fragment)
				if (eObject instanceof Statement) {
					val kwNode = NodeModelUtils.findActualNodeFor(eObject).leafNodes.filter[grammarElement instanceof Keyword].head
					if (kwNode !== null) {
						val	range = documentExtensions.newRange(resource, kwNode.textRegion)
						val locations = acceptor.references.get(uri).map[ refInfo |
							val eobj = resource.resourceSet.getEObject(refInfo.key, false)
							return documentExtensions.newLocation(eobj, refInfo.value, -1)
						].toList
						result += new CodeLens=>[
							it.range = range
							command = new Command => [
								command = 'yang.show.references'
								title = switch count : acceptor.references.get(uri).size {
									case 1 : '1 reference'
									default : '''«count» references'''
								}
								arguments = newArrayList(
									uri.trimFragment.toString,
									range.start,
									locations
								)
							]
						]
					}				
				}
			}
		}
		return result
	}
	
	@FinalFieldsConstructor static class MyAcceptor implements IReferenceFinder.Acceptor {
		
		val URI uri
		@Accessors val Multimap<URI, Pair<URI,EReference>> references = HashMultimap.create
		
		override accept(IReferenceDescription description) {
			if (description.targetEObjectUri.trimFragment == uri) 
				references.put(description.targetEObjectUri, description.sourceEObjectUri -> description.EReference)
		}
		
		override accept(EObject source, URI sourceURI, EReference eReference, int index, EObject targetOrProxy, URI targetURI) {
			if (targetURI.trimFragment == uri)
				references.put(targetURI, sourceURI -> eReference)
		}
		
	}
	
}