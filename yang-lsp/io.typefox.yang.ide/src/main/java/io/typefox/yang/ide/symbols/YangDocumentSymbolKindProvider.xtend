package io.typefox.yang.ide.symbols

import org.eclipse.xtext.ide.server.symbol.DocumentSymbolMapper.DocumentSymbolKindProvider
import org.eclipse.emf.ecore.EClass

import static io.typefox.yang.yang.YangPackage.Literals.*
import static org.eclipse.lsp4j.SymbolKind.*

class YangDocumentSymbolKindProvider extends DocumentSymbolKindProvider {

	override protected getSymbolKind(EClass clazz) {
		return switch (clazz) {
			case AUGMENT: Method
			case CASE: String
			case CHOICE: Number
			case CONTAINER: Namespace
			case EXTENSION: Module
			case FEATURE: Boolean
			case GROUPING: Class
			case IDENTITY: Constant
			case INPUT: Property
			case LEAF: Variable
			case LEAF_LIST: Array
			case OUTPUT: Constructor
			case NOTIFICATION: Function
			case RPC: Method
			case TYPEDEF: Enum
			default: Field
		}
	}

}
