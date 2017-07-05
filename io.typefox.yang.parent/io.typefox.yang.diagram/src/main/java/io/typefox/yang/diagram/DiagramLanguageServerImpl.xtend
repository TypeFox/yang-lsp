/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import com.google.inject.Inject
import com.google.inject.Provider
import com.google.inject.Singleton
import io.typefox.sprotty.api.ActionMessage
import io.typefox.sprotty.api.IDiagramServer
import io.typefox.sprotty.api.LayoutUtil
import io.typefox.sprotty.api.SModelRoot
import io.typefox.yang.yang.YangFile
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.lsp4j.jsonrpc.Endpoint
import org.eclipse.lsp4j.jsonrpc.services.JsonNotification
import org.eclipse.lsp4j.jsonrpc.services.ServiceEndpoints
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.ide.server.ILanguageServerAccess
import org.eclipse.xtext.ide.server.ILanguageServerAccess.IBuildListener
import org.eclipse.xtext.ide.server.ILanguageServerExtension
import org.eclipse.xtext.ide.server.UriExtensions
import org.eclipse.xtext.resource.IResourceDescription.Delta
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator

class DiagramLanguageServerImpl implements DiagramEndpoint, ILanguageServerExtension, IDiagramServer.Provider, IBuildListener {
	
	@Inject extension IResourceValidator

	@Inject extension UriExtensions
	
	@Inject YangDiagramGenerator diagramGenerator
	
	@Inject Provider<IDiagramServer> diagramServerProvider
	
	val Map<String, IDiagramServer> diagramServers = newLinkedHashMap

	DiagramEndpoint _client

	extension ILanguageServerAccess languageServerAccess
	
	override initialize(ILanguageServerAccess access) {
		this.languageServerAccess = access
		access.addBuildListener(this)
	}

	protected def DiagramEndpoint getClient() {
		if (_client === null) {
			val client = languageServerAccess.languageClient
			if (client instanceof Endpoint) {
				_client = ServiceEndpoints.toServiceObject(client, DiagramEndpoint)
			}
		}
		return _client
	}
	
	override getDiagramServer(String clientId) {
		synchronized (diagramServers) {
			var server = diagramServers.get(clientId)
			if (server === null) {
				server = diagramServerProvider.get
				server.clientId = clientId
				server.remoteEndpoint = [ message |
					client?.accept(message)
				]
				diagramServers.put(clientId, server)
			}
			return server
		}
	}
	
	override void accept(ActionMessage message) {
		val server = getDiagramServer(message.clientId)
		server.accept(message)
	}

	override afterBuild(List<Delta> deltas) {
		for (uri : deltas.map[uri.toPath]) {
			uri.doRead [ context |
				context.resource?.generateDiagram(context.cancelChecker)
			].thenAccept[ newRoot |
				val server = getDiagramServer(uri)
				if (server.model !== null)
					LayoutUtil.copyLayoutData(server.model, newRoot)
				server.updateModel(newRoot)
			]
		}
	}
	
	protected def SModelRoot generateDiagram(Resource resource, CancelIndicator cancelIndicator) {
		if (!resource.hasErrors(cancelIndicator)) {
			val content = resource.contents.head
			if (content instanceof YangFile) {
				return diagramGenerator.generateDiagram(content, cancelIndicator)
			}
		}
	}
	
	private def boolean hasErrors(Resource resource, CancelIndicator cancelIndicator) {
		resource.validate(CheckMode.NORMAL_AND_FAST, cancelIndicator).exists [
			severity === Severity.ERROR
		]
	}

}
