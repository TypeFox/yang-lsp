package io.typefox.yang.processor;

import org.eclipse.xtext.EcoreUtil2;

import io.typefox.yang.utils.YangExtensions;
import io.typefox.yang.yang.AbstractModule;
import io.typefox.yang.yang.OtherStatement;
import io.typefox.yang.yang.SchemaNode;
import io.typefox.yang.yang.Submodule;

public class ProcessorUtility {
	
	public static String getPrefix(OtherStatement statment) {
		return new YangExtensions().getPrefix(statment);
	}

	public static String getPrefix(Submodule statment) {
		return new YangExtensions().getPrefix(statment);
	}

	public static String getPrefix(SchemaNode node) {
		var module = EcoreUtil2.getContainerOfType(node, AbstractModule.class);
		return getPrefix(module);
	}
}
