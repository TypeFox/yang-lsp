package io.typefox.yang.diagram

import io.typefox.sprotty.api.HtmlRoot
import io.typefox.sprotty.api.IDiagramServer
import io.typefox.sprotty.api.IPopupModelFactory
import io.typefox.sprotty.api.PreRenderedElement
import io.typefox.sprotty.api.RequestPopupModelAction
import io.typefox.sprotty.api.SModelElement
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.YangVersion
import java.util.ArrayList

class YangPopupModelFactory implements IPopupModelFactory {

	override createPopupModel(SModelElement element, RequestPopupModelAction request, IDiagramServer server) {
		if (element instanceof YangNode) {
			val statement = element.source
			if (statement !== null)
				createPopup(statement, element, request)
		}
	}

	protected def createPopup(Statement stmt, SModelElement element, RequestPopupModelAction request) {
		val popupId = element.id + '-popup'
		val infos = new ArrayList<Pair<String, String>>

		for (statement : stmt.substatements) {
			val info = createHtml(statement)
			if(info !== null) infos.add(info)
		}
		if (!infos.empty)
			new HtmlRoot [
				type = 'html'
				id = popupId
				children = #[
					new PreRenderedElement [
						type = 'pre-rendered'
						id = popupId + '-body'
						code = '''
							<div class="infoBlock">
								«FOR info : infos»
									<div class="infoRow">
										<div class="infoTitle">«info.key»:</div>
										<div class="infoText">«info.value»</div>
									</div>
								«ENDFOR»
							</div>
						'''
					]
				]
				canvasBounds = request.bounds
			]
			
	}

	protected def dispatch Pair<String, String> createHtml(Statement statement) {
	}

	protected def dispatch Pair<String, String> createHtml(Prefix prefixStmt) {
		'Prefix' -> prefixStmt.prefix
	}

	protected def dispatch Pair<String, String> createHtml(Namespace namespaceStmt) {
		'Namespace' -> namespaceStmt.uri
	}

	protected def dispatch Pair<String, String> createHtml(YangVersion yangVersionStmt) {
		'Yang version' -> yangVersionStmt.yangVersion
	}

	protected def dispatch Pair<String, String> createHtml(Description descriptionStmt) {
		'Description' -> descriptionStmt.description
	}

}
