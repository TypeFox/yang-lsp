package io.typefox.yang.ide.editor.syntaxcoloring;

import java.util.ArrayList;
import java.util.List;

public class SemanticToken {

	private int line, column, length, tokenType, tokenModifiers = -1;

	public SemanticToken(int line, int column, int length, int tokenType, int tokenModifiers) {
		super();
		this.line = line;
		this.column = column;
		this.length = length;
		this.tokenType = tokenType;
		this.tokenModifiers = tokenModifiers;
	}

	public int getLine() {
		return line;
	}

	public int getColumn() {
		return column;
	}

	public int getLength() {
		return length;
	}

	public int getTokenType() {
		return tokenType;
	}

	public int getTokenModifiers() {
		return tokenModifiers;
	}

	public static List<Integer> encodedTokens(List<SemanticToken> tokens) {
		int numTokens = tokens.size();
		List<Integer> data = new ArrayList<>(numTokens * 5);
		int currentLine = 0;
		int currentColumn = 0;
		for (int i = 0; i < numTokens; i++) {
			SemanticToken token = tokens.get(i);
			int line = token.getLine() - 1;
			int column = token.getColumn() - 1;
			if (line < 0 || column < 0) {
				continue;
			}
			int deltaLine = line - currentLine;
			if (deltaLine != 0) {
				currentLine = line;
				currentColumn = 0;
			}
			int deltaColumn = column - currentColumn;
			currentColumn = column;
			// Disallow duplicate/conflict token (if exists)
			if (deltaLine != 0 || deltaColumn != 0 || i == 0) {
				int tokenTypeIndex = token.getTokenType();
				int tokenModifiers = token.getTokenModifiers();
				data.add(deltaLine);
				data.add(deltaColumn);
				data.add(token.getLength());
				data.add(tokenTypeIndex);
				data.add(tokenModifiers);
			}
		}
		return data;
	}
}