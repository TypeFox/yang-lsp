package io.typefox.yang.scoping

import com.google.inject.Inject
import io.typefox.yang.parser.antlr.lexer.jflex.YangFix
import io.typefox.yang.validation.LinkingErrorMessageProvider
import io.typefox.yang.yang.SchemaNodeIdentifier
import io.typefox.yang.yang.impl.XpathNameTestImpl
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.InternalEObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.linking.impl.LinkingHelper
import org.eclipse.xtext.linking.lazy.LazyURIEncoder
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription

class Linker {

	@Inject LinkingHelper linkingHelper
	@Inject LazyURIEncoder lazyURIEncoder
	@Inject IQualifiedNameConverter qualifiedNameConverter

	public static final IEObjectDescription ROOT = new EObjectDescription(QualifiedName.EMPTY, null, null)

	def <T> T link(EObject element, EReference reference, (QualifiedName)=>IEObjectDescription resolver) {
		val proxy = element.eGet(reference, false) as EObject
		if (proxy !== null && (!proxy.eIsProxy || LinkingErrorMessageProvider.isOK(proxy)))
			return proxy as T
		val qname = getLinkingName(element, reference)
		if (qname !== null) {
			val candidate = resolver.apply(qname)
			if (candidate === ROOT) {
				LinkingErrorMessageProvider.markOK(element)
			} else if (candidate !== null) {
				val resolved = EcoreUtil.resolve(candidate.getEObjectOrProxy, element)
				if(reference.EType.isInstance(resolved)) {
					element.eSet(reference, resolved) // replace SchemaNode with linked value (e.g. Leaf, List)
					return resolved as T
				}
			}
		}
		return element.eGet(reference, false) as InternalEObject as T
	}
	
	
	def QualifiedName getLinkingName(EObject element, EReference reference) {
		val proxy = element.eGet(reference, false) as InternalEObject
		if (proxy !== null) {
			val concatinationExtractor = [ String it |
				var modified = it?.trim() // remove spaces from hidden tokens
				val concatMatcher = YangFix.CONCAT_PATTERN.matcher(modified)
				if (concatMatcher.find)
					modified = concatMatcher.replaceAll("")
				return modified
			]
			if (proxy.eIsProxy) {
				val uri = proxy.eProxyURI
				if (uri.trimFragment == element.eResource.getURI &&
					lazyURIEncoder.isCrossLinkFragment(element.eResource, uri.fragment)) {
					val node = lazyURIEncoder.getNode(element, uri.fragment)
					val symbol = linkingHelper.getCrossRefNodeAsString(node, true)
					if(symbol.nullOrEmpty) {
						return null
					}
					var simpleName = qualifiedNameConverter.toQualifiedName(symbol)
					if (element instanceof XpathNameTestImpl || element instanceof SchemaNodeIdentifier) {
						simpleName = QualifiedName.create(simpleName.segments.map(concatinationExtractor).toList)// remove possible HIDDEN tokens (ID["+]["]ID)
					}
					if (element instanceof XpathNameTestImpl) {
						if(element.prefix !== null) 
							return qualifiedNameConverter.toQualifiedName(element.prefix).append(simpleName)		
					}
					return simpleName;
				} else {
					// regular proxy let's resolve here
					element.eGet(reference, true)
				}
			} else {
				val symbol = NodeModelUtils.findNodesForFeature(element, reference).map[leafNodes.filter[!isHidden].map[getText].join("")].join("")
				if (!symbol.empty) {
					val qName = qualifiedNameConverter.toQualifiedName(symbol)
					return QualifiedName.create(qName.segments.map(concatinationExtractor).toList)
				} 
			}
		}
		return null
	}
}
