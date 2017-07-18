package io.typefox.yang.diagram

import io.typefox.sprotty.api.HtmlRoot
import io.typefox.sprotty.api.IDiagramServer
import io.typefox.sprotty.api.IPopupModelFactory
import io.typefox.sprotty.api.PreRenderedElement
import io.typefox.sprotty.api.RequestPopupModelAction
import io.typefox.sprotty.api.SModelElement
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.YangVersion

class YangPopupModelFactory implements IPopupModelFactory {

	override createPopupModel(SModelElement element, RequestPopupModelAction request, IDiagramServer server) {
		if (element instanceof YangPopupNode) {
			val statement = element.source
			createPopup(statement, element)
		}
	}

	protected def createPopup(Statement statement, SModelElement element) {
		val popupId = element.id + '-popup'
		new HtmlRoot [
			type = 'html'
			id = popupId
			children = #[
				new PreRenderedElement [
					type = 'pre-rendered'
					id = popupId + '-body'
					code = '''
						<div>
							<span style="font-weight:bold;">Title:</span> some information
						</div>
					'''
				]
			]
		]
	}

	protected def dispatch SModelElement generateElement(Prefix prefixStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Namespace namespaceStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(YangVersion yangVersionStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

}
