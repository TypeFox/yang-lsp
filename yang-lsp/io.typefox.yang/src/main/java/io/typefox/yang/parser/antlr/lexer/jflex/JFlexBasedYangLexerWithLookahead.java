package io.typefox.yang.parser.antlr.lexer.jflex;

import java.util.function.BiFunction;

import org.antlr.runtime.CommonToken;
import org.antlr.runtime.Token;
import org.eclipse.xtext.util.Triple;
import org.eclipse.xtext.util.Tuples;

import io.typefox.yang.parser.antlr.lexer.jflex.YangFlexer.CommonTokenWithText;

public class JFlexBasedYangLexerWithLookahead extends JFlexBasedInternalYangLexer {

	private LookaheadState lh = new LookaheadState();

	@Override
	public Token nextToken() {
		Token currentSuperToken = super.nextToken();

		if (lh.currentToken == null) {
			// start: [curr][next][next]
			lh.currentToken = currentSuperToken;
			lh.lookAheadToken = super.nextToken();
			lh.lookAheadToken2 = super.nextToken();
			currentSuperToken = super.nextToken();
		}
		BiFunction<LookaheadState, Token, Triple<Token, Token, Token>> strategy = canSquash(lh,
				currentSuperToken);
		while (strategy != null) {
			// do squash
			Triple<Token, Token, Token> squashed = strategy.apply(lh, currentSuperToken);
			if (squashed.getFirst() == null)
				throw new IllegalStateException();
			lh.currentToken = squashed.getFirst();
			lh.lookAheadToken = squashed.getSecond();
			if (lh.lookAheadToken == null)
				lh.lookAheadToken = super.nextToken();
			lh.lookAheadToken2 = squashed.getThird();
			if (lh.lookAheadToken2 == null)
				lh.lookAheadToken2 = super.nextToken();

			currentSuperToken = super.nextToken();

			strategy = canSquash(lh, currentSuperToken);
		}
		Token result = lh.currentToken;
		lh.pushLeft(currentSuperToken);
		return result;
	}

	@Override
	public void reset() {
		super.reset();
		lh.reset();
	}

	/**
	 * ID is an RULE_ID or a valid part of it
	 * 
	 * @return <code>true</code> in case [ID][HIDDEN][HIDDEN][ID]
	 */
	private BiFunction<LookaheadState, Token, Triple<Token, Token, Token>> canSquash(LookaheadState lhState,
			Token currentSuperToken) {
		if (lhState.currentToken.getType() == RULE_ID && lhState.lookAheadToken.getType() == RULE_HIDDEN
				&& lhState.lookAheadToken2.getType() == RULE_HIDDEN && currentSuperToken.getType() == RULE_ID) {
			return new BiFunction<LookaheadState, Token, Triple<Token, Token, Token>>() {
				/**
				 * for case 1: [ID][HIDDEN][HIDDEN][ID] -> [ID+ID] <br>
				 */
				@Override
				public Triple<Token, Token, Token> apply(LookaheadState currState, Token currentSuperToken) {
					CommonToken currentCommonToken = (CommonToken) currState.currentToken;
					Token squashed = new CommonTokenWithText(
							currState.currentToken.getText() + currentSuperToken.getText(),
							currState.currentToken.getType(), currState.currentToken.getChannel(),
							currentCommonToken.getStartIndex(), ((CommonToken) currentSuperToken).getStopIndex());
					return Tuples.create(squashed, null, null);
				}
			};
		}
		if (delegate.yystate() != YangFlexer.IN_XPATH_EXPRESSION_STRING) {
			/* Not in XPATH Expression */
			if (lhState.currentToken.getType() == RULE_ID && lhState.lookAheadToken.getType() == RULE_HIDDEN
					&& lhState.lookAheadToken2.getType() == RULE_HIDDEN && isIdPart(currentSuperToken.getType())) {
				return new BiFunction<LookaheadState, Token, Triple<Token, Token, Token>>() {
					/**
					 * for case 2a: [ID][HIDDEN][HIDDEN][NUMBER/DOT/MINUS] ->
					 * [ID][HIDDEN][NUMBER/DOT/MINUS] <br>
					 */
					@Override
					public Triple<Token, Token, Token> apply(LookaheadState t, Token currentSuperToken) {
						CommonToken lookAheadTokenCommonToken = (CommonToken) t.lookAheadToken;
						Token squashed = new CommonTokenWithText(
								t.lookAheadToken.getText() + t.lookAheadToken2.getText(), t.lookAheadToken.getType(),
								t.lookAheadToken.getChannel(), lookAheadTokenCommonToken.getStartIndex(),
								((CommonToken) t.lookAheadToken2).getStopIndex());
						return Tuples.create(t.currentToken, squashed, currentSuperToken);
					}
				};
			}
			/* Not in XPATH Expression */
			if (lhState.currentToken.getType() == RULE_ID && lhState.lookAheadToken.getType() == RULE_HIDDEN
					&& isIdPart(lhState.lookAheadToken2.getType()) && currentSuperToken.getType() == RULE_ID) {
				return new BiFunction<LookaheadState, Token, Triple<Token, Token, Token>>() {
					/**
					 * for case 2b: [ID][HIDDEN][NUMBER/DOT/MINUS][ID] ->
					 * [ID+NUMBER/DOT/MINUS+ID]<br>
					 */
					@Override
					public Triple<Token, Token, Token> apply(LookaheadState t, Token currentSuperToken) {
						CommonToken currentCommonToken = (CommonToken) t.currentToken;
						Token squashed = new CommonTokenWithText(
								t.currentToken.getText() + lhState.lookAheadToken2.getText()
										+ currentSuperToken.getText(),
								t.currentToken.getType(), t.currentToken.getChannel(),
								currentCommonToken.getStartIndex(), ((CommonToken) currentSuperToken).getStopIndex());
						return Tuples.create(squashed, null, null);
					}
				};
			}
		}
		return null;
	}

	private boolean isIdPart(int type) {
		return type == RULE_SYMBOLIC_OPERATOR || type == RULE_NUMBER || type == FullStop;
	}

	protected static class LookaheadState {
		
		protected Token currentToken;
		protected Token lookAheadToken;
		protected Token lookAheadToken2;

		protected void reset() {
			this.currentToken = null;
			this.lookAheadToken = null;
			this.lookAheadToken2 = null;
		}

		/**
		 * push left: [curr][la1][la2] -> [la1][la2][next]
		 * 
		 * @param next = [next]
		 */
		protected void pushLeft(Token next) {
			currentToken = lookAheadToken;
			lookAheadToken = lookAheadToken2;
			lookAheadToken2 = next;
		}

		@Override
		public java.lang.String toString() {
			return "[" + currentToken + "] <- [" + lookAheadToken + "] <- [" + lookAheadToken2 + "]";
		}
	}
}
