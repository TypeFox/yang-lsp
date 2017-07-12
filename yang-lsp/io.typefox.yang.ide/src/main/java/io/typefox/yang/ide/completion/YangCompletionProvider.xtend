package io.typefox.yang.ide.completion

import com.google.inject.Inject
import io.typefox.yang.scoping.ScopeContextProvider
import java.util.Collection
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.GrammarUtil
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ide.editor.contentassist.IIdeContentProposalAcceptor
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.xtext.CurrentTypeFinder

class YangCompletionProvider extends IdeContentProposalProvider {
	
	@Inject extension CurrentTypeFinder
	@Inject ScopeContextProvider scopeContextProvider
	
	override protected _createProposals(RuleCall ruleCall, ContentAssistContext context, IIdeContentProposalAcceptor acceptor) {
		if (ruleCall.rule.name == 'BUILTIN_TYPE') {
			for (kw : EcoreUtil.getAllContents(ruleCall.rule, false).filter(Keyword).toIterable) {
				createProposals(kw, context, acceptor)
			}
		}
	}
	
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
	
	override createProposals(Collection<ContentAssistContext> contexts, IIdeContentProposalAcceptor acceptor) {
		super.createProposals(contexts, acceptor)
	}
	
	override protected getCrossrefFilter(CrossReference reference, ContentAssistContext context) {
		val scopeCtx = scopeContextProvider.findScopeContext(context.currentModel)
		val localPrefix = scopeCtx.localPrefix
		// filter local qualified names out
		return [ IEObjectDescription desc |
			return desc.name.segmentCount == 1 || desc.name.firstSegment != localPrefix
		]
	}
	
}