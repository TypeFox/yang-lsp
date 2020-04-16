package io.typefox.yang.formatting2

import com.google.inject.Inject
import io.typefox.yang.services.YangGrammarAccess
import io.typefox.yang.yang.Action
import io.typefox.yang.yang.Anydata
import io.typefox.yang.yang.Anyxml
import io.typefox.yang.yang.Argument
import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.Base
import io.typefox.yang.yang.BelongsTo
import io.typefox.yang.yang.BinaryOperation
import io.typefox.yang.yang.Bit
import io.typefox.yang.yang.Case
import io.typefox.yang.yang.Choice
import io.typefox.yang.yang.Config
import io.typefox.yang.yang.Contact
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Default
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Deviate
import io.typefox.yang.yang.Deviation
import io.typefox.yang.yang.Enum
import io.typefox.yang.yang.ErrorAppTag
import io.typefox.yang.yang.ErrorMessage
import io.typefox.yang.yang.Expression
import io.typefox.yang.yang.Extension
import io.typefox.yang.yang.Feature
import io.typefox.yang.yang.FractionDigits
import io.typefox.yang.yang.Grouping
import io.typefox.yang.yang.Identity
import io.typefox.yang.yang.IfFeature
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Include
import io.typefox.yang.yang.Input
import io.typefox.yang.yang.Key
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.LeafList
import io.typefox.yang.yang.Length
import io.typefox.yang.yang.Mandatory
import io.typefox.yang.yang.MaxElements
import io.typefox.yang.yang.MinElements
import io.typefox.yang.yang.Modifier
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Must
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Notification
import io.typefox.yang.yang.OrderedBy
import io.typefox.yang.yang.Organization
import io.typefox.yang.yang.Output
import io.typefox.yang.yang.Path
import io.typefox.yang.yang.Pattern
import io.typefox.yang.yang.Position
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Presence
import io.typefox.yang.yang.Range
import io.typefox.yang.yang.Reference
import io.typefox.yang.yang.Refine
import io.typefox.yang.yang.RequireInstance
import io.typefox.yang.yang.Revision
import io.typefox.yang.yang.RevisionDate
import io.typefox.yang.yang.Rpc
import io.typefox.yang.yang.SchemaNodeIdentifier
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Status
import io.typefox.yang.yang.Submodule
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import io.typefox.yang.yang.Unique
import io.typefox.yang.yang.Units
import io.typefox.yang.yang.Unknown
import io.typefox.yang.yang.Uses
import io.typefox.yang.yang.Value
import io.typefox.yang.yang.When
import io.typefox.yang.yang.XpathBinaryOperation
import io.typefox.yang.yang.XpathExpression
import io.typefox.yang.yang.XpathLocation
import io.typefox.yang.yang.XpathNameTest
import io.typefox.yang.yang.YangVersion
import io.typefox.yang.yang.YinElement
import java.util.ArrayList
import java.util.List
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.formatting.IIndentationInformation
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.FormatterPreferenceKeys
import org.eclipse.xtext.formatting2.FormatterRequest
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.eclipse.xtext.formatting2.regionaccess.IHiddenRegion
import org.eclipse.xtext.formatting2.regionaccess.IHiddenRegionPart
import org.eclipse.xtext.formatting2.regionaccess.ISemanticRegion
import org.eclipse.xtext.formatting2.regionaccess.ITextReplacement
import org.eclipse.xtext.formatting2.regionaccess.internal.NodeSemanticRegion
import org.eclipse.xtext.formatting2.regionaccess.internal.TextRegions
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.preferences.BooleanKey
import org.eclipse.xtext.preferences.MapBasedPreferenceValues

import static io.typefox.yang.yang.YangPackage.Literals.*

class YangFormatter extends AbstractFormatter2 {
    
    @Inject extension YangGrammarAccess
    @Inject IIndentationInformation indentationInformation
    
    // Option Keys
    
    public static val FORCE_NEW_LINE = new BooleanKey("FORCE_NEW_LINE", true)
    
    // Defaults

    override protected initialize(FormatterRequest request) {
        val preferences = request.preferences
        if (preferences instanceof MapBasedPreferenceValues) {
            preferences.put(FormatterPreferenceKeys.indentation, indentationInformation.indentString)
        }
        super.initialize(request)
    }
    
    // Rules

    def dispatch void format(Module m, extension IFormattableDocument it) {
        m.regionFor.assignment(moduleAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(m)
    }

    def dispatch void format(YangVersion v, extension IFormattableDocument it) {
        v.regionFor.assignment(yangVersionAccess.yangVersionAssignment_1).surroundSpace(it)
        formatStatement(v)
    }
    
    def dispatch void format(Namespace ns, extension IFormattableDocument it) {
        ns.regionFor.assignment(namespaceAccess.uriAssignment_1).surroundSpace(it)
        formatStatement(ns)
    }
    
    def dispatch void format(Prefix p, extension IFormattableDocument it) {
        p.regionFor.assignment(prefixAccess.prefixAssignment_1).surroundSpace(it)
        formatStatement(p)
    }
    
    def dispatch void format(Organization o, extension IFormattableDocument it) {
        formatMultilineString(o, organizationAccess.organizationAssignment_1)
        formatStatement(o)
    }
    
    def dispatch void format(Description d, extension IFormattableDocument it) {
        formatMultilineString(d, descriptionAccess.descriptionAssignment_1)
        formatStatement(d)
    }
    
    def dispatch void format(Contact c, extension IFormattableDocument it) {
        formatMultilineString(c, contactAccess.contactAssignment_1)
        formatStatement(c)
    }
    
    def dispatch void format(Reference r, extension IFormattableDocument it) {
        formatMultilineString(r, referenceAccess.referenceAssignment_1)
        formatStatement(r)
    }
    
    def dispatch void format(Pattern p, extension IFormattableDocument it) {
        formatMultilineString(p, patternAccess.regexpAssignment_1)
        formatStatement(p)
    }
    
    def dispatch void format(ErrorMessage e, extension IFormattableDocument it) {
        formatMultilineString(e, errorMessageAccess.messageAssignment_1)
        formatStatement(e)
    }
    
    def dispatch void format(ErrorAppTag e, extension IFormattableDocument it) {
        formatMultilineString(e, errorAppTagAccess.tagAssignment_1)
        formatStatement(e)
    }
    
    def dispatch void format(Presence p, extension IFormattableDocument it) {
        formatMultilineString(p, presenceAccess.descriptionAssignment_1)
        formatStatement(p)
    }
    
    def dispatch void format(Revision r, extension IFormattableDocument it) {
        r.regionFor.assignment(revisionAccess.revisionAssignment_1).surroundSpace(it)
        formatStatement(r)
    }
    
    def dispatch void format(Typedef t, extension IFormattableDocument it) {
        t.regionFor.assignment(typedefAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(t)
    }
    
    def dispatch void format(Type t, extension IFormattableDocument it) {
        val typeRef = t.typeRef
        if (typeRef !== null) {
            typeRef.regionFor.assignment(typeReferenceAccess.typeAssignment_1).surroundSpace(it)
            typeRef.regionFor.crossRef(typeReferenceAccess.typeTypedefCrossReference_1_0).surroundSpace(it)
        }
        formatStatement(t)
    }
    
    def dispatch void format(Enum e, extension IFormattableDocument it) {
        e.regionFor.assignment(enumAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(e)
    }
    
    def dispatch void format(Value v, extension IFormattableDocument it) {
        v.regionFor.assignment(valueAccess.ordinalAssignment_1).surroundSpace(it)
        formatStatement(v)
    }
    
    def dispatch void format(Length l, extension IFormattableDocument it) {
    	val exp = l.expression
    	exp.allSemanticRegions.surroundSpace(it)
        formatRefinement(exp, exp.previousHiddenRegion.isNextToHidden || exp.nextHiddenRegion.isNextToHidden)
        formatStatement(l)
    }
    
    def dispatch void format(Range r, extension IFormattableDocument it) {
    	val exp = r.expression
    	exp.allSemanticRegions.surroundSpace(it)
        formatRefinement(exp, exp.previousHiddenRegion.isNextToHidden || exp.nextHiddenRegion.isNextToHidden)
        formatStatement(r)
    }
    
    def dispatch void format(Grouping g, extension IFormattableDocument it) {
        g.regionFor.assignment(groupingAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(g)
    }
    
    def dispatch void format(Leaf l, extension IFormattableDocument it) {
        l.regionFor.assignment(leafAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(l)
    }

    def dispatch void format(LeafList l, extension IFormattableDocument it) {
        l.regionFor.assignment(leafListAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(l)
    }
    
    def dispatch void format(Augment a, extension IFormattableDocument it) {
        formatIdentifier(a.path)
        formatStatement(a)
    }
    
    def dispatch void format(When w, extension IFormattableDocument it) {
        formatXpath(w.condition)
        formatStatement(w)
    }
    
    def dispatch void format(Path p, extension IFormattableDocument it) {
        formatXpath(p.reference)
        formatStatement(p)
    }
    
    def dispatch void format(Uses u, extension IFormattableDocument it) {
        if (u.grouping !== null) {
            u.grouping.regionFor.crossRef(groupingRefAccess.nodeGroupingCrossReference_0).surroundSpace(it)
        }
        formatStatement(u)
    }
    
    def dispatch void format(Container c, extension IFormattableDocument it) {
        c.regionFor.assignment(containerAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(c)
    }
    
    def dispatch void format(Must m, extension IFormattableDocument it) {
        formatXpath(m.constraint)
        formatStatement(m)
    }
    
    def dispatch void format(Mandatory m, extension IFormattableDocument it) {
        m.regionFor.assignment(mandatoryAccess.isMandatoryAssignment_1).surroundSpace(it)
        formatStatement(m)
    }
    
    def dispatch void format(MinElements m, extension IFormattableDocument it) {
        m.regionFor.assignment(minElementsAccess.minElementsAssignment_1).surroundSpace(it)
        formatStatement(m)
    }
    
    def dispatch void format(MaxElements m, extension IFormattableDocument it) {
        m.regionFor.assignment(maxElementsAccess.maxElementsAssignment_1).surroundSpace(it)
        formatStatement(m)
    }
    
    def dispatch void format(OrderedBy o, extension IFormattableDocument it) {
        o.regionFor.assignment(orderedByAccess.orderedByAssignment_1).surroundSpace(it)
        formatStatement(o)
    }
    
    def dispatch void format(io.typefox.yang.yang.List l, extension IFormattableDocument it) {
        l.regionFor.assignment(listAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(l)
    }
    
    def dispatch void format(Choice c, extension IFormattableDocument it) {
        c.regionFor.assignment(choiceAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(c)
    }
    
    def dispatch void format(Case c, extension IFormattableDocument it) {
        c.regionFor.assignment(caseAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(c)
    }
    
    def dispatch void format(Anydata a, extension IFormattableDocument it) {
        a.regionFor.assignment(anydataAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(a)
    }
    
    def dispatch void format(Anyxml a, extension IFormattableDocument it) {
        a.regionFor.assignment(anyxmlAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(a)
    }
    
    def dispatch void format(Refine r, extension IFormattableDocument it) {
        formatIdentifier(r.node)
        formatStatement(r)
    }
    
    def dispatch void format(Rpc r, extension IFormattableDocument it) {
        r.regionFor.assignment(rpcAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(r)
    }
    
    def dispatch void format(Input i, extension IFormattableDocument it) {
        i.regionFor.assignment(inputAccess.nameAssignment_2).surroundSpace(it)
        formatStatement(i)
    }
    
    def dispatch void format(Output o, extension IFormattableDocument it) {
        o.regionFor.assignment(outputAccess.nameAssignment_2).surroundSpace(it)
        formatStatement(o)
    }
    
    def dispatch void format(Action a, extension IFormattableDocument it) {
        a.regionFor.assignment(actionAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(a)
    }
        
    def dispatch void format(Notification n, extension IFormattableDocument it) {
        n.regionFor.assignment(notificationAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(n)
    }
    
    def dispatch void format(Identity i, extension IFormattableDocument it) {
        i.regionFor.assignment(identityAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(i)
    }
    
    def dispatch void format(Base b, extension IFormattableDocument it) {
        b.regionFor.assignment(baseAccess.referenceAssignment_1).surroundSpace(it)
        formatStatement(b)
    }
    
    def dispatch void format(Extension e, extension IFormattableDocument it) {
        e.regionFor.assignment(extensionAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(e)
    }
    
    def dispatch void format(Argument a, extension IFormattableDocument it) {
        a.regionFor.assignment(argumentAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(a)
    }
    
    def dispatch void format(YinElement y, extension IFormattableDocument it) {
        y.regionFor.assignment(yinElementAccess.isYinElementAssignment_1).surroundSpace(it)
        formatStatement(y)
    }
    
    def dispatch void format(Feature f, extension IFormattableDocument it) {
        f.regionFor.assignment(featureAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(f)
    }
    
    def dispatch void format(Deviate d, extension IFormattableDocument it) {
        d.regionFor.assignment(deviateAccess.argumentAssignment_1).surroundSpace(it)
        formatStatement(d)
    }
    
    def dispatch void format(Deviation d, extension IFormattableDocument it) {
        formatIdentifier(d.reference)
        formatStatement(d)
    }
    
    def dispatch void format(Config c, extension IFormattableDocument it) {
        c.regionFor.assignment(configAccess.isConfigAssignment_1).surroundSpace(it)
        formatStatement(c)
    }
    
    def dispatch void format(Status s, extension IFormattableDocument it) {
        s.regionFor.assignment(statusAccess.argumentAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(FractionDigits s, extension IFormattableDocument it) {
        s.regionFor.assignment(fractionDigitsAccess.rangeAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(Modifier s, extension IFormattableDocument it) {
        s.regionFor.assignment(modifierAccess.modifierAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(Bit s, extension IFormattableDocument it) {
        s.regionFor.assignment(bitAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(Position s, extension IFormattableDocument it) {
        s.regionFor.assignment(positionAccess.ordinalAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(RequireInstance s, extension IFormattableDocument it) {
        s.regionFor.assignment(requireInstanceAccess.isRequireInstanceAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(Import s, extension IFormattableDocument it) {
        s.regionFor.assignment(importAccess.moduleAssignment_1).surroundSpace(it)
        formatStatement(s)
    }

    def dispatch void format(RevisionDate s, extension IFormattableDocument it) {
        s.regionFor.assignment(revisionDateAccess.dateAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(Include s, extension IFormattableDocument it) {
        s.regionFor.assignment(includeAccess.moduleAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(Submodule s, extension IFormattableDocument it) {
        s.regionFor.assignment(submoduleAccess.nameAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(BelongsTo s, extension IFormattableDocument it) {
        s.regionFor.assignment(belongsToAccess.moduleAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(Units s, extension IFormattableDocument it) {
        s.regionFor.assignment(unitsAccess.definitionAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(Default s, extension IFormattableDocument it) {
        s.regionFor.assignment(defaultAccess.defaultStringValueAssignment_1).surroundSpace(it)
        formatStatement(s)
    }
    
    def dispatch void format(Unique u, extension IFormattableDocument it) {
        for (reference : u.references) {
            formatIdentifier(reference)
        }
        formatStatement(u)
    }

    def dispatch void format(Key k, extension IFormattableDocument it) {
		k.references.last.semanticRegions.forEach[append[noSpace]]
		formatStatement(k)	
    }
    
    def dispatch void format(IfFeature i, extension IFormattableDocument it) {
		formatStatement(i)
    }

    def dispatch void format(Unknown u, extension IFormattableDocument it) {
		val lastRegion = if(u.name !== null)
			u.regionFor.assignment(unknownAccess.nameAssignment_1)
		else
			u.regionFor.assignment(unknownAccess.extensionAssignment_0)
   		if (lastRegion !== null) {
   			val nextSemanticRegion = lastRegion.nextSemanticRegion
	        if (HIDDENRule == nextSemanticRegion.grammarElement) {
	            nextSemanticRegion.prepend[noSpace].append[oneSpace]
	        } else {
	            lastRegion.append[oneSpace]
	        }
        }
        formatStatement(u)
    }
    
    // Tools
    
    protected def formatMultilineString(extension IFormattableDocument document, Statement s, Assignment a) {
        val region = s.regionFor.assignment(a)
        if (region instanceof NodeSemanticRegion) {
	        var trailingLinesIndent = 0
	        if (preferences.getPreference(YangFormatter.FORCE_NEW_LINE)) {
	            region.prepend[newLine]
	        } else {
	            region.prepend[oneSpace]
	            val keyword = s.findFirstKeyword
	            trailingLinesIndent = keyword.length
	        }
    		addReplacer(new MultilineStringReplacer(_yangGrammarAccess, region, trailingLinesIndent))
        }
    }
    
    protected def String findFirstKeyword(Statement statement) {
        val node = NodeModelUtils.findActualNodeFor(statement)
        return node.leafNodes.findFirst[grammarElement instanceof Keyword]?.text?:""
    }
    
    protected def void formatStatement(extension IFormattableDocument document, Statement it) {
        regionFor.keyword(statementEndAccess.semicolonKeyword_1).prepend[noSpace; highPriority]
            
        val leftCurly = regionFor.keyword(statementEndAccess.leftCurlyBracketKeyword_0_0)
        val rightCurly = regionFor.keyword(statementEndAccess.rightCurlyBracketKeyword_0_2)

        interior(
            leftCurly,
            rightCurly.prepend[newLine],
            [indent]
        ) 
        // continue
        substatements.forEach[
            prepend[setNewLines(1, 1, 2)]
            format
        ]
    }
    
    protected def formatIdentifier(extension IFormattableDocument document, SchemaNodeIdentifier id) {
        if (id === null) {
            return;
        }
        val nodeRegions = id.allSemanticRegions.toList
        nodeRegions.head.prepend[oneSpace]
        nodeRegions
        	.tail
        	.forEach[prepend[noSpace]]
        val nextSemanticRegion = nodeRegions.last.nextSemanticRegion
        if (HIDDENRule == nextSemanticRegion.grammarElement) {
            nextSemanticRegion.prepend[noSpace].append[oneSpace]
        } else {
            nodeRegions.last.append[oneSpace]
        }
    }
    
    protected def formatXpath(extension IFormattableDocument document, XpathExpression expression) {
        val nodeRegions = expression.allSemanticRegions.toList
        nodeRegions.head.prepend[oneSpace]
        nodeRegions.tail.forEach[formatXpathRegion(document)]
        val nextSemanticRegion = nodeRegions.last.nextSemanticRegion
        if (HIDDENRule == nextSemanticRegion.grammarElement) {
            nextSemanticRegion.prepend[noSpace].append[oneSpace]
        } else {
            nodeRegions.last.append[oneSpace]
        }
    }
    
    private def formatXpathRegion(ISemanticRegion region, extension IFormattableDocument document) {
    	if (region.grammarElement == HIDDENRule) {
    		val semantic = region.semanticElement
    		if (semantic instanceof XpathLocation || semantic instanceof XpathNameTest) {
    			val previousSemantic = region.previousSemanticRegion.semanticElement
    			if (!(previousSemantic instanceof XpathBinaryOperation)) {
    				region.prepend[noSpace]
				}
			}
    	}
    }
    
    protected def void formatRefinement(extension IFormattableDocument it, Expression expression, boolean isInHidden) {
        if (expression instanceof BinaryOperation) {
    		expression.regionFor.feature(BINARY_OPERATION__OPERATOR).prepend[
    			if (isInHidden && expression.left.nextHiddenRegion.length > 0)
    				oneSpace
    			else
    				noSpace
    		].append[
    			if (isInHidden && expression.right.previousHiddenRegion.length > 0)
    				oneSpace
    			else
    				noSpace
    		]
    		formatRefinement(expression.left, isInHidden)
    		formatRefinement(expression.right, isInHidden)
        }
    }
    
    protected def surroundSpace(Iterable<ISemanticRegion> nodeRegions, extension IFormattableDocument doc) {
        nodeRegions.head.prepend[oneSpace]
        val lastRegion = nodeRegions.last
        val nextSemanticRegion = lastRegion.nextSemanticRegion
        if (HIDDENRule == nextSemanticRegion.grammarElement) {
            nextSemanticRegion.prepend[noSpace].append[oneSpace]
        } else {
            lastRegion.append[oneSpace]
        }
    }
    
    protected def surroundSpace(ISemanticRegion token, IFormattableDocument doc) {
    	if (token !== null) {
			var previous = token.actualPreviousRegion
			var next = token.actualNextRegion
			doc.set(previous, next, [oneSpace]);
		}
		return token;
    }
    
    private def getActualPreviousRegion(ISemanticRegion token) {
    	val hidden = token.previousHiddenRegion
    	val previous = hidden?.previousSemanticRegion
		if (previous !== null && previous.grammarElement == HIDDENRule) {
			return previous.previousHiddenRegion
		}
		return hidden
    }
    
    private def getActualNextRegion(ISemanticRegion token) {
    	val hidden = token.nextHiddenRegion
    	val next = hidden?.nextSemanticRegion
		if (next !== null && next.grammarElement == HIDDENRule) {
			return next.nextHiddenRegion
		}
		return hidden
    }

	override protected postProcess(IFormattableDocument document, List<ITextReplacement> replacements) {
		val expected = newArrayList
		var current = textRegionAccess.regionForRootEObject.previousHiddenRegion
		while (current !== null) {
			if (current.isUndefined && isInRequestedRange(current.offset, current.endOffset)
					&& !isNextToHidden(current))
				expected.addAll(current.mergedSpaces)
			current = current.nextHiddenRegion
		}
		if (expected.isEmpty)
			return replacements
		val missing = TextRegions.difference(expected, replacements)
		if (missing.isEmpty)
			return replacements
		val result = new ArrayList(replacements)
		for (seg : missing) {
			val h =
				if (seg instanceof IHiddenRegion)
					seg
				else if (seg instanceof IHiddenRegionPart)
					seg.hiddenRegion
			if (h !== null && (h.nextSemanticRegion === null || h.previousSemanticRegion === null))
				result.add(seg.replaceWith(''))
			else
				result.add(seg.replaceWith(' '))
		}
		return result
	}

	private def isInRequestedRange(int offset, int endOffset) {
		val regions = request.regions
		if (regions.isEmpty)
			return true
		for (region : regions) {
			if (region.offset <= offset && region.offset + region.length >= endOffset)
				return true
		}
		return false
	}
	
	private def isNextToHidden(IHiddenRegion region) {
		val previous = region.previousSemanticRegion
		if (previous !== null && previous.grammarElement == HIDDENRule)
			return true
		val next = region.nextSemanticRegion
		if (next !== null && next.grammarElement == HIDDENRule)
			return true
		return false
	}
    
}