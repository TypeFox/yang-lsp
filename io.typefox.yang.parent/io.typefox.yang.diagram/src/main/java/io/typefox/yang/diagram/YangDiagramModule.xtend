/*
 * Copyright (C) 2017 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import com.google.inject.AbstractModule
import io.typefox.sprotty.api.DefaultDiagramServer
import io.typefox.sprotty.api.IDiagramSelectionListener
import io.typefox.sprotty.api.IDiagramServer
import io.typefox.sprotty.api.ILayoutEngine
import io.typefox.sprotty.api.IModelUpdateListener
import io.typefox.sprotty.api.IPopupModelFactory
import io.typefox.sprotty.layout.ElkLayoutEngine
import org.eclipse.xtext.ide.server.ILanguageServerExtension

class YangDiagramModule extends AbstractModule {
	
	override protected configure() {
		bind(ILanguageServerExtension).to(DiagramLanguageServerImpl)
		bind(IDiagramServer.Provider).to(DiagramLanguageServerImpl)
		bind(IDiagramServer).to(DefaultDiagramServer)
		bind(ILayoutEngine).to(ElkLayoutEngine)
		bind(IPopupModelFactory).to(IPopupModelFactory.NullImpl)
		bind(IModelUpdateListener).to(IModelUpdateListener.NullImpl)
		bind(IDiagramSelectionListener).to(IDiagramSelectionListener.NullImpl)
	}
	
}
