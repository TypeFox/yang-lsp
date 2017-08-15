package io.typefox.yang.diagram

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.xtext.nodemodel.INode
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
	
	def TextRegion getSignificantRegion(EObject element) {
		val feature = element.relevantFeature
		if (feature !== null) 
			return NodeModelUtils.findNodesForFeature(element, feature).head.toTextRegion
		else 
			return NodeModelUtils.findActualNodeFor(element).toTextRegion
	}

	protected def toTextRegion(INode node) {
		val leafNodes = node.leafNodes.filter[!hidden]
		if(!leafNodes.empty) {
			var start = leafNodes.head.offset
			var end = leafNodes.last.endOffset
			return new TextRegion(start, end - start)
		}
	}	
	
	protected def EStructuralFeature getRelevantFeature(EObject element) {
		element.eClass.EAllAttributes.findFirst[name == 'name'] 
		?: element.eClass.EAllAttributes.findFirst[EAttributeType === EcorePackage.Literals.ESTRING]
		?: element.eClass.EAllReferences.findFirst[isContainment && upperBound === 1]
	}
}