package io.typefox.yang.scoping.xpath

import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.resource.IEObjectDescription
import com.google.common.base.Supplier

class Types {
	public static val ANY = new XpathType() {}
	
	public static val BOOLEAN = new PrimitiveType("boolean")
	public static val STRING = new PrimitiveType("string")
	public static val NUMBER= new PrimitiveType("number")
	
	def static NodeSetType nodeSet(IEObjectDescription node) {
		if (node === null) {
			return nodeSet(#[])
		} else {
			return nodeSet(#[node])
		}
	}
	
	def static NodeSetType nodeSet(List<IEObjectDescription> nodes) {
		new NodeSetType(null, [|nodes])
	}
	
	def static NodeSetType nodeSet(IEObjectDescription firstNode, Supplier<List<IEObjectDescription>> nodesSuplier) {
		new NodeSetType(firstNode, nodesSuplier)
	}
	
	def static union(XpathType type, XpathType type2) {
		val nodes = newArrayList
		if (type instanceof NodeSetType) {
			nodes.addAll(type.allNodes)
		}
		if (type2 instanceof NodeSetType) {
			nodes.addAll(type2.allNodes)
		}
		return nodeSet(nodes)
	}
	 
}

interface XpathType {}


class NodeSetType implements XpathType {
	Supplier<List<IEObjectDescription>> nodes

	IEObjectDescription first

	new(IEObjectDescription first, Supplier<List<IEObjectDescription>> supplier) {
		this.first = first
		this.nodes = supplier
	}

	def getSingleNode() {
		return if (first !== null) {
			first
		} else
			allNodes.head
	}

	def getAllNodes() {
		return nodes.get
	}

	def isEmpty() {
		return if(first !== null) false else allNodes.empty
	}
}

@Data class PrimitiveType implements XpathType {
	String name
}

