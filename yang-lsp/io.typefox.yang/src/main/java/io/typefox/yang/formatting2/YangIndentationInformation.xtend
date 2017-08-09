package io.typefox.yang.formatting2

import org.eclipse.xtext.formatting.IIndentationInformation

/**
 * Indentation information for YANG. Instead of the default tab ({@code \t}) it uses
 * four spaces ({@code [ ][ ][ ][ ]}).
 * 
 * @author akos.kitta
 */
class YangIndentationInformation implements IIndentationInformation {
	
	override getIndentString() {
		return '    ';
	}
	
}