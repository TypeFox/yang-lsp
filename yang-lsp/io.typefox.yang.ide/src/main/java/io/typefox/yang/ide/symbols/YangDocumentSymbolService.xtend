package io.typefox.yang.ide.symbols

import com.google.inject.Inject
import org.eclipse.xtext.findReferences.IReferenceFinder.IResourceAccess
import org.eclipse.xtext.ide.server.DocumentExtensions
import org.eclipse.xtext.ide.server.symbol.DocumentSymbolService
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.TextRegion

class YangDocumentSymbolService extends DocumentSymbolService {
	
	@Inject extension DocumentExtensions 
	@Inject EObjectAtOffsetHelper helper
	
	override getDefinitions(XtextResource resource, int offset, IResourceAccess resourceAccess, CancelIndicator cancelIndicator) {
		val node = helper.getCrossReferenceNode(resource, new TextRegion(offset,0))
		if (node !== null) {
			val element = helper.getCrossReferencedElement(node)
			if (element !== null) {
				return #[element.newLocation]
			}
		}
		return emptyList
	}
	
}