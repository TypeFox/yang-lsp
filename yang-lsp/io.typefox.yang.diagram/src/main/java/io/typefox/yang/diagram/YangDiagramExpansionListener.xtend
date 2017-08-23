package io.typefox.yang.diagram

import io.typefox.sprotty.api.CollapseExpandAction
import io.typefox.sprotty.api.IDiagramExpansionListener
import io.typefox.sprotty.api.IDiagramServer
import io.typefox.sprotty.server.xtext.LanguageAwareDiagramServer

class YangDiagramExpansionListener implements IDiagramExpansionListener {
	
	override expansionChanged(CollapseExpandAction action, IDiagramServer server) {
		if (server instanceof LanguageAwareDiagramServer) {
			val languageServerExtension = server.languageServerExtension
			languageServerExtension.updateDiagram(server)
		}
	}
}