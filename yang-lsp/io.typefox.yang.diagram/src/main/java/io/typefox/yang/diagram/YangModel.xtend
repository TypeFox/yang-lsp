package io.typefox.yang.diagram

import io.typefox.sprotty.api.SCompartment
import io.typefox.sprotty.api.SLabel
import io.typefox.sprotty.api.SNode
import io.typefox.sprotty.server.xtext.tracing.TextRegion
import io.typefox.sprotty.server.xtext.tracing.Traceable
import io.typefox.yang.yang.Statement
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class YangNodeClassified extends SNode implements Traceable {
	String cssClass
	TextRegion traceRegion
	TextRegion significantRegion
}

@Accessors
class YangNode extends YangNodeClassified {
	transient Statement source
	Boolean expanded
}

@Accessors
class YangHeaderNode extends SCompartment {
	String cssClass
}

@Accessors
class YangLabel extends SLabel implements Traceable {
	TextRegion traceRegion
	TextRegion significantRegion
}

