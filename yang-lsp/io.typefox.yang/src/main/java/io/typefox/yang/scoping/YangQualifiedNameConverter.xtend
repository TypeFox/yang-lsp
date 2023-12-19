package io.typefox.yang.scoping

import org.eclipse.xtext.naming.IQualifiedNameConverter

class YangQualifiedNameConverter extends IQualifiedNameConverter.DefaultImpl {
	
	override getDelimiter() {
		':'
	}
	
}