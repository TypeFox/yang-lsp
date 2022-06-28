package io.typefox.yang.ide.editor.syntaxcoloring;

import org.eclipse.lsp4j.SemanticTokenTypes;

import io.typefox.yang.ide.editor.syntaxcoloring.YangSemanticHighlightingCalculator.Styles;

public enum TokenType {
	NORMAL_DATA_NODE_STYLE(Styles.NORMAL_DATA_NODE_STYLE, SemanticTokenTypes.Type),
	ALTERNATIVE_DATA_NODE_STYLE(Styles.ALTERNATIVE_DATA_NODE_STYLE, SemanticTokenTypes.Class),
	REUSABLE_DATA_NODE_STYLE(Styles.REUSABLE_DATA_NODE_STYLE, SemanticTokenTypes.Enum),
	EXTENDIBLE_MODULE_STATEMENT_STYLE(Styles.EXTENDIBLE_MODULE_STATEMENT_STYLE, SemanticTokenTypes.Interface),
	CONDITIONAL_MODULE_STATEMENT_STYLE(Styles.CONDITIONAL_MODULE_STATEMENT_STYLE, SemanticTokenTypes.Struct),
	CONSTRAINT_MODULE_STATEMENT_STYLE(Styles.CONSTRAINT_MODULE_STATEMENT_STYLE, SemanticTokenTypes.Parameter),
	INTERFACE_STATEMENT_STYLE(Styles.INTERFACE_STATEMENT_STYLE, SemanticTokenTypes.Variable),
	REFERENCEABLE_STATEMENT_STYLE(Styles.REFERENCEABLE_STATEMENT_STYLE, SemanticTokenTypes.EnumMember),
	DESCRIPTION_STYLE(Styles.DESCRIPTION_STYLE, SemanticTokenTypes.Namespace),
	KEY_STYLE(Styles.KEY_STYLE, SemanticTokenTypes.Function);

	private String lspName, yangStyle;

	TokenType(String yangStyle, String lspName) {
		this.lspName = lspName;
		this.yangStyle = yangStyle;
	}

	@Override
	public String toString() {
		return lspName;
	}

	public String getYangStyle() {
		return yangStyle;
	}
}
