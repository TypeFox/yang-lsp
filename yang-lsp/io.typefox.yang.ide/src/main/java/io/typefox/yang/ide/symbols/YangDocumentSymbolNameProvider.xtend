package io.typefox.yang.ide.symbols

import com.google.common.collect.Lists
import io.typefox.yang.utils.YangNameUtils
import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.Revision
import io.typefox.yang.yang.SchemaNode
import io.typefox.yang.yang.Unknown
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ide.server.symbol.DocumentSymbolMapper.DocumentSymbolNameProvider
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

class YangDocumentSymbolNameProvider extends DocumentSymbolNameProvider {

	override getName(EObject object) {
		if (object instanceof SchemaNode) {
			return object.name ?: object.yangName;
		} else if (object instanceof Augment) {
			return NodeModelUtils.findActualNodeFor(object.path).text.trim ?: object.yangName;
		} else if (object instanceof Revision) {
			return object.revision;
		} else if (object instanceof Unknown) {
			val name = super.getName(object);
			// Insert the name of the `extension` before the name of the current statement and after the name of the prefix.
			// https://github.com/theia-ide/yang-lsp/issues/149#issuecomment-437855640
			if (!name.nullOrEmpty && name.contains('.')) {
				val segments = Lists.newArrayList(name.split('\\.'));
				if (segments.last == object.name) {
					val extensionName = getName(object.extension);
					if (!extensionName.nullOrEmpty) {
						segments.add(segments.length - 1, extensionName);
						return segments.join('.');
					}
				}

			}
		}
		return super.getName(object);
	}

	protected def String getYangName(Object clazz) {
		return YangNameUtils.getYangName(clazz);
	}

}
