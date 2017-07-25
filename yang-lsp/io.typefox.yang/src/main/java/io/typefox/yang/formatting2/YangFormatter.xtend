package io.typefox.yang.formatting2

import com.google.inject.Inject
import io.typefox.yang.services.YangGrammarAccess
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.YangVersion
import java.util.List
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.FormatterPreferenceKeys
import org.eclipse.xtext.formatting2.FormatterRequest
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.eclipse.xtext.formatting2.ITextReplacer
import org.eclipse.xtext.formatting2.ITextReplacerContext
import org.eclipse.xtext.formatting2.regionaccess.ISemanticRegion
import org.eclipse.xtext.formatting2.regionaccess.ITextSegment
import org.eclipse.xtext.formatting2.regionaccess.internal.TextSegment
import org.eclipse.xtext.preferences.MapBasedPreferenceValues
import io.typefox.yang.yang.Organization
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Contact

class YangFormatter extends AbstractFormatter2 {
    
    static val INDENTATION = "  "
    public static val MAX_LINE_LENGTH = 72

    @Inject extension YangGrammarAccess

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
        val textRegion = o.regionFor.assignment(organizationAccess.organizationAssignment_1).prepend[newLine].textRegion
        addReplacer(new MultilineStringReplacer(textRegion))
        formatStatement(o)
    }
    
    def dispatch void format(Description d, extension IFormattableDocument it) {
        val textRegion = d.regionFor.assignment(descriptionAccess.descriptionAssignment_1).prepend[newLine].textRegion
        addReplacer(new MultilineStringReplacer(textRegion))
        formatStatement(d)
    }
    
    def dispatch void format(Contact c, extension IFormattableDocument it) {
        val textRegion = c.regionFor.assignment(contactAccess.contactAssignment_1).prepend[newLine].textRegion
        addReplacer(new MultilineStringReplacer(textRegion))
        formatStatement(c)
    }
    
    def void formatStatement(extension IFormattableDocument it, Statement s) {
        s.regionFor.keyword(statementEndAccess.semicolonKeyword_1)
            .prepend[noSpace; highPriority]
            
        val leftCurly = s.regionFor.keyword(statementEndAccess.leftCurlyBracketKeyword_0_0)
        val rightCurly = s.regionFor.keyword(statementEndAccess.rightCurlyBracketKeyword_0_2)

        interior(
            leftCurly,
            rightCurly.prepend[newLine]
        ) [indent]
        // continue
        formatSubstatements(s)
    }
    
    def formatSubstatements(extension IFormattableDocument it, Statement s) {
        for (substatement : s.substatements) {
            substatement.prepend[setNewLines(2, 2, 3)]
            substatement.format
        }
    }
    
    def TextSegment textRegion(ISemanticRegion region) {
        return new TextSegment(getTextRegionAccess(), region.offset, region.length)
    }

    override protected initialize(FormatterRequest request) {
        val preferences = request.preferences
        if (preferences instanceof MapBasedPreferenceValues) {
            preferences.put(FormatterPreferenceKeys.indentation, INDENTATION)
        }
        super.initialize(request)
    }
    
}

@FinalFieldsConstructor
class MultilineStringReplacer implements ITextReplacer {
    val TextSegment segment

    override ITextSegment getRegion() {
        segment
    }
    
    override createReplacements(ITextReplacerContext context) {
        val defaultIndentation = context.formatter.preferences.getPreference(FormatterPreferenceKeys.indentation)
        val currentIndentation = context.indentationString
        val indentation = currentIndentation + defaultIndentation
        val original = segment.text
        val splitted = original.substring(1, original.length - 1).split("(\\s(?=\\S)|\\n(?!' '))")
        var currentLine = <String> newLinkedList()
        val lines = <List<String>> newArrayList(currentLine)
        for (s : splitted) {
            val currentLength = currentLine.length
            if (currentLength + s.length > YangFormatter.MAX_LINE_LENGTH || s.length > YangFormatter.MAX_LINE_LENGTH) {
                lines += (currentLine = <String> newLinkedList())
            } else if (s.trim.empty) {
                lines += (currentLine = <String> newLinkedList())
            }
            if (currentLine.length > 0) {
                currentLine += " "
            }
            val word = s.ltrim
            if (!word.empty) {
                currentLine += word
            }
        }
        
        lines.head.add(0, currentIndentation + '"')
        if (lines.size === 1) {
            lines.head += '"'
        }
        if (lines.size > 2) {
            lines.tail.take(lines.size - 1).forEach[
                add(0, indentation + " ")
            ]
        }
        if (lines.size > 1) {
            lines += <String> newLinkedList(indentation, '"')
        }
        val newText = lines.map[join()].join("\n")
        context.addReplacement(segment.replaceWith(newText))
        return context
    }
    
    static def length(List<String> strings)  {
        return strings.fold(0, [r, w| r + w.length])
    }
    
    static def String ltrim(String s) {
        val char space = ' '
        val beginIndex = (0..<s.length).findFirst[i | s.charAt(i) !== space]?:s.length
        return s.substring(beginIndex)
    }
    
}