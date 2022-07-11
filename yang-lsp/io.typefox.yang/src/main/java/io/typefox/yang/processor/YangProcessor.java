package io.typefox.yang.processor;

import static com.google.common.collect.Lists.newArrayList;

import java.util.List;

import org.eclipse.emf.common.util.EList;

import com.google.gson.GsonBuilder;

import io.typefox.yang.yang.AbstractModule;
import io.typefox.yang.yang.Deviate;
import io.typefox.yang.yang.Deviation;
import io.typefox.yang.yang.SchemaNode;

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
			}
		}));

		modules.forEach((module) -> processedDataTree.addModule(module));
		return processedDataTree;
	}
}
