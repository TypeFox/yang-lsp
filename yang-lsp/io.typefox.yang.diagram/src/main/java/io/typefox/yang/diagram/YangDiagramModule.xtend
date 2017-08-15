/*
 * Copyright (C) 2017 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import io.typefox.sprotty.server.xtext.DefaultDiagramModule
import io.typefox.sprotty.server.xtext.IDiagramGenerator
import org.eclipse.xtext.ide.server.occurrences.IDocumentHighlightService

class YangDiagramModule extends DefaultDiagramModule {
	
	def Class<? extends IDocumentHighlightService> bindIDocumentHighlightService() {
		YangHighlightService
	}
	
	override bindILanguageServerExtension() {
		YangLanguageServerExtension
	}
	
	override bindIDiagramServerProvider() {
		YangLanguageServerExtension
	}
	
	override bindILayoutEngine() {
		YangLayoutEngine
	}
	
	def Class<? extends IDiagramGenerator> bindIDiagramGenerator() {
		YangDiagramGenerator
	}
	
	override bindIPopupModelFactory() {
		YangPopupModelFactory
	}
	
	override bindIDiagramSelectionListener() {
		YangDiagramSelectionListener
	}
	
}
