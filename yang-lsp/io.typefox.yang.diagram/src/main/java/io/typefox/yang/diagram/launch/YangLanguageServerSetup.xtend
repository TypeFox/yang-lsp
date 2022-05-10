/*
 * Copyright (C) 2020 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram.launch

import com.google.inject.Guice
import io.typefox.yang.YangRuntimeModule
import io.typefox.yang.diagram.YangDiagramModule
import io.typefox.yang.ide.YangIdeModule
import io.typefox.yang.ide.YangIdeSetup
import io.typefox.yang.ide.server.YangProjectManager
import java.util.logging.LogManager
import org.eclipse.elk.alg.layered.options.LayeredMetaDataProvider
import org.eclipse.elk.core.util.persistence.ElkGraphResourceFactory
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.sprotty.layout.ElkLayoutEngine
import org.eclipse.sprotty.xtext.launch.DiagramLanguageServerSetup
import org.eclipse.sprotty.xtext.ls.SyncDiagramServerModule
import org.eclipse.xtext.ide.server.ProjectManager
import org.eclipse.xtext.ide.server.ServerModule
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.util.Modules2

class YangLanguageServerSetup extends DiagramLanguageServerSetup {
	
	override setupLanguages() {
		try {
			LogManager.getLogManager().readConfiguration(
				this.getClass().getClassLoader().getResourceAsStream('server_logging.properties'));
		} catch (Throwable ex) {
		}
		// Initialize ELK
		ElkLayoutEngine.initialize(new LayeredMetaDataProvider)
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put('elkg', new ElkGraphResourceFactory)
		
		// Do a manual setup that includes the Yang diagram module
		new YangIdeSetup {
			override createInjector() {
				Guice.createInjector(Modules2.mixin(new YangRuntimeModule, new YangIdeModule, new YangDiagramModule))
			}
		}.createInjectorAndDoEMFRegistration()
	}

	override getLanguageServerModule() {
		Modules2.mixin(
			new ServerModule,
			new SyncDiagramServerModule,
			[
				bind(IResourceServiceProvider.Registry).toProvider(IResourceServiceProvider.Registry.RegistryProvider)
				bind(ProjectManager).to(YangProjectManager)
			]
		) 
	}
	
}