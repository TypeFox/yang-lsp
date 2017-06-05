package io.typefox.yang.tests

import com.google.inject.Inject
import com.google.inject.Provider
import io.typefox.yang.parser.antlr.lexer.jflex.JFlexBasedInternalYangLexer
import org.antlr.runtime.ANTLRStringStream
import org.eclipse.xtext.parser.antlr.Lexer
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static io.typefox.yang.parser.antlr.internal.InternalYangParser.*
import static org.junit.Assert.*

@InjectWith(YangInjectorProvider)
@RunWith(XtextRunner)
class LexerTest {

	@Inject Provider<JFlexBasedInternalYangLexer> lexer
	
	@Test def void testExpressionString() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			when "./foo[x = \"holla\"] and myFunction(23.4, .5 + (.45 div 23))";
		''')
		l.assertNextToken(When,'when')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(QuotationMark,'"')
		l.assertNextToken(FullStop,'.')
		l.assertNextToken(Solidus,'/')
		l.assertNextToken(RULE_ID,'foo')
		l.assertNextToken(LeftSquareBracket,'[')
		l.assertNextToken(RULE_ID,'x')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_OPERATOR,'=')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_STRING,'\\\"holla\\\"')
		l.assertNextToken(RightSquareBracket,']')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_OPERATOR,'and')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_ID,'myFunction')
		l.assertNextToken(LeftParenthesis,'(')
		l.assertNextToken(RULE_NUMBER,'23.4')
		l.assertNextToken(Comma,',')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_NUMBER,'.5')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_OPERATOR,'+')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(LeftParenthesis,'(')
		l.assertNextToken(RULE_NUMBER,'.45')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_OPERATOR,'div')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_NUMBER,'23')
		l.assertNextToken(RightParenthesis,')')
		l.assertNextToken(RightParenthesis,')')
		l.assertNextToken(QuotationMark,'"')
		l.assertNextToken(Semicolon,';')
	}
	
	@Test def void testCustomStatement() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			foo:bar 'holz';
		''')
		l.assertNextToken(RULE_ID,'foo')
		l.assertNextToken(Colon,':')
		l.assertNextToken(RULE_ID,'bar')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_STRING,"'holz'")
		l.assertNextToken(Semicolon,';')
	}

	@Test def void testLexer() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			module 212-$556C {
			  path "module"
			}
		''')
		l.assertNextToken(Module, 'module')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_STRING, '212-$556C')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(LeftCurlyBracket, '{')
		l.assertNextToken(RULE_WS, '\n  ')
		l.assertNextToken(Path, 'path')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(QuotationMark, '"')
		l.assertNextToken(RULE_ID, 'module')
		l.assertNextToken(QuotationMark, '"')
		l.assertNextToken(RULE_WS, '\n')
		l.assertNextToken(RightCurlyBracket, '}')
	}
	
	
	@Test def void test_DoubleQuotedString() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			module "foo"
		''')
		l.assertNextToken(Module, 'module')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_STRING, '"foo"')
	}
	
	@Test def void test_SingleQuotedString() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			module 'foo-bar42'
		''')
		l.assertNextToken(Module, 'module')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_STRING, "'foo-bar42'")
	}
	
	
	private def void assertNextToken(Lexer it, int id, String text) {
		val t = nextToken
		assertEquals(text, t.text)
		assertEquals(id, t.type)
	}
	
}
