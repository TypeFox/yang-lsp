package io.typefox.yang.processor;

import java.util.List;

import com.google.common.collect.Lists;
import com.google.gson.GsonBuilder;

import io.typefox.yang.yang.AbstractModule;

public class YangProcessor {

	public static void main(String[] args) {
		var processedData = new YangProcessor().process(Lists.newArrayList(), Lists.newArrayList(),
				Lists.newArrayList());
		new GsonBuilder().create().toJson(processedData, System.out);
	}

	public ProcessedDataTree process(List<AbstractModule> modules, List<String> includedFeatures,
			List<String> excludedFeatures) {
		return new ProcessedDataTree();
	}
}
