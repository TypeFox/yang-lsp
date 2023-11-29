package io.typefox.yang.processor;

import static com.google.common.collect.Lists.newArrayList;

import java.util.List;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.beust.jcommander.ParameterException;

public class YangProcessorApp {

	public static class Args {

		@Parameter(names = "--help", help = true)
		private boolean help;

		@Parameter(description = "<filename>", required = true)
		public String module;

		@Parameter(names = { "-d", "--deviation-module" }, description = "Deviation module file")
		public String deviationModule;

		@Parameter(names = { "-f", "--format" }, description = "Output format: tree, json")
		public String format;

		@Parameter(names = { "-F", "--features" }, description = "Included features")
		public List<String> includedFeatures = newArrayList();

		@Parameter(names = { "-X", "--exclude-features" }, description = "Excluded features")
		public List<String> excludedFeatures = newArrayList();

	}

	public static void main(String[] args) {
		Args cliArgs = null;
		StringBuilder out = new StringBuilder();
		try {
			cliArgs = parseArgs(out, args);
		} catch (ParameterException pe) {
			System.err.println(pe.getMessage());
			pe.usage();
			System.exit(29);
		}

		if (cliArgs.help) {
			System.out.println(out.toString());
			return;
		}

		var yangProcessor = new YangProcessor();
		var processedData = yangProcessor.process(null, cliArgs.includedFeatures, cliArgs.excludedFeatures);

		if (processedData == null || processedData.getModules() == null) {
			String msg = "No module found in file: " + (cliArgs.module == null ? "<empty>" : cliArgs.module);
			System.err.println(msg);
			System.exit(11);
		}

		var output = new StringBuilder();
		yangProcessor.serialize(processedData, cliArgs.format, output);
		System.out.println(output.toString());
	}

	public static Args parseArgs(StringBuilder out, String... args) {
		var cliArgs = new Args();
		JCommander commander = JCommander.newBuilder().programName("yang-tool").addObject(cliArgs).build();
		commander.parse(args);
		if (cliArgs.help && out != null) {
			commander.usage(out);
		}
		return cliArgs;
	}

}
