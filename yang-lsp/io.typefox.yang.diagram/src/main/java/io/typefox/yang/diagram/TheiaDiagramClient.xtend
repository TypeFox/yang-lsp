package io.typefox.yang.diagram

import io.typefox.sprotty.server.xtext.DiagramEndpoint
import org.eclipse.lsp4j.Location
import org.eclipse.lsp4j.jsonrpc.services.JsonNotification
import org.eclipse.lsp4j.jsonrpc.services.JsonSegment

@JsonSegment('diagram')
interface TheiaDiagramClient extends DiagramEndpoint {
	
	@JsonNotification
	def void openInTextEditor(Location location)
	
}