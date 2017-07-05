package io.typefox.yang.diagram;

import java.util.function.Consumer;

import io.typefox.sprotty.api.SNode;

public class SLayoutNode extends SNode {
	private String layout;

	public SLayoutNode() {
		
	}

	public SLayoutNode(Consumer<SNode> initializer) {
		initializer.accept(this);
	}

	public String getLayout() {
		return layout;
	}

	public void setLayout(String layout) {
		this.layout = layout;
	}
	
	
}
