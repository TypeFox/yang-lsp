package io.typefox.yang.resource

import org.eclipse.xtext.parsetree.reconstr.impl.TokenUtil
import org.eclipse.xtext.nodemodel.INode

class YangTokenUtil extends TokenUtil {
	
	override isWhitespaceOrCommentNode(INode node) {
		if(node.text == '"' || node.text == "'")
			return true
		super.isWhitespaceOrCommentNode(node)
	}
	
}