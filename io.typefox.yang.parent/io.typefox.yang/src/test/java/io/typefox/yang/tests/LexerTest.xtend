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
