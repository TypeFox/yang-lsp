package io.typefox.yang.diagram

import io.typefox.sprotty.api.SNode
import io.typefox.yang.yang.Statement
import org.eclipse.xtend.lib.annotations.Accessors
import io.typefox.sprotty.api.SCompartment

@Accessors
class YangNodeClassified extends SNode {
	String cssClass
}

@Accessors
class YangPopupNode extends YangNodeClassified {
	transient Statement source
}

@Accessors
class YangHeaderNode extends SCompartment {
	String tag
	String label
	String cssClass
}
