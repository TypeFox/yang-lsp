/*
 * Copyright (C) 2017-2020 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import com.google.inject.Inject
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.YangVersion
import java.util.ArrayList
import org.eclipse.sprotty.HtmlRoot
import org.eclipse.sprotty.IDiagramServer
import org.eclipse.sprotty.IPopupModelFactory
import org.eclipse.sprotty.PreRenderedElement
import org.eclipse.sprotty.RequestPopupModelAction
import org.eclipse.sprotty.SModelElement
import org.eclipse.sprotty.xtext.ILanguageAwareDiagramServer
import org.eclipse.sprotty.xtext.tracing.ITraceProvider

class YangPopupModelFactory implements IPopupModelFactory {

	@Inject extension ITraceProvider

	override createPopupModel(SModelElement element, RequestPopupModelAction request, IDiagramServer server) {
		val future = element.withSource(server as ILanguageAwareDiagramServer) [ statement, context |
			if (statement instanceof Statement) 
				createPopup(statement, element, request)
		]
		future.get
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
