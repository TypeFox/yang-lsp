package io.typefox.yang.ide.formatting

import com.google.inject.Inject
import java.util.List
import org.eclipse.lsp4j.FormattingOptions
import org.eclipse.lsp4j.TextEdit
import org.eclipse.xtext.formatting.IIndentationInformation
import org.eclipse.xtext.ide.server.Document
import org.eclipse.xtext.ide.server.formatting.FormattingService
import org.eclipse.xtext.preferences.MapBasedPreferenceValues
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.TextRegion
import com.google.common.base.Strings

class YangFormattingService extends FormattingService {
	
	@Inject IIndentationInformation indentationInformation
	
	override List<TextEdit> format(XtextResource resource, Document document, int offset, int length, FormattingOptions options) {
		var indent = indentationInformation.indentString
		if (options !== null) {
			if (options.insertSpaces) {
				indent = Strings.padEnd("", options.tabSize," ")
			}
		}
		val preferences = newHashMap
		preferences.put("indentation", indent)
		val replacements = format2(resource, new TextRegion(offset, length), new MapBasedPreferenceValues(preferences))
		return replacements.map [ r |
			document.toTextEdit(r.replacementText, r.offset, r.length)
		].<TextEdit>toList
	}
}