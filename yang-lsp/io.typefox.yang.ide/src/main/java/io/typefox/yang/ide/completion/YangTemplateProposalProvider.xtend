package io.typefox.yang.ide.completion

import com.google.inject.Inject
import com.google.inject.Singleton
import io.typefox.yang.ide.completion.YangTemplateProvider.Template
import org.eclipse.xtext.formatting.IIndentationInformation
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistEntry

/**
 * Singleton template proposal provider for YANG.
 * 
 * @author akos.kitta
 */
@Singleton
class YangTemplateProposalProvider {

	@Inject
	extension YangTemplateProvider;
	
	@Inject
	extension IIndentationInformation;

	def Iterable<ContentAssistEntry> getTemplateEntry(ContentAssistEntry entry) {
		return if (entry?.kind == ContentAssistEntry.KIND_KEYWORD) {
			getTemplatesForKeyword(entry).map[toTemplate(entry)];
		} else {
			emptyList;
		}
	}

	private def toTemplate(Template template, ContentAssistEntry original) {
		new ContentAssistEntry() => [
			prefix = original.prefix;
			label = template.label;
			proposal = template.template.replaceAll('  ', indentString);
			description = template.description;
			documentation = template.documentation;
			kind = ContentAssistEntry.KIND_SNIPPET;
			source = original.source;
		];
	}

}
