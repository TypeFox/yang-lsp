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
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Include
import io.typefox.yang.yang.Input
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
import io.typefox.yang.yang.Uses
import io.typefox.yang.yang.Value
import io.typefox.yang.yang.When
import io.typefox.yang.yang.XpathExpression
import io.typefox.yang.yang.YangVersion
import io.typefox.yang.yang.YinElement
import java.util.List
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.formatting.IIndentationInformation
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.FormatterPreferenceKeys
import org.eclipse.xtext.formatting2.FormatterRequest
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.eclipse.xtext.formatting2.ITextReplacer
import org.eclipse.xtext.formatting2.ITextReplacerContext
import org.eclipse.xtext.formatting2.regionaccess.ITextSegment
import org.eclipse.xtext.formatting2.regionaccess.internal.NodeSemanticRegion
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.preferences.BooleanKey
import org.eclipse.xtext.preferences.MapBasedPreferenceValues

import static io.typefox.yang.formatting2.MultilineStringReplacer.Line.PartType.*

import static extension com.google.common.base.Strings.*

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
        m.regionFor.assignment(moduleAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(m)
    }

    def dispatch void format(YangVersion v, extension IFormattableDocument it) {
        v.regionFor.assignment(yangVersionAccess.yangVersionAssignment_1).surround[oneSpace]
        formatStatement(v)
    }
    
    def dispatch void format(Namespace ns, extension IFormattableDocument it) {
        ns.regionFor.assignment(namespaceAccess.uriAssignment_1).surround[oneSpace]
        formatStatement(ns)
    }
    
    def dispatch void format(Prefix p, extension IFormattableDocument it) {
        p.regionFor.assignment(prefixAccess.prefixAssignment_1).surround[oneSpace]
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
        r.regionFor.assignment(revisionAccess.revisionAssignment_1).surround[oneSpace]
        formatStatement(r)
    }
    
    def dispatch void format(Typedef t, extension IFormattableDocument it) {
        t.regionFor.assignment(typedefAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(t)
    }
    
    def dispatch void format(Type t, extension IFormattableDocument it) {
        val typeRef = t.typeRef
        if (typeRef !== null) {
            typeRef.regionFor.assignment(typeReferenceAccess.typeAssignment_1).surround[oneSpace]
            typeRef.regionFor.crossRef(typeReferenceAccess.typeTypedefCrossReference_1_0).surround[oneSpace]
        }
        formatStatement(t)
    }
    
    def dispatch void format(Enum e, extension IFormattableDocument it) {
        e.regionFor.assignment(enumAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(e)
    }
    
    def dispatch void format(Value v, extension IFormattableDocument it) {
        v.regionFor.assignment(valueAccess.ordinalAssignment_1).surround[oneSpace]
        formatStatement(v)
    }
    
    def dispatch void format(Length l, extension IFormattableDocument it) {
        formatRefinement(l.expression)
        formatStatement(l)
    }
    
    def dispatch void format(Range r, extension IFormattableDocument it) {
        formatRefinement(r.expression)
        formatStatement(r)
    }
    
    def dispatch void format(Grouping g, extension IFormattableDocument it) {
        g.regionFor.assignment(groupingAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(g)
    }
    
    def dispatch void format(Leaf l, extension IFormattableDocument it) {
        l.regionFor.assignment(leafAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(l)
    }

    def dispatch void format(LeafList l, extension IFormattableDocument it) {
        l.regionFor.assignment(leafListAccess.nameAssignment_1).surround[oneSpace]
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
            u.grouping.regionFor.crossRef(groupingRefAccess.nodeGroupingCrossReference_0).surround[oneSpace]
        }
        formatStatement(u)
    }
    
    def dispatch void format(Container c, extension IFormattableDocument it) {
        c.regionFor.assignment(containerAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(c)
    }
    
    def dispatch void format(Must m, extension IFormattableDocument it) {
        formatXpath(m.constraint)
        formatStatement(m)
    }
    
    def dispatch void format(Mandatory m, extension IFormattableDocument it) {
        m.regionFor.assignment(mandatoryAccess.isMandatoryAssignment_1).surround[oneSpace]
        formatStatement(m)
    }
    
    def dispatch void format(MinElements m, extension IFormattableDocument it) {
        m.regionFor.assignment(minElementsAccess.minElementsAssignment_1).surround[oneSpace]
        formatStatement(m)
    }
    
    def dispatch void format(MaxElements m, extension IFormattableDocument it) {
        m.regionFor.assignment(maxElementsAccess.maxElementsAssignment_1).surround[oneSpace]
        formatStatement(m)
    }
    
    def dispatch void format(OrderedBy o, extension IFormattableDocument it) {
        o.regionFor.assignment(orderedByAccess.orderedByAssignment_1).surround[oneSpace]
        formatStatement(o)
    }
    
    def dispatch void format(io.typefox.yang.yang.List l, extension IFormattableDocument it) {
        l.regionFor.assignment(listAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(l)
    }
    
    def dispatch void format(Choice c, extension IFormattableDocument it) {
        c.regionFor.assignment(choiceAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(c)
    }
    
    def dispatch void format(Case c, extension IFormattableDocument it) {
        c.regionFor.assignment(caseAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(c)
    }
    
    def dispatch void format(Anydata a, extension IFormattableDocument it) {
        a.regionFor.assignment(anydataAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(a)
    }
    
    def dispatch void format(Anyxml a, extension IFormattableDocument it) {
        a.regionFor.assignment(anyxmlAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(a)
    }
    
    def dispatch void format(Refine r, extension IFormattableDocument it) {
        formatIdentifier(r.node)
        formatStatement(r)
    }
    
    def dispatch void format(Rpc r, extension IFormattableDocument it) {
        r.regionFor.assignment(rpcAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(r)
    }
    
    def dispatch void format(Input i, extension IFormattableDocument it) {
        i.regionFor.assignment(inputAccess.nameAssignment_2).surround[oneSpace]
        formatStatement(i)
    }
    
    def dispatch void format(Output o, extension IFormattableDocument it) {
        o.regionFor.assignment(outputAccess.nameAssignment_2).surround[oneSpace]
        formatStatement(o)
    }
    
    def dispatch void format(Action a, extension IFormattableDocument it) {
        a.regionFor.assignment(actionAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(a)
    }
        
    def dispatch void format(Notification n, extension IFormattableDocument it) {
        n.regionFor.assignment(notificationAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(n)
    }
    
    def dispatch void format(Identity i, extension IFormattableDocument it) {
        i.regionFor.assignment(identityAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(i)
    }
    
    def dispatch void format(Base b, extension IFormattableDocument it) {
        b.regionFor.assignment(baseAccess.referenceAssignment_1).surround[oneSpace]
        formatStatement(b)
    }
    
    def dispatch void format(Extension e, extension IFormattableDocument it) {
        e.regionFor.assignment(extensionAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(e)
    }
    
    def dispatch void format(Argument a, extension IFormattableDocument it) {
        a.regionFor.assignment(argumentAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(a)
    }
    
    def dispatch void format(YinElement y, extension IFormattableDocument it) {
        y.regionFor.assignment(yinElementAccess.isYinElementAssignment_1).surround[oneSpace]
        formatStatement(y)
    }
    
    def dispatch void format(Feature f, extension IFormattableDocument it) {
        f.regionFor.assignment(featureAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(f)
    }
    
    def dispatch void format(Deviate d, extension IFormattableDocument it) {
        d.regionFor.assignment(deviateAccess.argumentAssignment_1).surround[oneSpace]
        formatStatement(d)
    }
    
    def dispatch void format(Deviation d, extension IFormattableDocument it) {
        formatIdentifier(d.reference)
        formatStatement(d)
    }
    
    def dispatch void format(Config c, extension IFormattableDocument it) {
        c.regionFor.assignment(configAccess.isConfigAssignment_1).surround[oneSpace]
        formatStatement(c)
    }
    
    def dispatch void format(Status s, extension IFormattableDocument it) {
        s.regionFor.assignment(statusAccess.argumentAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(FractionDigits s, extension IFormattableDocument it) {
        s.regionFor.assignment(fractionDigitsAccess.rangeAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(Modifier s, extension IFormattableDocument it) {
        s.regionFor.assignment(modifierAccess.modifierAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(Bit s, extension IFormattableDocument it) {
        s.regionFor.assignment(bitAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(Position s, extension IFormattableDocument it) {
        s.regionFor.assignment(positionAccess.ordinalAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(RequireInstance s, extension IFormattableDocument it) {
        s.regionFor.assignment(requireInstanceAccess.isRequireInstanceAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(Import s, extension IFormattableDocument it) {
        s.regionFor.assignment(importAccess.moduleAssignment_1).surround[oneSpace]
        formatStatement(s)
    }

    def dispatch void format(RevisionDate s, extension IFormattableDocument it) {
        s.regionFor.assignment(revisionDateAccess.dateAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(Include s, extension IFormattableDocument it) {
        s.regionFor.assignment(includeAccess.moduleAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(Submodule s, extension IFormattableDocument it) {
        s.regionFor.assignment(submoduleAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(BelongsTo s, extension IFormattableDocument it) {
        s.regionFor.assignment(belongsToAccess.moduleAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(Units s, extension IFormattableDocument it) {
        s.regionFor.assignment(unitsAccess.definitionAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(Default s, extension IFormattableDocument it) {
        s.regionFor.assignment(defaultAccess.defaultStringValueAssignment_1).surround[oneSpace]
        formatStatement(s)
    }
    
    def dispatch void format(Unique u, extension IFormattableDocument it) {
        for (reference : u.references) {
            formatIdentifier(reference)
        }
        formatStatement(u)
    }
    
    // Tools
    
    protected def formatMultilineString(extension IFormattableDocument document, Statement s, Assignment a) {
        val region = s.regionFor.assignment(a) as NodeSemanticRegion
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
        if (nodeRegions.length > 1) {
            nodeRegions.tail.take(nodeRegions.length - 2).forEach[surround[noSpace]]
        }
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
        val nextSemanticRegion = nodeRegions.last.nextSemanticRegion
        if (HIDDENRule == nextSemanticRegion.grammarElement) {
            nextSemanticRegion.prepend[noSpace].append[oneSpace]
        } else {
            nodeRegions.last.append[oneSpace]
        }
    }
    
    protected def formatRefinement(extension IFormattableDocument document, Expression expression) {
        val nodeRegions = expression.allSemanticRegions.toList
        nodeRegions.head.prepend[oneSpace]
        val nextSemanticRegion = nodeRegions.last.nextSemanticRegion
        if (HIDDENRule == nextSemanticRegion.grammarElement) {
            nextSemanticRegion.prepend[noSpace].append[oneSpace]
        } else {
            nodeRegions.last.append[oneSpace]
        }
    }
    
}

@FinalFieldsConstructor
class MultilineStringReplacer implements ITextReplacer {
    val YangGrammarAccess grammerAccess
    val NodeSemanticRegion region
    val int trailingLinesIndent

    override ITextSegment getRegion() {
        region
    }
    
    def boolean alignWithKeyword() {
        return trailingLinesIndent !== 0
    }
    
    def String getFirstLineIndentation() {
        return if (alignWithKeyword) "" else "  " 
    }

    def String getTrailingLinesIndentation() {
        return if (alignWithKeyword) " ".repeat(trailingLinesIndent - 1) else ""
    }
    
    override createReplacements(ITextReplacerContext context) {
        val currentIndentation = context.indentationString
        val firstLineIndentation = firstLineIndentation 
        val trailingLinesIndentation = currentIndentation + trailingLinesIndentation 
        
        val leafNodes = region.node.leafNodes.toList
        
        val model = new LinesModel(grammerAccess, firstLineIndentation, trailingLinesIndentation)
        model.build(leafNodes)
        val newText = model.toString()
        
        context.addReplacement(region.replaceWith(newText))
        return context
    }
    
    @FinalFieldsConstructor
    static class LinesModel {
        val lines = newLinkedList(new Line)
        
        val extension YangGrammarAccess
        val String firstLineIndentation
        val String trailingLinesIndentation
    
        def getLast() {
            return lines.last
        }
        
        def addSpace() {
            if (!last.empty && !last.last.trim.empty) {
                last.append(" ", Hidden)
            }
        }
        
        def addStringValue(String text) {
            val parts = text.split("\n")
            if (parts.length === 1) {
                last.append(text, Value)
            } else {
                last.append(parts.head, Value)
                val indentToRemoved = indentToRemoved(parts)
                val rest = parts.tail.map[leftTrim(indentToRemoved)].toList
                if (rest.last.trim == '"') {
                    rest.set(rest.length - 1, '"')
                }
                for (part : rest) {
                    newLine()
                    last.append(part, ValueContinuation)
                }
            }
        }
    
        static def String leftTrim(String string, int trimLength) {
            val beginIndex = (0 ..< Math.min(string.length, trimLength)).findFirst[index | !Character.isWhitespace(string.charAt(index))]?:trimLength
            return string.substring(Math.min(string.length, beginIndex))
        }
        
        static def String leftTrim(String s) {
            val beginIndex = (0 ..< s.length).findFirst[index | !Character.isWhitespace(s.charAt(index))]?:s.length
            return s.substring(beginIndex)
        }
    
        static def indentToRemoved(String[] strings) {
            val (String)=>Integer countLeadingWS = [(0 ..< length).findFirst[index | !Character.isWhitespace(charAt(index))]?:Integer.MAX_VALUE]
            var count = strings.length - 1
            if (strings.last.trim == '"') {
                count -= 1
            }
            return strings.tail.take(count).map[countLeadingWS.apply(it)].min
        }

        def addSingleLineComment(String text) {
            last.append(text, SingleLineComment)
        }
        
        def newLine() {
            if (!last.empty) {
                lines += new Line
            }
        }
    
        def addMultiLineComment(String text) {
            var parts = text.split("\n")
            var first = true
            for (part : parts) {
                if (first) {
                    first = false
                    last.append(part, MultiLineComment)
                } else {
                    newLine()
                    last.append(" " + part.leftTrim, MultiLineComment)
                }
            }
            return this
        }
    
        def addPlus() {
            if (!last.empty) {
                last.append("+", Hidden)
            }
        }
        
        def build(List<ILeafNode> leafNodes) {
            for (it : leafNodes) {
                if (isHidden) {
                    val grammarElement = grammarElement
                    if (ML_COMMENTRule == grammarElement) {
                        addSpace()
                        addMultiLineComment(text)
                    }
                    if (SL_COMMENTRule == grammarElement) {
                        val text = text.replace("\n", "")
                        addSpace()
                        addSingleLineComment(text)
                        newLine()
                    }
                    if (WSRule == grammarElement) {
                        if (text.contains("\n")) {
                            newLine()
                        } else {
                            addSpace()
                        }
                    }
                    if (HIDDENRule == grammarElement) {
                        if (text.contains("+")) {
                            addPlus()
                        }
                    }
                } else {
                    addStringValue(text)
                }
            }
            lines.head.prepend(firstLineIndentation, Hidden)
            lines.tail.forEach[
                val lineTypePrefix = prefix
                prepend(trailingLinesIndentation + lineTypePrefix, Hidden)
            ]
        }
        
        override toString() {
            val string = lines.join("\n")
            return string
        }
    }
    
    static class Line {
        val parts = <String> newLinkedList()
        val types = <PartType> newLinkedList()
        
        def isEmpty() {
            return parts.empty
        }
        
        def getLast() {
            if (!parts.empty) {
                return parts.last
            }
            return null
        }
        
        def prepend(String string, PartType type) {
            parts.add(0, string)
            types.add(0, type)
        }
    
        def append(String string, PartType type) {
            parts += string
            types += type
        }
        
        enum PartType {
            Hidden, Value, ValueContinuation, SingleLineComment, MultiLineComment
        }
    
        def getPrefix() {
            val startsWithValueContinuation = !types.empty && types.first == PartType.ValueContinuation
            if (startsWithValueContinuation) {
                return if (parts.first == '"') "  " else "   ";
            }
            val containsValue = types.contains(PartType.Value)
            if (containsValue) {
                return "+ ";
            }
            return "  "
        }
        
        override toString() {
            return parts.join
        }
    }
}