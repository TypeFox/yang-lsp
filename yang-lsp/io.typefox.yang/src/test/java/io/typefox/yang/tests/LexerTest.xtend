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
	
	@Test def void testExpression() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			when ./myFunction(23.4,.5+(.45div(23)));
		''')
		l.assertNextToken(When,'when')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(FullStop,'.')
		l.assertNextToken(Solidus,'/')
		l.assertNextToken(RULE_ID,'myFunction')
		l.assertNextToken(LeftParenthesis,'(')
		l.assertNextToken(RULE_NUMBER,'23.4')
		l.assertNextToken(Comma,',')
		l.assertNextToken(RULE_NUMBER,'.5')
		l.assertNextToken(PlusSign,'+')
		l.assertNextToken(LeftParenthesis,'(')
		l.assertNextToken(RULE_NUMBER,'.45')
		l.assertNextToken(Div,'div')
		l.assertNextToken(LeftParenthesis,'(')
		l.assertNextToken(RULE_NUMBER,'23')
		l.assertNextToken(RightParenthesis,')')
		l.assertNextToken(RightParenthesis,')')
		l.assertNextToken(RightParenthesis,')')
		l.assertNextToken(Semicolon,';')
	}
	
	@Test def void testKeyExpression() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			key "k1 k2";
		''')
		l.assertNextToken(Key,'key')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_HIDDEN,'"')
		l.assertNextToken(RULE_ID,'k1')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_ID,'k2')
		l.assertNextToken(RULE_HIDDEN,'"')
		l.assertNextToken(Semicolon,';')
	}
	
	@Test def void testNonExpression() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			description ./myFunction(23.4,.5+(.45div(23)));
		''')
		l.assertNextToken(Description,'description')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_STRING,'./myFunction(23.4,.5+(.45div(23)))')
		l.assertNextToken(Semicolon,';')
	}
	
	@Test def void testBlackBoxDQString() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			  revision 2015-05-26 {
			    description
			      "Formal Project Review Draft 1.";
			    reference "EVC Ethernet Services Definitions YANG Modules " +
			    		"(MEF XX), TBD";
			  }
		''')	
	}
	
	@Test def void testExpressionSQString() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			when './foo[x = "holla"] '
				+ /* test */ 
				'and myFunction(23.4, .5 + (.45 div 23))';
		''')
		l.assertNextToken(When,'when')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_HIDDEN,"'")
		l.assertNextToken(FullStop,'.')
		l.assertNextToken(Solidus,'/')
		l.assertNextToken(RULE_ID,'foo')
		l.assertNextToken(LeftSquareBracket,'[')
		l.assertNextToken(RULE_ID,'x')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(EqualsSign,'=')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_STRING,'"holla"')
		l.assertNextToken(RightSquareBracket,']')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_HIDDEN,"'
	+ /* test */ 
	")
		l.assertNextToken(RULE_HIDDEN,"'")
		l.assertNextToken(And,'and')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_ID,'myFunction')
		l.assertNextToken(LeftParenthesis,'(')
		l.assertNextToken(RULE_NUMBER,'23.4')
		l.assertNextToken(Comma,',')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_NUMBER,'.5')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(PlusSign,'+')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(LeftParenthesis,'(')
		l.assertNextToken(RULE_NUMBER,'.45')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(Div,'div')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_NUMBER,'23')
		l.assertNextToken(RightParenthesis,')')
		l.assertNextToken(RightParenthesis,')')
		l.assertNextToken(RULE_HIDDEN,"'")
		l.assertNextToken(Semicolon,';')
	}
	
	@Test def void testExpressionString() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			when "./foo[x = \"holla\"] "
				+ /* test */ 
				"and myFunction(23.4, .5 + (.45 div 23))";
		''')
		l.assertNextToken(When,'when')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_HIDDEN,'"')
		l.assertNextToken(FullStop,'.')
		l.assertNextToken(Solidus,'/')
		l.assertNextToken(RULE_ID,'foo')
		l.assertNextToken(LeftSquareBracket,'[')
		l.assertNextToken(RULE_ID,'x')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(EqualsSign,'=')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_STRING,'\\\"holla\\\"')
		l.assertNextToken(RightSquareBracket,']')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_HIDDEN,'"
	+ /* test */ 
	')
		l.assertNextToken(RULE_HIDDEN,'"')
		l.assertNextToken(And,'and')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_ID,'myFunction')
		l.assertNextToken(LeftParenthesis,'(')
		l.assertNextToken(RULE_NUMBER,'23.4')
		l.assertNextToken(Comma,',')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_NUMBER,'.5')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(PlusSign,'+')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(LeftParenthesis,'(')
		l.assertNextToken(RULE_NUMBER,'.45')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(Div,'div')
		l.assertNextToken(RULE_WS,' ')
		l.assertNextToken(RULE_NUMBER,'23')
		l.assertNextToken(RightParenthesis,')')
		l.assertNextToken(RightParenthesis,')')
		l.assertNextToken(RULE_HIDDEN,'"')
		l.assertNextToken(Semicolon,';')
	}
	
	@Test def void testCustomStatement() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			foo:bar 'holz';
		''')
		l.assertNextToken(RULE_EXTENSION_NAME,'foo:bar')
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
		l.assertNextToken(RULE_HIDDEN, '"')
		l.assertNextToken(RULE_ID, 'module')
		l.assertNextToken(RULE_HIDDEN, '"')
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
	
	@Test def void test_MinMaxRangeExpression() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			range 1 | min..2|3..max|min..max  |  min .. max
		''')
		l.assertNextToken(Range, 'range')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_NUMBER, '1')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(VerticalLine, '|')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(Min, 'min')
		l.assertNextToken(FullStopFullStop, '..')
		l.assertNextToken(RULE_NUMBER, '2')
		l.assertNextToken(VerticalLine, '|')
		l.assertNextToken(RULE_NUMBER, '3')
		l.assertNextToken(FullStopFullStop, '..')
		l.assertNextToken(Max, 'max')
		l.assertNextToken(VerticalLine, '|')
		l.assertNextToken(Min, 'min')
		l.assertNextToken(FullStopFullStop, '..')
		l.assertNextToken(Max, 'max')
		l.assertNextToken(RULE_WS, '  ')
		l.assertNextToken(VerticalLine, '|')
		l.assertNextToken(RULE_WS, '  ')
		l.assertNextToken(Min, 'min')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(FullStopFullStop, '..')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(Max, 'max')
	}
	
	@Test def void test_SignedRangeExpression() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			range -1 | -2..2|+3..4
		''')
		l.assertNextToken(Range, 'range')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_NUMBER, '-1')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(VerticalLine, '|')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_NUMBER, '-2')
		l.assertNextToken(FullStopFullStop, '..')
		l.assertNextToken(RULE_NUMBER, '2')
		l.assertNextToken(VerticalLine, '|')
		l.assertNextToken(RULE_NUMBER, '+3')
		l.assertNextToken(FullStopFullStop, '..')
		l.assertNextToken(RULE_NUMBER, '4')
	}
	
	@Test def void test_singleQuotedString() {
		val l = lexer.get;
		l.charStream = new ANTLRStringStream('''
			pattern '((:|[0-9a-fA-F]{0,4}):)([0-9a-fA-F]{0,4}:){0,5}'
			  + '((([0-9a-fA-F]{0,4}:)?(:|[0-9a-fA-F]{0,4}))|'
			  + '(((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}'
			  + '(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])))'
			  + '(%[\p{N}\p{L}]+)?';
		''')
		l.assertNextToken(Pattern, 'pattern')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_STRING, "'((:|[0-9a-fA-F]{0,4}):)([0-9a-fA-F]{0,4}:){0,5}'")
		l.assertNextToken(RULE_WS, System.lineSeparator + '  ')
		l.assertNextToken(RULE_HIDDEN, '+')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_STRING, "'((([0-9a-fA-F]{0,4}:)?(:|[0-9a-fA-F]{0,4}))|'")
		l.assertNextToken(RULE_WS, System.lineSeparator + '  ')
		l.assertNextToken(RULE_HIDDEN, '+')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_STRING, "'(((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\\.){3}'")
		l.assertNextToken(RULE_WS, System.lineSeparator + '  ')
		l.assertNextToken(RULE_HIDDEN, '+')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_STRING, "'(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])))'")
		l.assertNextToken(RULE_WS, System.lineSeparator + '  ')
		l.assertNextToken(RULE_HIDDEN, '+')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_STRING, "'(%[\\p{N}\\p{L}]+)?'")
	}
	
	@Test def void test_Comments() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			/*
			    augment "/policy:policies/policy:policy-entry"
			        + "/policy:classifier-entry"
			        + "/policy:classifier-action-entry-cfg/"
			        + "policy:action-cfg-params/action:marking/action:marking-cfg" {
			            description "extend the marking dscp to add set from a tablemap";
			            uses SET-VAL-TABLEMAP;
			        }
			*/
		''')
		l.assertNextToken(RULE_ML_COMMENT, '''
			/*
			    augment "/policy:policies/policy:policy-entry"
			        + "/policy:classifier-entry"
			        + "/policy:classifier-action-entry-cfg/"
			        + "policy:action-cfg-params/action:marking/action:marking-cfg" {
			            description "extend the marking dscp to add set from a tablemap";
			            uses SET-VAL-TABLEMAP;
			        }
			*/''')
		l.assertNextToken(RULE_WS, '\n')
		l.assertNextToken(EOF,null)
	}
	
	@Test def void testString() {
		val l = lexer.get
		l.charStream = new ANTLRStringStream('''
			description "User variable type; only 'global' variables can \\
					be saved in the yangcli uservars file.";
		''')
		l.assertNextToken(Description, 'description')
		l.assertNextToken(RULE_WS, ' ')
		l.assertNextToken(RULE_STRING, null)
		l.assertNextToken(Semicolon, ';')
		l.assertNextToken(RULE_WS, null)
		l.assertNextToken(EOF, null)
	}
	
	private def void assertNextToken(Lexer it, int id, String text) {
		val t = nextToken
		assertEquals(id, t.type)
		if (text !== null)
			assertEquals(text, t.text)
	}
	
}
