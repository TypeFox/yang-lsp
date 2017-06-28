package io.typefox.yang.scoping

import org.eclipse.xtext.naming.IQualifiedNameConverter

class QualifiedNameConverter extends IQualifiedNameConverter.DefaultImpl {
	
	override getDelimiter() {
		':'
	}
	
}