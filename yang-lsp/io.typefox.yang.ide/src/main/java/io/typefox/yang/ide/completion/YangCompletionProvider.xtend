package io.typefox.yang.ide.completion

import com.google.inject.Inject
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.GrammarUtil
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ide.editor.contentassist.IIdeContentProposalAcceptor
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider
import org.eclipse.xtext.xtext.CurrentTypeFinder

class YangCompletionProvider extends IdeContentProposalProvider {
	
	@Inject extension CurrentTypeFinder
	
	override protected _createProposals(CrossReference reference, ContentAssistContext context, IIdeContentProposalAcceptor acceptor) {
		val type = findCurrentTypeAfter(reference)
		if (type instanceof EClass) {
			val ereference = GrammarUtil.getReference(reference, type)
			val currentModel = context.currentModel
			if (ereference !== null && currentModel !== null) {
				val scope = scopeProvider.getScope(currentModel, ereference)
				crossrefProposalProvider.lookupCrossReference(scope, reference, context, acceptor,
					getCrossrefFilter(reference, context))
			}
		}
	}
	
}