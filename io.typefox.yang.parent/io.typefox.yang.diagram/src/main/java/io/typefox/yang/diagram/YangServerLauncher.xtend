/*
 * Copyright (C) 2017 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import com.google.inject.Guice
import com.google.inject.Inject
import io.typefox.sprotty.server.json.ActionTypeAdapter
import io.typefox.yang.YangRuntimeModule
import io.typefox.yang.ide.YangIdeModule
import io.typefox.yang.ide.YangIdeSetup
import java.io.InputStream
import java.io.OutputStream
import java.io.PrintWriter
import java.util.LinkedHashMap
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.function.Function
import org.apache.log4j.FileAppender
import org.apache.log4j.Logger
import org.eclipse.lsp4j.jsonrpc.Launcher
import org.eclipse.lsp4j.jsonrpc.MessageConsumer
import org.eclipse.lsp4j.jsonrpc.RemoteEndpoint
import org.eclipse.lsp4j.jsonrpc.json.ConcurrentMessageProcessor
import org.eclipse.lsp4j.jsonrpc.json.JsonRpcMethod
import org.eclipse.lsp4j.jsonrpc.json.JsonRpcMethodProvider
import org.eclipse.lsp4j.jsonrpc.json.MessageJsonHandler
import org.eclipse.lsp4j.jsonrpc.json.StreamMessageConsumer
import org.eclipse.lsp4j.jsonrpc.json.StreamMessageProducer
import org.eclipse.lsp4j.jsonrpc.services.ServiceEndpoints
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
	
	override start(LaunchArgs it) {
		val launcher = createLauncher(languageServer, LanguageClient, in, out, validate, trace)
		languageServer.connect(launcher.remoteProxy)
		val future = launcher.startListening
		while (!future.done) {
			Thread.sleep(10_000l)
		}
	}
	
	/**
	 * Copied from {@link org.eclipse.lsp4j.jsonrpc.Launcher} to customize the JSON handler.
	 * https://github.com/eclipse/lsp4j/issues/105
	 */
	def <T> Launcher<T> createLauncher(Object localService, Class<T> remoteInterface, InputStream in, OutputStream out, boolean validate, PrintWriter trace) {
		val Function<MessageConsumer, MessageConsumer> wrapper = [ consumer |
			var result = consumer
			if (trace !== null) {
				result = [ message |
					trace.println(message)
					trace.flush()
					consumer.consume(message)
				]
			}
			if (validate) {
				result = new ReflectiveMessageValidator(result)
			}
			return result
		]
		return createIoLauncher(localService, remoteInterface, in, out, Executors.newCachedThreadPool(), wrapper);
	}
	
	/**
	 * Copied from {@link org.eclipse.lsp4j.jsonrpc.Launcher} to customize the JSON handler.
	 * https://github.com/eclipse/lsp4j/issues/105
	 */
	def <T> Launcher<T> createIoLauncher(Object localService, Class<T> remoteInterface, InputStream in, OutputStream out, ExecutorService executorService, Function<MessageConsumer, MessageConsumer> wrapper) {
		val supportedMethods = new LinkedHashMap<String, JsonRpcMethod>
		supportedMethods.putAll(ServiceEndpoints.getSupportedMethods(remoteInterface))
		
		if (localService instanceof JsonRpcMethodProvider) {
			supportedMethods.putAll(localService.supportedMethods)
		} else {
			supportedMethods.putAll(ServiceEndpoints.getSupportedMethods(localService.class))
		}
		
		val jsonHandler = new MessageJsonHandler(supportedMethods) {
			override getDefaultGsonBuilder() {
				val gsonBuilder = super.defaultGsonBuilder
				ActionTypeAdapter.configureGson(gsonBuilder)
				return gsonBuilder
			}
		}
		val outGoingMessageStream = wrapper.apply(new StreamMessageConsumer(out, jsonHandler))
		val serverEndpoint = new RemoteEndpoint(outGoingMessageStream, ServiceEndpoints.toEndpoint(localService))
		jsonHandler.methodProvider = serverEndpoint
		val messageConsumer = wrapper.apply(serverEndpoint)
		val reader = new StreamMessageProducer(in, jsonHandler)
		
		val T theRemoteProxy = ServiceEndpoints.toServiceObject(serverEndpoint, remoteInterface)
		
		return new Launcher<T> () {
			override startListening() {
				return ConcurrentMessageProcessor.startProcessing(reader, messageConsumer, executorService)
			}

			override getRemoteProxy() {
				return theRemoteProxy
			}
		}
	}
	
}
