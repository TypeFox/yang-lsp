package io.typefox.yang.formatting2

import com.google.inject.Inject
import io.typefox.yang.services.YangGrammarAccess
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Statement
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
import io.typefox.yang.yang.YangVersion

class YangFormatter extends AbstractFormatter2 {
    
    static val INDENTATION = "    "

    @Inject extension YangGrammarAccess

    def dispatch void format(Module m, extension IFormattableDocument it) {
        m.regionFor.assignment(moduleAccess.nameAssignment_1).surround[oneSpace]
        formatStatement(m)
    }
    
    def dispatch void format(Description d, extension IFormattableDocument it) {
        val textRegion = d.regionFor.assignment(descriptionAccess.descriptionAssignment_1).prepend[newLine].textRegion
        addReplacer(new MultilineStringReplacer(textRegion))
        formatStatement(d)
    }
    
    def dispatch void format(YangVersion v, extension IFormattableDocument it) {
        v.regionFor.assignment(yangVersionAccess.yangVersionAssignment_1).surround[oneSpace]
        formatStatement(v)
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
        val splitted = original.substring(1, original.length - 1).split("\\s(?=\\S)")
        val sb = new StringBuilder(currentIndentation).append('"')
        var lineLength = 0
        var first = true
        var singleline = true
        for (s : splitted) {
            if ((lineLength += s.length) > 72) {
                singleline = false
                sb.append("\n").append(indentation).append(" ")
                lineLength = s.length
            } else {
                if (!first) {
                    sb.append(" ")
                }
            }
            first = false
            sb.append(s.replace("\n", "\n" + currentIndentation + " " ))
        }
        if (!singleline) {
            sb.append("\n").append(indentation)
        }
        sb.append('"')
        context.addReplacement(segment.replaceWith(sb.toString))
        return context
    }
}