package io.typefox.yang.diagram

import com.google.inject.Inject
import io.typefox.sprotty.api.HtmlRoot
import io.typefox.sprotty.api.IDiagramServer
import io.typefox.sprotty.api.IPopupModelFactory
import io.typefox.sprotty.api.PreRenderedElement
import io.typefox.sprotty.api.RequestPopupModelAction
import io.typefox.sprotty.api.SModelElement
import io.typefox.sprotty.server.xtext.tracing.ITraceProvider
import io.typefox.sprotty.server.xtext.tracing.Traceable
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.YangVersion
import java.util.ArrayList
import io.typefox.sprotty.server.xtext.ILanguageAwareDiagramServer

class YangPopupModelFactory implements IPopupModelFactory {

	@Inject extension ITraceProvider

	override createPopupModel(SModelElement element, RequestPopupModelAction request, IDiagramServer server) {
		if (element instanceof Traceable) {
			val future = element.withSource(server as ILanguageAwareDiagramServer) [ statement, context |
				if (statement instanceof Statement) 
					createPopup(statement, element, request)
				else
					null
			]
			future.get
		} else {
			null
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
									<div class="sprotty-infoRow">
										<div class="sprotty-infoTitle">«info.key»:</div>
										<div class="sprotty-infoText">«info.value»</div>
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
