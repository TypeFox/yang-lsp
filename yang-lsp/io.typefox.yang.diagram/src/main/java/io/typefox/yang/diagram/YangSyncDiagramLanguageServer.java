package io.typefox.yang.diagram;

import java.util.Collections;
import java.util.concurrent.CompletableFuture;

import org.apache.log4j.Logger;
import org.eclipse.emf.common.util.URI;
import org.eclipse.lsp4j.InitializeParams;
import org.eclipse.lsp4j.SemanticTokens;
import org.eclipse.lsp4j.SemanticTokensParams;
import org.eclipse.lsp4j.ServerCapabilities;
import org.eclipse.sprotty.xtext.ls.SyncDiagramLanguageServer;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.ide.server.Document;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;

import com.google.inject.Inject;

import io.typefox.yang.ide.editor.syntaxcoloring.YangSemanticTokensProvider;
import io.typefox.yang.ide.server.YangAdditionalServerCapabilities;


public class YangSyncDiagramLanguageServer extends SyncDiagramLanguageServer {
	
	private static final Logger LOG = Logger.getLogger(YangSyncDiagramLanguageServer.class);
	private static final SemanticTokens EMPTY_SEMANTIC_TOKENS = new SemanticTokens(Collections.emptyList());
	
	@Inject
	YangAdditionalServerCapabilities serverAdditions;
	@Inject
	YangSemanticTokensProvider semantikTokens;

	@Override
	protected ServerCapabilities createServerCapabilities(InitializeParams params) {
		ServerCapabilities capabilities = super.createServerCapabilities(params);
		serverAdditions.addAdditionalServerCapabilities(capabilities, params);
		return capabilities;
	}

	public CompletableFuture<SemanticTokens> semanticTokensFull(SemanticTokensParams params) {
		return getRequestManager().runRead((cancelIndicator) -> semanticTokensCompute(params, cancelIndicator));
	}

	private SemanticTokens semanticTokensCompute(SemanticTokensParams params, CancelIndicator cancelIndicator) {
		URI uri = getURI(params.getTextDocument());
		ISemanticHighlightingCalculator highlightingCalculator = getService(uri, ISemanticHighlightingCalculator.class);
		if (highlightingCalculator == null) {
			LOG.error("Semantic Highlighting Calculator service is not registered for URI: " +uri.toString());
			return EMPTY_SEMANTIC_TOKENS;
		}
		return getWorkspaceManager().doRead(uri, (final Document doc, final XtextResource resource) -> {
			return semantikTokens.highlightedPositionsToSemanticTokens(doc, resource,
					highlightingCalculator, cancelIndicator);
		});
	}

}
