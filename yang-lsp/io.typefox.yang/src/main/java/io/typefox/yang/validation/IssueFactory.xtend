package io.typefox.yang.validation

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.validation.Issue.IssueImpl
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.emf.ecore.util.EcoreUtil

class IssueFactory {
	
	static def Issue createIssue(EObject obj, EStructuralFeature feature, Severity severity, String message, String code) {
		val nodes = NodeModelUtils.findNodesForFeature(obj, feature)
		val lineAndOffset = NodeModelUtils.getLineAndColumn(nodes.head, nodes.head.offset)
		val result = new IssueImpl
		result.message = message
		result.code = code
		result.lineNumber = lineAndOffset.line
		result.column = lineAndOffset.column
		result.length = nodes.map[length].reduce[p1, p2| p1 + p2]
		result.severity = severity
		result.uriToProblem = EcoreUtil.getURI(obj)
		return result
	}

	static def Issue createIssue(EObject obj, EStructuralFeature feature, String message, String code) {
		createIssue(obj, feature, Severity.ERROR, message, code)
	}
}