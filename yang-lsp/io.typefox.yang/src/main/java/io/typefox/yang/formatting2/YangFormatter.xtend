package io.typefox.yang.formatting2

import com.google.inject.Inject
import io.typefox.yang.services.YangGrammarAccess
import io.typefox.yang.yang.Statement
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.eclipse.xtext.formatting2.FormatterRequest
import org.eclipse.xtext.formatting2.FormatterPreferenceKeys
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

    override protected initialize(FormatterRequest request) {
        val preferences = request.preferences
        if (preferences instanceof MapBasedPreferenceValues) {
            preferences.put(FormatterPreferenceKeys.indentation, "    ")
        }
        super.initialize(request)
    }
}
