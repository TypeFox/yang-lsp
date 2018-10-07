package io.typefox.yang.ide.symbols

import io.typefox.yang.utils.YangNameUtils
import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.SchemaNode
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ide.server.symbol.DocumentSymbolMapper.DocumentSymbolNameProvider
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

class YangDocumentSymbolNameProvider extends DocumentSymbolNameProvider {

	override getName(EObject object) {
		if (object instanceof SchemaNode) {
			return object.name ?: object.yangName;
		} else if (object instanceof Augment) {
			return NodeModelUtils.findActualNodeFor(object.path).text.trim ?: object.yangName;
		}
		super.getName(object);
	}

	protected def String getYangName(Object clazz) {
		return YangNameUtils.getYangName(clazz);
	}

}
