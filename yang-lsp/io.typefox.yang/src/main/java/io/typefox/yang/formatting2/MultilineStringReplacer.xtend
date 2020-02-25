package io.typefox.yang.formatting2

import io.typefox.yang.services.YangGrammarAccess
import java.util.List
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.formatting2.ITextReplacer
import org.eclipse.xtext.formatting2.ITextReplacerContext
import org.eclipse.xtext.formatting2.regionaccess.ITextSegment
import org.eclipse.xtext.formatting2.regionaccess.internal.NodeSemanticRegion
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.util.Wrapper

import static io.typefox.yang.formatting2.MultilineStringReplacer.Line.PartType.*

import static extension com.google.common.base.Strings.*

@FinalFieldsConstructor
class MultilineStringReplacer implements ITextReplacer {
    val YangGrammarAccess grammarAccess
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
        
        val model = new LinesModel(grammarAccess, firstLineIndentation, trailingLinesIndentation)
        model.build(leafNodes)
        val newText = model.toString()
        
        context.addReplacement(region.replaceWith(newText))
        return context
    }
    
    static def isQuote(String s) {
        val trimmed = s.trim
        return trimmed == '"' || trimmed == "'"
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
        
        def addStringValue(String text, int originalStartColumn) {
            val parts = text.split(System.lineSeparator)
            if (parts.length === 1) {
                last.append(text, Value)
            } else {
                last.append(parts.head, Value)
                val indentToRemoved = indentToRemoved(parts, originalStartColumn)
                val rest = parts.tail.map[leftTrim(indentToRemoved)].toList
                if (rest.last.isQuote) {
                    rest.set(rest.length - 1, rest.last.trim)
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
    
        static def indentToRemoved(String[] strings, int originalStartColumn) {
            val (String)=>Integer countLeadingWS = [(0 ..< length).findFirst[index | !Character.isWhitespace(charAt(index))]?:Integer.MAX_VALUE]
            var count = strings.length - 1
            if (strings.last.isQuote) {
                count -= 1
            }
            if (count < 1) {
                return 0;
            }
            val minCountLeadingWS = strings.tail.take(count).map[countLeadingWS.apply(it)].min
            return Math.min(minCountLeadingWS, originalStartColumn)
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
            var parts = text.split(System.lineSeparator)
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
                    switch grammarElement {
	                    case ML_COMMENTRule: {
	                        addSpace()
	                        addMultiLineComment(text)
	                    }
	                    case SL_COMMENTRule: {
	                        val text = text.replace(System.lineSeparator, "")
	                        addSpace()
	                        addSingleLineComment(text)
	                        newLine()
	                    }
	                    case WSRule: {
	                        if (text.contains(System.lineSeparator))
	                            newLine()
	                        else
	                            addSpace()
	                    }
	                    case HIDDENRule: {
	                        if (text.contains("+"))
	                            addPlus()
	                    }
                    }
                } else {
                    val originalStartColumn = NodeModelUtils.getLineAndColumn(it, offset).column
                    addStringValue(text, originalStartColumn)
                }
            }
            lines.head.prepend(firstLineIndentation, Hidden)
            val previousLine = new Wrapper(lines.head)
            lines.tail.forEach[
                val lineTypePrefix = prefix
                // https://github.com/theia-ide/yang-lsp/issues/153
                if (previousLine.get.last == '+' && lineTypePrefix.startsWith('+'))
                	previousLine.get.removeLast()
                prepend(trailingLinesIndentation + lineTypePrefix, Hidden)
                previousLine.set(it)
            ]
        }
        
        override toString() {
            val string = lines.join(System.lineSeparator)
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
        
        def void removeLast() {
        	parts.removeLast()
        	types.removeLast()
        	while (!parts.empty && parts.last == ' ') {
        		parts.removeLast()
        		types.removeLast()
        	}
        }
        
        def void prepend(String string, PartType type) {
            parts.add(0, string)
            types.add(0, type)
        }
    
        def void append(String string, PartType type) {
            parts += string
            types += type
        }
        
        enum PartType {
            Hidden, Value, ValueContinuation, SingleLineComment, MultiLineComment
        }
    
        def getPrefix() {
            val startsWithValueContinuation = !types.empty && types.first == PartType.ValueContinuation
            if (startsWithValueContinuation) {
                return if (parts.first.isQuote) "  " else "   ";
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