package io.typefox.yang.documentation

import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Statement
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider

class DocumentationProvider implements IEObjectDocumentationProvider {
	
	def dispatch getDocumentation(EObject o) {
		return null
	}
	
	def dispatch getDocumentation(Statement o) {
		val description = o.substatements.filter(Description).head
		if (description === null) {
			return null
		}
		
		return description.description.split('\\n').map[trim].join("\n")
	}
	
}