package io.typefox.yang.scoping.xpath

import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.resource.IEObjectDescription

class Types {
	public static val ANY = new XpathType() {}
	
	public static val BOOLEAN = new PrimitiveType("boolean")
	public static val STRING = new PrimitiveType("string")
	public static val NUMBER= new PrimitiveType("number")
	
	def static NodeSetType nodeSet(IEObjectDescription nodes) {
		if (nodes === null) {
			return nodeSet(#[])
		} else {			
			return nodeSet(#[nodes])
		}
	}
	def static NodeSetType nodeSet(List<IEObjectDescription> nodes) {
		new NodeSetType(nodes)
	}
	
	def static union(XpathType type, XpathType type2) {
		val nodes = newArrayList
		if (type instanceof NodeSetType) {
			nodes.addAll(type.nodes)
		}
		if (type2 instanceof NodeSetType) {
			nodes.addAll(type2.nodes)
		}
		return nodeSet(nodes)
	}
	 
}

interface XpathType {}


@Data class NodeSetType implements XpathType {
	List<IEObjectDescription> nodes
}

@Data class PrimitiveType implements XpathType {
	String name
}

