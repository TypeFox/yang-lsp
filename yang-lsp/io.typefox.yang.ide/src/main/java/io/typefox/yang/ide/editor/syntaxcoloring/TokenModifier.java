package io.typefox.yang.ide.editor.syntaxcoloring;

import org.eclipse.lsp4j.SemanticTokenModifiers;

public enum TokenModifier {
	DEFAULT(SemanticTokenModifiers.Declaration);

	private String lspName;

	TokenModifier(String lspName) {
		this.lspName = lspName;
	}

	@Override
	public String toString() {
		return lspName;
	}
}
