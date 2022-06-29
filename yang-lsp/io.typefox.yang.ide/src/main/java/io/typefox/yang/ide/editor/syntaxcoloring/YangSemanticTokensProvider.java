package io.typefox.yang.ide.editor.syntaxcoloring;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.SemanticTokens;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.ide.server.Document;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;

public class YangSemanticTokensProvider {

	public SemanticTokens highlightedPositionsToSemanticTokens(final Document doc, final XtextResource resource,
			ISemanticHighlightingCalculator highlightingCalculator, CancelIndicator cancelIndicator) {
		List<SemanticToken> tokens = new ArrayList<>();
		IHighlightedPositionAcceptor acceptor = new IHighlightedPositionAcceptor() {

			@Override
			public void addPosition(int offset, int length, String... ids) {
				for (String styleId : ids) {
					Optional<TokenType> yangStyle = Arrays.stream(TokenType.values())
							.filter(e -> e.getYangStyle().equals(styleId)).findFirst();
					if (yangStyle.isPresent()) {
						Position position = doc.getPosition(offset);
						tokens.add(new SemanticToken(position.getLine() + 1, position.getCharacter() + 1, length,
								yangStyle.get().ordinal(), 0));
					}
				}
			}
		};
		highlightingCalculator.provideHighlightingFor(resource, acceptor, cancelIndicator);
		return new SemanticTokens(SemanticToken.encodedTokens(tokens));
	}
}
