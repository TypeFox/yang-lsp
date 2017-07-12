package io.typefox.yang.ide.completion

import com.google.inject.Inject
import io.typefox.yang.scoping.ScopeContextProvider
import io.typefox.yang.yang.SchemaNodeIdentifier
import io.typefox.yang.yang.YangPackage
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
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.xtext.CurrentTypeFinder

class YangCompletionProvider extends IdeContentProposalProvider {
	
	@Inject extension CurrentTypeFinder
	@Inject ScopeContextProvider scopeContextProvider

	override protected _createProposals(RuleCall ruleCall, ContentAssistContext context,
		IIdeContentProposalAcceptor acceptor) {
		if (ruleCall.rule.name == 'BUILTIN_TYPE') {
			for (kw : EcoreUtil.getAllContents(ruleCall.rule, false).filter(Keyword).toIterable) {
				createProposals(kw, context, acceptor)
			}
		}
	}

	override protected _createProposals(CrossReference reference, ContentAssistContext context,
		IIdeContentProposalAcceptor acceptor) {
		val type = findCurrentTypeAfter(reference)
		if (type instanceof EClass) {
			val ereference = GrammarUtil.getReference(reference, type)
			val currentModel = context.currentModel
			if (ereference !== null && currentModel !== null) {
				if (YangPackage.Literals.SCHEMA_NODE_IDENTIFIER__SCHEMA_NODE === ereference) {
					computeIdentifierRefProposals(reference, context, acceptor)
				} else {
					val scope = scopeProvider.getScope(currentModel, ereference)

					crossrefProposalProvider.lookupCrossReference(scope, reference, context, acceptor,
						getCrossrefFilter(reference, context))
				}
			}
		}
	}

	private def QualifiedName computeNodeSchemaPrefix(ContentAssistContext context, IScope nodeScope) {
		if (context.currentModel instanceof SchemaNodeIdentifier) {
			val identifier =  context.currentModel as SchemaNodeIdentifier
			if (identifier.target === null || identifier.target.schemaNode.eIsProxy) {
				return QualifiedName.EMPTY;
			}
			val desc = nodeScope.getSingleElement(identifier.target.schemaNode)
			if (desc !== null) {
				return desc.name
			}
		}
		return QualifiedName.EMPTY
	}

	def computeIdentifierRefProposals(CrossReference reference, ContentAssistContext context,
		IIdeContentProposalAcceptor acceptor) {

		val scopeCtx = scopeContextProvider.findScopeContext(context.currentModel)
		val nodeScope = scopeCtx.nodeScope
		val prefix = computeNodeSchemaPrefix(context, nodeScope)

		for (e : nodeScope.allElements.filter[name.startsWith(prefix)]) {
			val suffix = e.name.skipFirst(prefix.segmentCount)
			var name = new StringBuilder()
			for (var i = 0; i < suffix.segmentCount; i++) {
				if (i % 2 === 0) { // module prefix
					val modulePrefix = suffix.getSegment(i)
					if (modulePrefix != scopeCtx.moduleName) {
						name.append(suffix.getSegment(i)).append(":")
					}
				} else {
					name.append(suffix.getSegment(i))
					if (i + 1 < suffix.segmentCount) {
						name.append("/")
					}
				}
			}
			if (name.length > 0) {
				val entry = this.proposalCreator.createProposal(name.toString, context) [
					// TODO description, etc.
				]
				acceptor.accept(entry, this.proposalPriorities.getCrossRefPriority(e, entry))
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
