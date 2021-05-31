package io.typefox.yang.resource

import com.google.inject.Inject
import io.typefox.yang.scoping.ScopeContextProvider
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.YangPackage
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.linking.lazy.LazyLinkingResource
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.util.Triple
import org.eclipse.xtext.util.internal.Log

@Log
class YangResource extends LazyLinkingResource {
	
	@Inject ScopeContextProvider provider
	
	override protected getEObject(String uriFragment, Triple<EObject, EReference, INode> triple) throws AssertionError {
		// ensure proper initialization
		try {
			val ctx = provider.getScopeContext(this.contents.head as AbstractModule)
			switch triple.second.EReferenceType {
				case YangPackage.Literals.SCHEMA_NODE,
				case YangPackage.Literals.LEAF :
					ctx.resolveAll
				default:
					ctx.resolveDefinitionPhase // does definition linking
			}
			val result = triple.first.eGet(triple.second, false)
			if (result instanceof EObject && !(result as EObject).eIsProxy) {
				return result as EObject;
			}
		} catch (IllegalStateException e) {
			LOG.error('''Failed to resolve fragment «uriFragment» in resource «URI.toString»''', e)
		}
		super.getEObject(uriFragment, triple)
	}
	
}