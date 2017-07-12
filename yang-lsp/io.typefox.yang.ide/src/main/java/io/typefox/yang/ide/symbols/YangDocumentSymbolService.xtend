package io.typefox.yang.ide.symbols

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.lsp4j.Location
import org.eclipse.xtext.findReferences.IReferenceFinder.IResourceAccess
import org.eclipse.xtext.ide.server.DocumentExtensions
import org.eclipse.xtext.ide.server.symbol.DocumentSymbolService
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator

class YangDocumentSymbolService extends DocumentSymbolService {
	
	@Inject extension DocumentExtensions 
	
	override getDefinitions(XtextResource resource, int offset, IResourceAccess resourceAccess, CancelIndicator cancelIndicator) {
		val node = NodeModelUtils.findLeafNodeAtOffset(resource.parseResult.rootNode, offset)
		val List<Location> result = newArrayList()
		if (node.semanticElement !== null) {
			for (ref: node.semanticElement.eClass.EAllReferences.filter[!containment]) {
				val nodes = NodeModelUtils.findNodesForFeature(node.semanticElement, ref)
				if (nodes !== null && !nodes.empty) {
					if (nodes.head.offset <= offset && nodes.last.endOffset >= offset ) {
						val EObject referenced = node.semanticElement.eGet(ref) as EObject
						result.add(referenced.newLocation)
					}
				}
			}
		}
		return result
	}
	
}