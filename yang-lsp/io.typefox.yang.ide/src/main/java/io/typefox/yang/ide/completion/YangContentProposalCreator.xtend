package io.typefox.yang.ide.completion

import org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistEntry
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalCreator

import static extension io.typefox.yang.ide.completion.ContentAssistEntryUtils.attachSourceIfAbsent

/**
 * Content proposal creator for YANG.
 * 
 * <p>
 * Sets the {@link ContentAssistEntry#getSource() source} EObject (based on the
 * {@link ContentAssistContext#getCurrentModel() current model} of the content
 * assist content) on the content assist entry to be able to reuse it for
 * temples. For instance to be able to get the name of the containing resource.
 * 
 * @author akos.kitta
 */
class YangContentProposalCreator extends IdeContentProposalCreator {

	/**
	 * Besides doing exactly what described at {@link IdeContentProposalCreator} the super class,
	 * it tries to set the source of the entry. If the current model of the content is not {@code null}
	 * it sets on the entry. If the current module is {@code null} (consider an empty YANG file), then sets
	 * the resource as the source. 
	 */
	override ContentAssistEntry createProposal(String proposal, String prefix, ContentAssistContext context,
		String kind, (ContentAssistEntry)=>void init) {

		return super.createProposal(proposal, prefix, context, kind, init).attachSourceIfAbsent(context);
	}

}
