package io.typefox.yang.ide.completion

import com.google.inject.Inject
import com.google.inject.Singleton
import io.typefox.yang.documentation.DocumentationProvider
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistEntry
import org.eclipse.xtext.ide.editor.contentassist.IdeCrossrefProposalProvider
import org.eclipse.xtext.resource.IEObjectDescription

/**
 * Cross reference proposal provider implementation that attaches a documentation 
 * to the content assist entry. The attached documentation is extracted for all the 
 * cross-references YANG statements that have the {@code description} sub-statement.
 * 
 * @author akos.kitta
 */
@Singleton
class YangCrossrefProposalProvider extends IdeCrossrefProposalProvider {

	@Inject
	extension DocumentationProvider;

	protected override ContentAssistEntry createProposal(IEObjectDescription candidate, CrossReference crossRef,
		ContentAssistContext context) {

		proposalCreator.createProposal(qualifiedNameConverter.toString(candidate.name), context) [
			source = candidate;
			description = candidate.getEClass?.name;
			documentation = candidate.EObjectOrProxy.documentation;
		];
	}

}
