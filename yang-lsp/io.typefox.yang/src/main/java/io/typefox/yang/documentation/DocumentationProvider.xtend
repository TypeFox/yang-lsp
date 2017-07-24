package io.typefox.yang.documentation

import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.YangPackage
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.util.internal.Log
import com.google.inject.Singleton

@Log
@Singleton
class DocumentationProvider implements IEObjectDocumentationProvider {
	
	def dispatch getDocumentation(EObject o) {
		return null
	}
	
	def dispatch getDocumentation(Statement o) {
		val description = o.substatements.filter(Description).head
		if (description === null) {
			return null
		}
		val node = NodeModelUtils.findNodesForFeature(description, YangPackage.Literals.DESCRIPTION__DESCRIPTION).head
		if (node === null) {
			return null
		}
		try {
			val column = NodeModelUtils.getLineAndColumn(node, node.offset).column
			val result = new StringBuilder
			var lineNo = 0
			for (line : description.description.split('\\n')) {
				if (lineNo === 0) {			
					result.append(line)
				} else {
					var substrStart = 0
					for (;substrStart < line.length && substrStart < column && Character.isWhitespace(line.charAt(substrStart));substrStart++) {}
					result.append("\n")
					result.append(line.substring(substrStart))
				}
				lineNo++
			}
			return result.toString		
		} catch (Exception e) {
			LOG.info('''Couldn't obtain documentatio for node «o» («e.class.simpleName» : «e.message»)''')
			return null
		}
	}
	
}