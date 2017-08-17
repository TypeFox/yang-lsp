package io.typefox.yang.ide.extensions

import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.lsp4j.services.LanguageClient

interface ICommandExtension {
	
	/**
	 * Returns the commands that are contributed by this extension.
	 */
	def List<String> getCommands();
	
	/**
	 * Executes the given command.
	 */
	def void executeCommand(String command, Resource resource, LanguageClient client);
}