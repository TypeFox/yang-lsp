package io.typefox.yang.processor;

import static com.google.common.collect.Lists.newArrayList;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.xtext.resource.FileExtensionProvider;
import org.eclipse.xtext.resource.XtextResourceSet;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.beust.jcommander.ParameterException;

import io.typefox.yang.YangStandaloneSetup;
import io.typefox.yang.processor.YangProcessor.Format;
import io.typefox.yang.yang.AbstractModule;

public class YangProcessorApp {

	public static class Args {

		@Parameter(names = "--help", help = true)
		private boolean help;

		@Parameter(description = "<filename>", required = true)
		public String module;

		@Parameter(names = { "-d",
				"--deviation-module" }, description = "DISABLED! Use to apply the deviations defined in this file.")
		public String deviationModule;

		@Parameter(names = { "-f", "--format" }, description = "Output format.")
		public Format format = Format.tree;

		@Parameter(names = { "-p",
				"--path" }, description = "A colon (:) separated list of directories to search for imported modules. Default is the current directory.")
		public String path;

		@Parameter(names = { "-F", "--features" }, description = "Included features.")
		public List<String> includedFeatures = newArrayList();

		@Parameter(names = { "-X", "--exclude-features" }, description = "Excluded features.")
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

		List<AbstractModule> modules = null;
		try {
			var pathes = cliArgs.path != null ? cliArgs.path.split(":") : null;
			modules = loadModuleFileAndDependencies(cliArgs.module, pathes);
		} catch (IOException e) {
			String msg = e.getMessage();
			if (msg == null) {
				msg = "An exception occured when loading file: " + cliArgs.module;
			}
			System.err.println(msg);
			System.exit(11);
		}
		var processedData = yangProcessor.process(modules, cliArgs.includedFeatures, cliArgs.excludedFeatures);

		if (processedData == null || processedData.getModules() == null) {
			String msg = "No module found in file: " + (cliArgs.module == null ? "<empty>" : cliArgs.module);
			System.err.println(msg);
			System.exit(23);
		}

		var output = new StringBuilder();
		yangProcessor.serialize(processedData, cliArgs.format, output);
		System.out.println(output.toString());
	}

	private static List<AbstractModule> loadModuleFileAndDependencies(String moduleFilePath, String... paths)
			throws IOException {
		var injector = new YangStandaloneSetup().createInjectorAndDoEMFRegistration();
		var moduleFile = new File(moduleFilePath);
		if (!moduleFile.exists()) {
			throw new IOException(
					"File " + moduleFilePath + " doesn't exists in directory " + moduleFile.getAbsolutePath());
		}

		var rs = injector.getInstance(XtextResourceSet.class);
		// add main module as first resource
		var moduleResource = rs.createResource(URI.createFileURI(moduleFile.getAbsolutePath()));

		// add files from the current directory
		var implicitLookup = moduleFile.getAbsoluteFile().getParentFile();
		var extensionProvider = injector.getInstance(FileExtensionProvider.class);
		var fileExts = Collections.singleton("yang");
		if (extensionProvider != null && extensionProvider.getFileExtensions() != null) {
			if (!extensionProvider.getFileExtensions().isEmpty())
				fileExts = extensionProvider.getFileExtensions();
		}
		loadAdditionalFiles(implicitLookup, rs, fileExts);

		// handle --path argument
		if (paths != null) {
			for (String path : paths) {
				var folder = new File(path);
				if (!folder.isDirectory()) {
					System.err.println(folder.getAbsolutePath() + " is not a directory. Skipped.");
				} else {
					loadAdditionalFiles(folder.getAbsoluteFile(), rs, fileExts);
				}
			}
		}

		// load models
		moduleResource.load(rs.getLoadOptions());
		EcoreUtil.resolveAll(moduleResource);

		// Collect all contained modules
		var modules = new ArrayList<AbstractModule>();
		for (Resource res : rs.getResources()) {
			var rootObj = res.getContents().get(0);
			if (rootObj instanceof AbstractModule) {
				modules.add((AbstractModule) rootObj);
			}
		}
		return modules;
	}

	private static void loadAdditionalFiles(File parent, XtextResourceSet rs, Set<String> fileExtensions) {
		for (File file : parent.listFiles()) {
			URI fileURI = URI.createFileURI(file.getAbsolutePath());
			if (file.isFile() && fileExtensions.contains(fileURI.fileExtension())) {
				rs.getResource(fileURI, true);
			}
		}
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
