package io.typefox.yang.formatting2

import com.google.inject.Inject
import io.typefox.yang.services.YangGrammarAccess
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.formatting2.regionaccess.TextRegionAccessBuilder
import org.eclipse.xtext.formatting2.regionaccess.internal.NodeModelBasedRegionAccessBuilder
import org.eclipse.xtext.formatting2.regionaccess.internal.TextRegionAccessBuildingSequencer
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.serializer.ISerializationContext

class YangTextRegionAccessBuilder extends TextRegionAccessBuilder {
    
    @Inject YangGrammarAccess grammarAccess
    
    TextRegionAccessBuildingSequencer fromSequencer

    NodeModelBasedRegionAccessBuilder fromNodeModel
    

    override forNodeModel(XtextResource resource) {
        fromNodeModel = new YangNodeModelBasedRegionAccessBuilder(grammarAccess).withResource(resource);
        return this;
    }
    
    override forSequence(ISerializationContext ctx, EObject root) {
        return this.fromSequencer = new TextRegionAccessBuildingSequencer().withRoot(ctx, root);
    }

    override create() {
        if (fromNodeModel !== null)
            return fromNodeModel.create();
        if (fromSequencer !== null)
            return fromSequencer.getRegionAccess();
        throw new IllegalStateException();
    }

}