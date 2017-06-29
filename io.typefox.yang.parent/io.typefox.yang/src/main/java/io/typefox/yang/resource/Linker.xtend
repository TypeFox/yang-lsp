package io.typefox.yang.resource

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.InternalEObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.linking.impl.LinkingHelper
import org.eclipse.xtext.linking.impl.XtextLinkingDiagnostic
import org.eclipse.xtext.linking.lazy.LazyURIEncoder
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.XtextResource

class Linker {

	@Inject LinkingHelper linkingHelper
	@Inject LazyURIEncoder lazyURIEncoder
	@Inject IQualifiedNameConverter qualifiedNameConverter

	protected def addLinkingIssue(XtextResource resource, INode node, String errorMessage) {
		val list = resource.errors
		val diagnostic = new XtextLinkingDiagnostic(node, errorMessage, XtextLinkingDiagnostic.LINKING_DIAGNOSTIC)
		if (!list.contains(diagnostic))
			list.add(diagnostic)
	}

	def <T> T link(EObject element, EReference reference, (QualifiedName)=>IEObjectDescription resolver) {
		val proxy = element.eGet(reference, false) as InternalEObject
		if (proxy !== null && proxy.eIsProxy) {
			val uri = proxy.eProxyURI
			if (uri.trimFragment == element.eResource.getURI &&
				lazyURIEncoder.isCrossLinkFragment(element.eResource, uri.fragment)) {
				val node = lazyURIEncoder.getNode(element, uri.fragment)
				val symbol = linkingHelper.getCrossRefNodeAsString(node, true)
				val candidate = resolver.apply(qualifiedNameConverter.toQualifiedName(symbol))
				if (candidate !== null) {
					val resolved = EcoreUtil.resolve(candidate.getEObjectOrProxy, element)
					element.eSet(reference, resolved)
					return resolved as T
				} else {
					addLinkingIssue(element.eResource as XtextResource, node, "Unknown symbol '" + symbol + "'.")
					(element.eResource as YangResource).unresolvableURIFragments.add(uri.fragment)
				}
			}
		}
		return null
	}

}
