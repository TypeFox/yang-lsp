package io.typefox.yang.diagram

import io.typefox.sprotty.api.SNode
import io.typefox.yang.yang.Statement
import org.eclipse.xtend.lib.annotations.Accessors
import io.typefox.sprotty.api.SCompartment
import org.eclipse.xtend.lib.annotations.Data
import io.typefox.sprotty.api.SLabel

@Accessors
class YangNodeClassified extends SNode implements Traceable {
	String cssClass
	TextRegion traceRegion
	TextRegion significantRegion
}

@Accessors
class YangNode extends YangNodeClassified {
	transient Statement source
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

interface Traceable {
	def TextRegion getTraceRegion()
	def void setTraceRegion(TextRegion traceRegion)
	def TextRegion getSignificantRegion()
	def void setSignificantRegion(TextRegion traceRegion)
}

@Data
class TextRegion {
	int offset
	int length
}