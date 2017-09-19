package io.typefox.yang.diagram

import io.typefox.sprotty.api.SCompartment
import io.typefox.sprotty.api.SLabel
import io.typefox.sprotty.api.SNode
import io.typefox.sprotty.server.xtext.tracing.Traceable
import org.eclipse.xtend.lib.annotations.Accessors
import io.typefox.sprotty.api.SShapeElement
import io.typefox.sprotty.api.Layouting

@Accessors
class YangNodeClassified extends SNode implements Traceable {
	String cssClass
	String trace
}

@Accessors
class YangNode extends YangNodeClassified {
	Boolean expanded
}

@Accessors
class YangHeaderNode extends SCompartment {
	String cssClass
}

@Accessors
class YangLabel extends SLabel implements Traceable {
	String trace
}

@Accessors 
class YangTag extends SShapeElement implements Layouting {
	String layout
	
	new() {}
	new((YangTag)=>void initializer) {
		initializer.apply(this)
	}
}