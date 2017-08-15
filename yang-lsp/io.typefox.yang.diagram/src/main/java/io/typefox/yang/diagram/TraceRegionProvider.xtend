package io.typefox.yang.diagram

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

class TraceRegionProvider {

	def TextRegion getTraceRegion(EObject element) {
		val node = NodeModelUtils.findActualNodeFor(element)
		if (node !== null) {
			val document = node.rootNode.text
			val leafNodes = node.leafNodes.filter[!hidden]
			if(!leafNodes.empty) {
				var start = leafNodes.head.offset
				while (start > 0 && document.charAt(start - 1) === 32) 
					start--
				var end = leafNodes.last.endOffset
				while(end < document.length && document.charAt(end) === 32)
					end++
				return new TextRegion(start, end - start)
			}
		}
		return null
	}
}