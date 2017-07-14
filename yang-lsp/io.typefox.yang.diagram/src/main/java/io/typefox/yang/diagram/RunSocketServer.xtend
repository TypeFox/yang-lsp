/*
 * Copyright (C) 2017 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import com.google.gson.GsonBuilder
import com.google.inject.Guice
import io.typefox.sprotty.layout.ElkLayoutEngine
import io.typefox.sprotty.server.json.ActionTypeAdapter
import io.typefox.yang.YangRuntimeModule
import io.typefox.yang.ide.YangIdeModule
import io.typefox.yang.ide.YangIdeSetup
import java.net.InetSocketAddress
import java.nio.channels.AsynchronousServerSocketChannel
import java.nio.channels.Channels
import java.util.concurrent.Executors
import java.util.function.Consumer
import org.eclipse.elk.alg.layered.options.LayeredMetaDataProvider
import org.eclipse.lsp4j.jsonrpc.Launcher
import org.eclipse.lsp4j.services.LanguageClient
import org.eclipse.xtext.ide.server.LanguageServerImpl
import org.eclipse.xtext.ide.server.ServerModule
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.util.Modules2

class RunSocketServer {

	def static void main(String[] args) throws Exception {
		// Initialize ELK
		ElkLayoutEngine.initialize(new LayeredMetaDataProvider)
		
		// Do a manual setup that includes the Yang diagram module
		new YangIdeSetup {
			override createInjector() {
				Guice.createInjector(Modules2.mixin(new YangRuntimeModule, new YangIdeModule, new YangDiagramModule))
			}
		}.createInjectorAndDoEMFRegistration()
		
		val injector = Guice.createInjector(Modules2.mixin(new ServerModule, [
			bind(IResourceServiceProvider.Registry).toProvider(IResourceServiceProvider.Registry.RegistryProvider)
		]))
		val serverSocket = AsynchronousServerSocketChannel.open.bind(new InetSocketAddress("localhost", 5007))
		val threadPool = Executors.newCachedThreadPool()
		
		while (true) {
			var languageServer = injector.getInstance(LanguageServerImpl)
			val socketChannel = serverSocket.accept.get
			val in = Channels.newInputStream(socketChannel)
			val out = Channels.newOutputStream(socketChannel)
			val Consumer<GsonBuilder> configureGson = [ gsonBuilder |
				ActionTypeAdapter.configureGson(gsonBuilder)
			]
			val launcher = Launcher.createIoLauncher(languageServer, LanguageClient, in, out, threadPool, [it], configureGson)
			languageServer.connect(launcher.remoteProxy)
			launcher.startListening
			println("Started Language server.")
		}
	}
}