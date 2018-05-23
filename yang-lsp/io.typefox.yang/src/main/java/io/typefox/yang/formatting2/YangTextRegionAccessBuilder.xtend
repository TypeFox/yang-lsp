package io.typefox.yang.formatting2

import com.google.inject.Inject
import io.typefox.yang.services.YangGrammarAccess
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.formatting2.regionaccess.TextRegionAccessBuilder
import org.eclipse.xtext.formatting2.regionaccess.internal.NodeModelBasedRegionAccessBuilder
import org.eclipse.xtext.formatting2.regionaccess.internal.TextRegionAccessBuildingSequencer
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.serializer.ISerializationContext
import org.eclipse.xtext.serializer.acceptor.ISequenceAcceptor
import org.eclipse.xtext.AbstractRule

class YangTextRegionAccessBuilder extends TextRegionAccessBuilder {
    
    @Inject YangGrammarAccess grammarAccess
    
    TextRegionAccessBuildingSequencer fromSequencer

    NodeModelBasedRegionAccessBuilder fromNodeModel

    override forNodeModel(XtextResource resource) {
        fromNodeModel = new YangNodeModelBasedRegionAccessBuilder(grammarAccess).withResource(resource);
        return this;
    }
    
	override ISequenceAcceptor forSequence(ISerializationContext ctx, EObject root) {
		return this.fromSequencer = new YangTextRegionAccessBuildingSequencer().withRoot(ctx, root);
	}

    override create() {
        if (fromNodeModel !== null)
            return fromNodeModel.create();
        if (fromSequencer !== null)
            return fromSequencer.getRegionAccess();
        throw new IllegalStateException();
    }

	static class YangTextRegionAccessBuildingSequencer extends TextRegionAccessBuildingSequencer {

		override acceptWhitespace(AbstractRule rule, String token, ILeafNode node) {
			if (token == '"' || token == "'") {
				acceptSemantic(rule, token)
				super.acceptWhitespace(rule, '', node)
			} else {
				super.acceptWhitespace(rule, token, node)				
			} 
		}

		override acceptUnassignedKeyword(Keyword keyword, String token, ILeafNode node) {
			if (keyword.value == '<<<<' || keyword.value == '>>>>')
				return;
			super.acceptUnassignedKeyword(keyword, token, node)
		} 
	}
}