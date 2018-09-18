package io.typefox.yang.ide.codeAction

import io.typefox.yang.validation.IssueCodes
import org.eclipse.emf.common.util.URI
import org.eclipse.lsp4j.CodeActionParams
import org.eclipse.lsp4j.Command
import org.eclipse.lsp4j.TextEdit
import org.eclipse.lsp4j.WorkspaceEdit
import org.eclipse.xtext.ide.server.Document
import org.eclipse.xtext.ide.server.codeActions.ICodeActionService
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.lsp4j.jsonrpc.messages.Either

class CodeActionService implements ICodeActionService {
	
	static val COMMAND_ID = 'yang.apply.workspaceEdit'
	
	override getCodeActions(Document document, XtextResource resource, CodeActionParams params, CancelIndicator indicator) {
		val result = <Command>newArrayList
		for (d : params.context.diagnostics) {
			if (d.code == IssueCodes.INCORRECT_VERSION) {
				result += createFix('Change to "1.1".', resource.URI, new TextEdit => [
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