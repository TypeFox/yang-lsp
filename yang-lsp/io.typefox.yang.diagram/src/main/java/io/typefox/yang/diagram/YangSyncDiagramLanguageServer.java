package io.typefox.yang.diagram;

import java.util.Collections;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import org.apache.log4j.Logger;
import org.eclipse.emf.common.util.URI;
import org.eclipse.lsp4j.CodeAction;
import org.eclipse.lsp4j.CodeActionParams;
import org.eclipse.lsp4j.Command;
import org.eclipse.lsp4j.CompletionItem;
import org.eclipse.lsp4j.CompletionList;
import org.eclipse.lsp4j.CompletionParams;
import org.eclipse.lsp4j.DefinitionParams;
import org.eclipse.lsp4j.DocumentFormattingParams;
import org.eclipse.lsp4j.DocumentHighlight;
import org.eclipse.lsp4j.DocumentHighlightParams;
import org.eclipse.lsp4j.DocumentSymbol;
import org.eclipse.lsp4j.DocumentSymbolParams;
import org.eclipse.lsp4j.Hover;
import org.eclipse.lsp4j.HoverParams;
import org.eclipse.lsp4j.InitializeParams;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.LocationLink;
import org.eclipse.lsp4j.ReferenceParams;
import org.eclipse.lsp4j.RenameParams;
import org.eclipse.lsp4j.SemanticTokens;
import org.eclipse.lsp4j.SemanticTokensParams;
import org.eclipse.lsp4j.ServerCapabilities;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.TextEdit;
import org.eclipse.lsp4j.WorkspaceEdit;
import org.eclipse.lsp4j.jsonrpc.messages.Either;
import org.eclipse.sprotty.xtext.ls.SyncDiagramLanguageServer;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.ide.server.Document;
import org.eclipse.xtext.preferences.PreferenceKey;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;

import com.google.inject.Inject;

import io.typefox.yang.ide.editor.syntaxcoloring.YangSemanticTokensProvider;
import io.typefox.yang.ide.server.YangAdditionalServerCapabilities;
import io.typefox.yang.ide.server.YangFeatureToggleKeys;
import io.typefox.yang.settings.PreferenceValuesProvider;


public class YangSyncDiagramLanguageServer extends SyncDiagramLanguageServer {
	
	private static final Logger LOG = Logger.getLogger(YangSyncDiagramLanguageServer.class);
	private static final SemanticTokens EMPTY_SEMANTIC_TOKENS = new SemanticTokens(Collections.emptyList());
	public static final PreferenceKey SEMANTIC_TOKENS_ENABLED = new PreferenceKey("semantic-tokens", "on");
	
	@Inject
	YangAdditionalServerCapabilities serverAdditions;
	@Inject
	YangSemanticTokensProvider semantikTokens;
	@Inject
	PreferenceValuesProvider preferenceProvider;

	private boolean isEnabled(URI uri, PreferenceKey key) {
		if (uri == null || !uri.isFile()) {
			return true;
		}
		try {
			return "on".equals(getWorkspaceManager().doRead(uri, (doc, resource) ->
				preferenceProvider.getPreferenceValues(resource).getPreference(key)));
		} catch (Exception e) {
			return true;
		}
	}

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
			return EMPTY_SEMANTIC_TOKENS;
		}
		return getWorkspaceManager().doRead(uri, (final Document doc, final XtextResource resource) -> {
			String enabled = preferenceProvider.getPreferenceValues(resource).getPreference(SEMANTIC_TOKENS_ENABLED);
			if (!"on".equals(enabled)) {
				return EMPTY_SEMANTIC_TOKENS;
			}
			return semantikTokens.highlightedPositionsToSemanticTokens(doc, resource,
					highlightingCalculator, cancelIndicator);
		});
	}

	@Override
	protected Either<List<CompletionItem>, CompletionList> completion(CancelIndicator cancelIndicator, CompletionParams params) {
		if (!isEnabled(getURI(params), YangFeatureToggleKeys.COMPLETION)) {
			return Either.forRight(new CompletionList(Collections.emptyList()));
		}
		return super.completion(cancelIndicator, params);
	}

	@Override
	protected Hover hover(HoverParams params, CancelIndicator cancelIndicator) {
		if (!isEnabled(getURI(params), YangFeatureToggleKeys.HOVER)) {
			return new Hover();
		}
		return super.hover(params, cancelIndicator);
	}

	@Override
	protected Either<List<? extends Location>, List<? extends LocationLink>> definition(DefinitionParams params, CancelIndicator cancelIndicator) {
		if (!isEnabled(getURI(params), YangFeatureToggleKeys.DEFINITION)) {
			return Either.forLeft(Collections.emptyList());
		}
		return super.definition(params, cancelIndicator);
	}

	@Override
	protected List<? extends Location> references(ReferenceParams params, CancelIndicator cancelIndicator) {
		if (!isEnabled(getURI(params), YangFeatureToggleKeys.REFERENCES)) {
			return Collections.emptyList();
		}
		return super.references(params, cancelIndicator);
	}

	@Override
	protected List<Either<SymbolInformation, DocumentSymbol>> documentSymbol(DocumentSymbolParams params, CancelIndicator cancelIndicator) {
		if (!isEnabled(getURI(params.getTextDocument()), YangFeatureToggleKeys.DOCUMENT_SYMBOLS)) {
			return Collections.emptyList();
		}
		return super.documentSymbol(params, cancelIndicator);
	}

	@Override
	protected List<? extends DocumentHighlight> documentHighlight(DocumentHighlightParams params, CancelIndicator cancelIndicator) {
		if (!isEnabled(getURI(params), YangFeatureToggleKeys.DOCUMENT_HIGHLIGHT)) {
			return Collections.emptyList();
		}
		return super.documentHighlight(params, cancelIndicator);
	}

	@Override
	public CompletableFuture<WorkspaceEdit> rename(RenameParams params) {
		if (!isEnabled(getURI(params.getTextDocument()), YangFeatureToggleKeys.RENAME)) {
			return CompletableFuture.completedFuture(new WorkspaceEdit());
		}
		return super.rename(params);
	}

	@Override
	protected List<Either<Command, CodeAction>> codeAction(CodeActionParams params, CancelIndicator cancelIndicator) {
		if (!isEnabled(getURI(params.getTextDocument()), YangFeatureToggleKeys.CODE_ACTIONS)) {
			return Collections.emptyList();
		}
		return super.codeAction(params, cancelIndicator);
	}

	@Override
	protected List<? extends TextEdit> formatting(DocumentFormattingParams params, CancelIndicator cancelIndicator) {
		if (!isEnabled(getURI(params.getTextDocument()), YangFeatureToggleKeys.FORMATTING)) {
			return Collections.emptyList();
		}
		return super.formatting(params, cancelIndicator);
	}

}
