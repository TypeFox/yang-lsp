package io.typefox.yang.processor;

import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.xtext.EcoreUtil2;

import io.typefox.yang.processor.FeatureExpressions.FeatureCondition;
import io.typefox.yang.processor.YangProcessor.ForeignModuleAdapter;
import io.typefox.yang.utils.YangExtensions;
import io.typefox.yang.yang.AbstractModule;
import io.typefox.yang.yang.IfFeature;
import io.typefox.yang.yang.OtherStatement;
import io.typefox.yang.yang.Prefix;
import io.typefox.yang.yang.SchemaNode;
import io.typefox.yang.yang.Statement;
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

	public static ModuleIdentifier moduleIdentifier(Statement statement) {
		var module = EcoreUtil2.getContainerOfType(statement, AbstractModule.class);
		Prefix prefix = (Prefix) module.getSubstatements().stream().filter(s -> (s instanceof Prefix)).findFirst()
				.get();
		return new ModuleIdentifier(module.getName(), prefix != null ? prefix.getPrefix() : null);
	}

	public static List<IfFeature> findIfFeatures(Statement statement) {
		return statement.getSubstatements().stream().filter(sub -> sub instanceof IfFeature).map(IfFeature.class::cast)
				.collect(Collectors.toList());
	}

	public static boolean checkIfFeatures(List<IfFeature> ifFeatures, FeatureEvaluationContext evalCtx) {
		if (ifFeatures.isEmpty()) {
			return true;
		}
		return ifFeatures.stream().allMatch(feature -> {
			FeatureCondition condition = FeatureCondition.create(feature.getCondition());
			return condition.evaluate(evalCtx);
		});
	}

	public static String qualifiedName(SchemaNode node) {
		ForeignModuleAdapter foreignAdapter = ForeignModuleAdapter.find(node);
		if (foreignAdapter != null) {
			// FIXME here we expect the local import prefix, not the global one
			return foreignAdapter.moduleId.prefix + ":" + node.getName();
		}
		return node.getName();
	}

	public static class ModuleIdentifier {
		final public String name, prefix;

		public ModuleIdentifier(String name, String prefix) {
			super();
			this.name = name;
			this.prefix = prefix;
		}

		@Override
		public String toString() {
			return name + " (" + prefix + ")";
		}
	}
}
