package io.typefox.yang.parser.antlr.lexer.jflex;

import org.antlr.runtime.ANTLRStringStream;
import org.antlr.runtime.CommonToken;
import org.antlr.runtime.Lexer;
import org.antlr.runtime.Token;

import com.google.inject.Inject;
import com.google.inject.Provider;

import io.typefox.yang.parser.antlr.lexer.jflex.YangFlexer.CommonTokenWithText;

public class JFlexBasedYangLexerWithLookahead extends JFlexBasedInternalYangLexer {

	private Token currentToken;
	private Token lookAheadToken;
	private Token lookAheadToken2;

	@Inject
	Provider<JFlexBasedInternalYangLexer> prober;

	@Override
	public Token nextToken() {
		Token currentSuperToken = super.nextToken();

		if (currentToken == null) {
			// start: [curr][next][next]
			currentToken = currentSuperToken;
			lookAheadToken = super.nextToken();
			lookAheadToken2 = super.nextToken();
			currentSuperToken = super.nextToken();
		}

		while (canSquash(currentToken, lookAheadToken, lookAheadToken2, currentSuperToken)) {
			// do squash
			Token squashed = squash(currentToken, lookAheadToken, lookAheadToken2, currentSuperToken);
			currentToken = squashed;
			lookAheadToken = super.nextToken();
			lookAheadToken2 = super.nextToken();
			currentSuperToken = super.nextToken();
		}
		Token result = currentToken;
		// push left: [curr][la1][la2] -> [la1][la2][next]
		currentToken = lookAheadToken;
		lookAheadToken = lookAheadToken2;
		lookAheadToken2 = currentSuperToken;
		return result;
	}

	@Override
	public void reset() {
		super.reset();
		currentToken = lookAheadToken = lookAheadToken2 = null;
	}

	/**
	 * 
	 * @return <code>true</code> in case [ID][HIDDEN][HIDDEN][ID]
	 */
	private boolean canSquash(Token currentToken, Token lookAheadToken, Token lookAheadToken2,
			Token currentSuperToken) {
		if (currentToken.getType() == RULE_ID && lookAheadToken.getType() == RULE_HIDDEN
				&& lookAheadToken2.getType() == RULE_HIDDEN && currentSuperToken.getType() == RULE_ID) {
			Lexer lexer = prober.get();
			lexer.setCharStream(new ANTLRStringStream(currentToken.getText() + currentSuperToken.getText()));
			return lexer.nextToken().getType() == RULE_ID && lexer.nextToken().getType() == EOF;
		}
		return false;
	}

	/**
	 * 
	 * @return for case [ID][HIDDEN][HIDDEN][ID] -> [ID+ID]
	 */
	private Token squash(Token currentToken, Token lookAheadToken, Token lookAheadToken2, Token currentSuperToken) {
		CommonToken lookAheadCommonToken = (CommonToken) lookAheadToken;
		CommonToken squashed = new CommonTokenWithText(currentToken.getText() + currentSuperToken.getText(),
				currentSuperToken.getType(), lookAheadCommonToken.getChannel(),
				((CommonToken) currentToken).getStartIndex(), ((CommonToken) currentSuperToken).getStopIndex());
		return squashed;
	}
}
