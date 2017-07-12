package io.typefox.yang.diagram

import com.google.inject.Guice
import io.typefox.sprotty.layout.ElkLayoutEngine
import io.typefox.yang.YangRuntimeModule
import io.typefox.yang.ide.YangIdeModule
import io.typefox.yang.ide.YangIdeSetup
import java.net.InetSocketAddress
import java.nio.channels.AsynchronousServerSocketChannel
import java.nio.channels.Channels
import java.util.concurrent.Executors
import org.eclipse.elk.alg.layered.options.LayeredOptions
import org.eclipse.lsp4j.services.LanguageClient
import org.eclipse.xtext.ide.server.LanguageServerImpl
import org.eclipse.xtext.ide.server.ServerModule
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.util.Modules2

class RunSocketServer {

	def static void main(String[] args) throws Exception {
		
		ElkLayoutEngine.initialize(new LayeredOptions)
		
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
			val launcher = YangServerLauncher.createIoLauncher(languageServer, LanguageClient, in, out, threadPool, [it])
			languageServer.connect(launcher.remoteProxy)
			launcher.startListening
			println("Started Language server.")
		}
	}
}