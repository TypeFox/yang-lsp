package io.typefox.yang.ide.completion

import com.google.inject.Inject
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistEntry
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalAcceptor

/**
 * Customized content proposal acceptor that automatically accepts all 
 * available template proposals for a particular keyword entry and disregards the
 * keyword entry.
 * 
 * @author akos.kitta
 */
class YangContentProposalAcceptor extends IdeContentProposalAcceptor {

	@Inject
	YangTemplateProposalProvider templateProposalProvider;

	override accept(ContentAssistEntry entry, int priority) {
		val templates = templateProposalProvider.getTemplateEntry(entry);
		if (templates.nullOrEmpty) {
			super.accept(entry, priority);
		} else {
			templates.forEach [
				super.accept(it, priority);
			];
		}
	}

}
