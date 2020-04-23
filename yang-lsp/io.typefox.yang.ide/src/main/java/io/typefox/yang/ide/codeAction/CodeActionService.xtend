package io.typefox.yang.ide.codeAction

import io.typefox.yang.validation.IssueCodes
import org.eclipse.emf.common.util.URI
import org.eclipse.lsp4j.Command
import org.eclipse.lsp4j.TextEdit
import org.eclipse.lsp4j.WorkspaceEdit
import org.eclipse.lsp4j.jsonrpc.messages.Either
import org.eclipse.xtext.ide.server.codeActions.ICodeActionService2

class CodeActionService implements ICodeActionService2 {
	
	static val COMMAND_ID = 'yang.apply.workspaceEdit'
	
	override getCodeActions(Options options) {
		val result = <Command>newArrayList
		for (d : options.codeActionParams.context.diagnostics) {
			if (d.code == IssueCodes.INCORRECT_VERSION) {
				result += createFix('Change to "1.1".', options.resource.URI, new TextEdit => [
					newText = "1.1"
					range = d.range
				])			
			}
		}
		return result.map[Either.forLeft(it)]
	}
	
	private def Command createFix(String title, URI uri, TextEdit... edits) {
		val textEdits = edits.toList
		val edit = new WorkspaceEdit => [
			changes.put(uri.toString, textEdits)
		]
		val result = new Command => [
			command = COMMAND_ID
			it.title = title
			arguments = #[edit]
		]
		return result
	}
	
}