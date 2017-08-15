package io.typefox.yang.diagram

import io.typefox.sprotty.api.IDiagramSelectionListener
import io.typefox.sprotty.api.SelectAction
import io.typefox.sprotty.api.IDiagramServer
import io.typefox.sprotty.api.SModelIndex
import com.google.inject.Inject
import io.typefox.sprotty.server.xtext.LanguageAwareDiagramServer
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.ide.server.UriExtensions
import org.eclipse.lsp4j.Location
import org.eclipse.lsp4j.Range

class YangDiagramSelectionListener implements IDiagramSelectionListener {
	
	@Inject extension YangLanguageServerExtension
	
	@Inject extension UriExtensions
	
	override selectionChanged(SelectAction action, IDiagramServer server) {
		if(server instanceof LanguageAwareDiagramServer) {
			val languageServerExtension = server.languageServerExtension
			if(languageServerExtension instanceof YangLanguageServerExtension) {
				if(!action.deselectAll && action.selectedElementsIDs !== null && action.selectedElementsIDs.size === 1)  {
					val id = action.selectedElementsIDs.head
					val selectedElement = new SModelIndex(server.model).get(id)
					if (selectedElement instanceof Traceable) {
						val traceRegion = selectedElement.significantRegion
						if(traceRegion !== null) {							
							val uri = server.sourceUri
							if(uri !== null) {
								uri.findDiagramServersByUri.forEach[
									languageServerExtension.languageServerAccess.doRead(
										URI.createURI(uri).toPath, [ context |
									 		val start = context.document.getPosition(traceRegion.offset)
									 		val end = context.document.getPosition(traceRegion.offset + traceRegion.length)
									 		languageServerExtension.client.openInTextEditor(new Location(uri, new Range(start, end)))
									 		return null
										])
								 	]
							}
						}
					}
				}
			}
		}
	}
}