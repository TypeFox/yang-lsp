package io.typefox.yang.formatting2

import com.google.inject.Inject
import io.typefox.yang.services.YangGrammarAccess
import io.typefox.yang.yang.Description
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

class YangFormatter extends AbstractFormatter2 {

    @Inject extension YangGrammarAccess

    def dispatch void format(Statement s, extension IFormattableDocument document) {
        s.regionFor.keyword(statementEndAccess.semicolonKeyword_1)
            .prepend[noSpace; highPriority]
            .append[setNewLines(1, 1, 2)]

        val leftCurly = s.regionFor.keyword(statementEndAccess.leftCurlyBracketKeyword_0_0)
        val rightCurly = s.regionFor.keyword(statementEndAccess.rightCurlyBracketKeyword_0_2)

        interior(
            leftCurly.append[newLine],
            rightCurly.append[setNewLines(1, 1, 2)]
        )[indent; highPriority]

        for (substatement : s.substatements) {
            substatement.format
        }
    }
    
    def dispatch void format(Description d, extension IFormattableDocument document) {
        val textRegion = d.regionFor.assignment(descriptionAccess.descriptionAssignment_1).prepend[newLine].textRegion
        addReplacer(new MultilineStringReplacer(textRegion))
        
        for (substatement : d.substatements) {
            substatement.format
        }
    }
    
    def TextSegment textRegion(ISemanticRegion region) {
        return new TextSegment(getTextRegionAccess(), region.offset, region.length)
    }

    override protected initialize(FormatterRequest request) {
        val preferences = request.preferences
        if (preferences instanceof MapBasedPreferenceValues) {
            preferences.put(FormatterPreferenceKeys.indentation, "    ")
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
        val sb = new StringBuilder(currentIndentation)
        sb.append('"')
        var lineLength = 0
        var first = true
        for (s : splitted) {
            lineLength += s.length
            if (lineLength > 72) {
                sb.append("\n") sb.append(indentation) sb.append(" ")
                lineLength = s.length
            } else {
                if (!first) {
                    sb.append(" ")
                }
            }
            first = false
            sb.append(s)
        }
        sb.append("\n") sb.append(indentation) sb.append('"')
        context.addReplacement(segment.replaceWith(sb.toString))
        return context
    }
}