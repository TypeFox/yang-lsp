package io.typefox.yang.diagram;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

import org.eclipse.emf.common.util.URI;
import org.eclipse.lsp4j.InitializeParams;
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.SemanticTokens;
import org.eclipse.lsp4j.SemanticTokensLegend;
import org.eclipse.lsp4j.SemanticTokensParams;
import org.eclipse.lsp4j.SemanticTokensWithRegistrationOptions;
import org.eclipse.lsp4j.ServerCapabilities;
import org.eclipse.sprotty.xtext.ls.SyncDiagramLanguageServer;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.ide.server.Document;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;

import io.typefox.yang.ide.editor.syntaxcoloring.SemanticToken;
import io.typefox.yang.ide.editor.syntaxcoloring.TokenModifier;
import io.typefox.yang.ide.editor.syntaxcoloring.TokenType;

public class YangSyncDiagramLanguageServer extends SyncDiagramLanguageServer {

	@Override
	protected ServerCapabilities createServerCapabilities(InitializeParams params) {
		ServerCapabilities capabilities = super.createServerCapabilities(params);

		SemanticTokensWithRegistrationOptions options = new SemanticTokensWithRegistrationOptions();
		options.setLegend(new SemanticTokensLegend(
				Arrays.stream(TokenType.values()).map(TokenType::toString).collect(Collectors.toList()),
				Arrays.stream(TokenModifier.values()).map(TokenModifier::toString).collect(Collectors.toList())));
		options.setRange(false);
		options.setFull(true);

		capabilities.setSemanticTokensProvider(options);

		return capabilities;
	}

	public CompletableFuture<SemanticTokens> semanticTokensFull(SemanticTokensParams params) {
		return getRequestManager().runRead((cancelIndicator) -> semanticTokensCompute(params, cancelIndicator));
	}

	private SemanticTokens semanticTokensCompute(SemanticTokensParams params, CancelIndicator cancelIndicator) {
		URI uri = getURI(params.getTextDocument());
		ISemanticHighlightingCalculator highlightingCalculator = getService(uri, ISemanticHighlightingCalculator.class);
		if (highlightingCalculator == null) {
			throw new UnsupportedOperationException();
		}
		return getWorkspaceManager().doRead(uri, (final Document doc, final XtextResource resource) -> {
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
		});
	}

}
