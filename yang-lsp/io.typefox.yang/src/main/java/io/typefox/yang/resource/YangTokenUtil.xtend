package io.typefox.yang.resource

import org.eclipse.xtext.parsetree.reconstr.impl.TokenUtil
import org.eclipse.xtext.nodemodel.INode
import java.util.regex.Pattern

class YangTokenUtil extends TokenUtil {
	
	public static val HIDDEN_QUOTES_PATTERN = Pattern.compile('["\']\\s*\\+?\\s*')
	
	override isWhitespaceOrCommentNode(INode node) {
		HIDDEN_QUOTES_PATTERN.matcher(node.text).matches || super.isWhitespaceOrCommentNode(node)
	}
	
}