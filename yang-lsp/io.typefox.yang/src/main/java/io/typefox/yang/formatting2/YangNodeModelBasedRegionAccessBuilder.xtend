package io.typefox.yang.formatting2

import io.typefox.yang.services.YangGrammarAccess
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.formatting2.regionaccess.IHiddenRegion
import org.eclipse.xtext.formatting2.regionaccess.ISemanticRegion
import org.eclipse.xtext.formatting2.regionaccess.ITextRegionAccess
import org.eclipse.xtext.formatting2.regionaccess.internal.NodeEObjectRegion
import org.eclipse.xtext.formatting2.regionaccess.internal.NodeHiddenRegion
import org.eclipse.xtext.formatting2.regionaccess.internal.NodeModelBasedRegionAccess
import org.eclipse.xtext.formatting2.regionaccess.internal.NodeModelBasedRegionAccessBuilder
import org.eclipse.xtext.formatting2.regionaccess.internal.NodeRegion
import org.eclipse.xtext.formatting2.regionaccess.internal.SemanticRegionMatcher
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.GrammarUtil
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.formatting2.regionaccess.IEObjectRegion

@FinalFieldsConstructor
class YangNodeModelBasedRegionAccessBuilder extends NodeModelBasedRegionAccessBuilder {

    val extension YangGrammarAccess grammarAccess

    override protected add(NodeModelBasedRegionAccess access, INode node) {
        if (node instanceof ILeafNode && HIDDENRule == node.grammarElement) {
            addHIDDEN(access, node)
            return;
        }
        super.add(access, node)
    }

    def protected addHIDDEN(NodeModelBasedRegionAccess access, INode node) {
        val eObjectTokens = stack.head()
        val newSemantic = new HIDDENSemanticRegion(access, node)
        val newHidden = createHiddenRegion(access);
        newSemantic.trailing = newHidden
        newHidden.setPrevious(newSemantic)
        newSemantic.leading = lastHidden
        lastHidden.setNext(newSemantic)
        eObjectTokens.addChild(newSemantic);
        newSemantic.setEObjectTokens(eObjectTokens);
        lastHidden = newHidden;
    }

    override ExtendedNodeHiddenRegion createHiddenRegion(ITextRegionAccess access) {
        return new ExtendedNodeHiddenRegion(access)
    }

    override protected ExtendedNodeHiddenRegion getLastHidden() {
        super.getLastHidden() as ExtendedNodeHiddenRegion
    }
}

package class ExtendedNodeHiddenRegion extends NodeHiddenRegion {

    protected new(ITextRegionAccess access) {
        super(access)
    }

    override public setPrevious(ISemanticRegion previous) {
        super.setPrevious(previous)
    }

    override public setNext(ISemanticRegion next) {
        super.setNext(next)
    }
}

package class HIDDENSemanticRegion extends NodeRegion implements ISemanticRegion {

    @Accessors NodeEObjectRegion eObjectTokens
    @Accessors IHiddenRegion leading
    @Accessors IHiddenRegion trailing

    protected new(NodeModelBasedRegionAccess access, INode node) {
        super(access, node)
    }

    override EObject getGrammarElement() {
        return node.grammarElement
    }

    override getEObjectRegion() {
        return eObjectTokens
    }

    override getNextHiddenRegion() {
        return trailing
    }

    override getNextSemanticRegion() {
        return if (trailing !== null) trailing.getNextSemanticRegion() else null
    }

    override getNextSequentialRegion() {
        return trailing
    }

    override getPreviousHiddenRegion() {
        return leading
    }

    override getPreviousSemanticRegion() {
        return if (leading !== null) leading.getPreviousSemanticRegion() else null
    }

    override getPreviousSequentialRegion() {
        return leading
    }

    override immediatelyFollowing() {
        return new SemanticRegionMatcher(getNextSemanticRegion())
    }

    override immediatelyPreceding() {
        return new SemanticRegionMatcher(getPreviousSemanticRegion());
    }

    override getSemanticElement() {
		return if(eObjectTokens !== null) eObjectTokens.getSemanticElement() else null
	}

	override EStructuralFeature getContainingFeature() {
		var Assignment assignment = GrammarUtil.containingAssignment(getGrammarElement())
		if (assignment !== null) {
			return getSemanticElement().eClass().getEStructuralFeature(assignment.getFeature())
		}
		return null
	}

	override IEObjectRegion getContainingRegion() {
		return eObjectTokens
	}

	override getIndexInContainingFeature() {
		// can't implement since opposite in 
		// org.eclipse.xtext.formatting2.regionaccess.internal.AbstractEObjectRegion.initChildrenFeatureIndexes()
		// is required
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

}
