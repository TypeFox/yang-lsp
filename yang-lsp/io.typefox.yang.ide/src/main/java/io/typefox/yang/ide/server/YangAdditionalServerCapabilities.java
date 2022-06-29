package io.typefox.yang.ide.server;

import java.util.Arrays;
import java.util.stream.Collectors;

import org.eclipse.lsp4j.InitializeParams;
import org.eclipse.lsp4j.SemanticTokensLegend;
import org.eclipse.lsp4j.SemanticTokensWithRegistrationOptions;
import org.eclipse.lsp4j.ServerCapabilities;

import io.typefox.yang.ide.editor.syntaxcoloring.TokenModifier;
import io.typefox.yang.ide.editor.syntaxcoloring.TokenType;

public class YangAdditionalServerCapabilities {

	public void addAdditionalServerCapabilities(ServerCapabilities capabilities, InitializeParams params) {
		SemanticTokensWithRegistrationOptions options = new SemanticTokensWithRegistrationOptions();
		options.setLegend(new SemanticTokensLegend(
				Arrays.stream(TokenType.values()).map(TokenType::toString).collect(Collectors.toList()),
				Arrays.stream(TokenModifier.values()).map(TokenModifier::toString).collect(Collectors.toList())));
		options.setRange(false);
		options.setFull(true);
		capabilities.setSemanticTokensProvider(options);
	}

}
