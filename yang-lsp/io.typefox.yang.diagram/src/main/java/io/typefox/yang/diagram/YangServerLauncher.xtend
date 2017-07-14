/*
 * Copyright (C) 2017 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import com.google.gson.GsonBuilder
import com.google.inject.Guice
import com.google.inject.Inject
import io.typefox.sprotty.layout.ElkLayoutEngine
import io.typefox.sprotty.server.json.ActionTypeAdapter
import io.typefox.yang.YangRuntimeModule
import io.typefox.yang.ide.YangIdeModule
import io.typefox.yang.ide.YangIdeSetup
import java.util.concurrent.Executors
import java.util.function.Consumer
import java.util.function.Function
import org.apache.log4j.FileAppender
import org.apache.log4j.Logger
import org.eclipse.elk.alg.layered.options.LayeredMetaDataProvider
import org.eclipse.lsp4j.jsonrpc.Launcher
import org.eclipse.lsp4j.jsonrpc.MessageConsumer
import org.eclipse.lsp4j.jsonrpc.validation.ReflectiveMessageValidator
import org.eclipse.lsp4j.services.LanguageClient
import org.eclipse.xtext.ide.server.LanguageServerImpl
import org.eclipse.xtext.ide.server.LaunchArgs
import org.eclipse.xtext.ide.server.ServerLauncher
import org.eclipse.xtext.ide.server.ServerModule
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.util.Modules2

class YangServerLauncher extends ServerLauncher {
	
	def static void main(String[] args) {
		// Redirect Log4J output to a file
		Logger.rootLogger => [
			val defaultAppender = getAppender('default')
			removeAllAppenders()
			addAppender(new FileAppender(defaultAppender.layout, 'yang-server.log', false))
		]

		// Initialize ELK
		ElkLayoutEngine.initialize(new LayeredMetaDataProvider)

		// Do a manual setup that includes the Yang diagram module
		new YangIdeSetup {
			override createInjector() {
				Guice.createInjector(Modules2.mixin(new YangRuntimeModule, new YangIdeModule, new YangDiagramModule))
			}
		}.createInjectorAndDoEMFRegistration()
		
		// Launch the server
		launch(ServerLauncher.name, args, Modules2.mixin(new ServerModule, [
			bind(ServerLauncher).to(YangServerLauncher)
			bind(IResourceServiceProvider.Registry).toProvider(IResourceServiceProvider.Registry.RegistryProvider)
		]))
	}

	@Inject LanguageServerImpl languageServer
	
	override start(LaunchArgs args) {
		val executorService = Executors.newCachedThreadPool
		val Consumer<GsonBuilder> configureGson = [ gsonBuilder |
			ActionTypeAdapter.configureGson(gsonBuilder)
		]
		val launcher = Launcher.createIoLauncher(languageServer, LanguageClient, args.in, args.out, executorService,
				args.wrapper, configureGson)
		languageServer.connect(launcher.remoteProxy)
		val future = launcher.startListening
		while (!future.done) {
			Thread.sleep(10_000l)
		}
	}
	
	private def Function<MessageConsumer, MessageConsumer> getWrapper(LaunchArgs args) {
		[ consumer |
			var result = consumer
			if (args.trace !== null) {
				result = [ message |
					args.trace.println(message)
					args.trace.flush()
					consumer.consume(message)
				]
			}
			if (args.validate) {
				result = new ReflectiveMessageValidator(result)
			}
			return result
		]
	}
	
}
