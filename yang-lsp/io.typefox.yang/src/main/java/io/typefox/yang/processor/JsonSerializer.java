package io.typefox.yang.processor;

import com.google.gson.GsonBuilder;

import io.typefox.yang.processor.ProcessedDataModel.ModuleData;

public class JsonSerializer {

	public CharSequence serialize(ModuleData moduleData) {
		var writer = new StringBuilder();
		serialize(moduleData, writer);
		return writer.toString();
	}

	public void serialize(ModuleData moduleData, Appendable writer) {
		new GsonBuilder().setPrettyPrinting().create().toJson(moduleData, writer);
	}
}
