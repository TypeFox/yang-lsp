package io.typefox.yang.diagram

import io.typefox.sprotty.api.SNode
import io.typefox.yang.yang.Statement
import org.eclipse.xtend.lib.annotations.Accessors
import io.typefox.sprotty.api.SModelElement
import org.eclipse.xtend.lib.annotations.ToString
import java.util.function.Consumer

@Accessors
@ToString(skipNulls = true)
class YangModuleModel extends SNode {
	SModelElement parent
	
	new() {}
	new(Consumer<SModelElement> initializer) {
		initializer.accept(this)
	}
}


@Accessors
class YangNode extends SNode {
	transient Statement source
}
