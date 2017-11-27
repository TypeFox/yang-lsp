package io.typefox.yang.ide.extensions

import com.google.inject.Inject
import io.typefox.yang.settings.PreferenceValuesProvider
import io.typefox.yang.utils.ExtensionProvider
import java.util.List
import org.eclipse.lsp4j.ExecuteCommandParams
import org.eclipse.lsp4j.MessageParams
import org.eclipse.xtext.ide.server.ILanguageServerAccess
import org.eclipse.xtext.ide.server.commands.IExecutableCommandService
import org.eclipse.xtext.preferences.IPreferenceValuesProvider
import org.eclipse.xtext.preferences.PreferenceKey
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.IDisposable
import org.eclipse.xtext.util.internal.Log
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

@Log class CommandService implements IExecutableCommandService {
	
	static val KEY = new PreferenceKey("extension.commands", "")
	
	@Inject ExtensionProvider extensionProvider
	
	(String)=>IDisposable register
	
	List<IDisposable> registeredCommands = newArrayList
	ExecutorService service = Executors.newSingleThreadExecutor
	
	@Inject	def void registerPreferenceChangeListener(IPreferenceValuesProvider provider) {
		if (provider instanceof PreferenceValuesProvider) {
			provider.registerChangeListener[
				if (extensionProvider === null || register === null) {
					return
				}
				service.submit [
					Thread.sleep(1000)
					val extensions = extensionProvider.getExtensions(KEY, $1, ICommandExtension)
					try {
						registeredCommands.forEach[dispose]
					} catch (Exception e) {
						LOG.warn("Error unregistering commands : "+e.message)
						dispose()
						return
					}
					registeredCommands = newArrayList
					for (ext: extensions) {
						for (c : ext.commands) {
							try {
								val apply = register.apply(c)
								registeredCommands.add(apply)
							} catch (Exception e) {
								LOG.warn("Error registering commands : "+e.message)
								dispose()
								return
							}
						}
					}
				]
			]
		}
	}
	
	def dispose() {
		this.registeredCommands.clear
		this.register = null
	}
	
	override execute(ExecuteCommandParams params, ILanguageServerAccess access, CancelIndicator cancelIndicator) {
		val uri = params.arguments.head as String
		if (uri !== null) {
			access.doRead(uri) [
				val commands = extensionProvider.getExtensions(KEY, resource, ICommandExtension)
				for (c : commands) {
					if (c.commands.contains(params.command)) {
						try {						
							c.executeCommand(params.command, resource, access.languageClient)
						} catch (Exception e) {
							access.languageClient.showMessage(new MessageParams => [
								message = '''
									Couldn't execute command '«c»'.
									
									Error : «e.message»
									Stack Trace : 
										«FOR traceElement : e.stackTrace»
											«traceElement.toString»
										«ENDFOR»
								'''
							])
						}
					}				
				}
				return null;
			].get
		}
	}
	
	override initialize() {
		return #[]
	}
	
	override void initializeDynamicRegistration((String)=>IDisposable register) {
		this.register = register
	}
	
}