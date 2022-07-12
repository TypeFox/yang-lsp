package io.typefox.yang.processor;

import static com.google.common.collect.Lists.newArrayList;

import java.util.List;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.util.EcoreUtil;

import com.google.gson.GsonBuilder;

import io.typefox.yang.processor.ProcessedDataTree.ForeignModuleAdapter;
import io.typefox.yang.yang.AbstractModule;
import io.typefox.yang.yang.Augment;
import io.typefox.yang.yang.Deviate;
import io.typefox.yang.yang.Deviation;
import io.typefox.yang.yang.Prefix;
import io.typefox.yang.yang.SchemaNode;
import io.typefox.yang.yang.Statement;

public class YangProcessor {

	public static void main(String[] args) {
		var processedData = new YangProcessor().process(newArrayList(), newArrayList(), newArrayList());
		new GsonBuilder().create().toJson(processedData, System.out);
	}

	/**
	 * 
	 * @param modules
	 * @param includedFeatures
	 * @param excludedFeatures
	 * @return ProcessedDataTree or <code>null</code> if modules is
	 *         <code>null</code> or empty.
	 */
	public ProcessedDataTree process(List<AbstractModule> modules, List<String> includedFeatures,
			List<String> excludedFeatures) {
		if (modules == null || modules.isEmpty()) {
			return null;
		}
		return processInternal(modules, includedFeatures == null ? newArrayList() : includedFeatures,
				excludedFeatures == null ? newArrayList() : excludedFeatures);
	}

	protected ProcessedDataTree processInternal(List<AbstractModule> modules, List<String> includedFeatures,
			List<String> excludedFeatures) {
		ProcessedDataTree processedDataTree = new ProcessedDataTree();
		modules.forEach((module) -> module.eAllContents().forEachRemaining((ele) -> {
			if (ele instanceof Deviate) {
				/*
				 * var deviation = ((Deviation) ele); deviation.getSubstatements().forEach((sub)
				 * -> { });
				 */
				Deviate deviate = (Deviate) ele;
				switch (deviate.getArgument()) {
				case "add":
				case "replace":
					break;
				case "delete":
				case "not-supported":
					var deviation = ((Deviation) ele.eContainer());
					SchemaNode schemaNode = deviation.getReference().getSchemaNode();
					Object eGet = schemaNode.eContainer().eGet(schemaNode.eContainingFeature(), true);
					if (eGet instanceof EList) {
						((EList<?>) eGet).remove(schemaNode);
					}
					break;
				}
			} else if (ele instanceof Augment) {
				var augment = (Augment) ele;
				augment.getSubstatements().forEach((subStatement) -> {
					Statement copy = EcoreUtil.copy(subStatement);
					Prefix prefix = (Prefix) module.getSubstatements().stream().filter(s -> (s instanceof Prefix))
							.findFirst().get();
					if (prefix != null)
						copy.eAdapters().add(new ForeignModuleAdapter(prefix.getPrefix()));
					augment.getPath().getSchemaNode().getSubstatements().add(copy);
				});
			}
		}));

		modules.forEach((module) -> processedDataTree.addModule(module));
		return processedDataTree;
	}
}
