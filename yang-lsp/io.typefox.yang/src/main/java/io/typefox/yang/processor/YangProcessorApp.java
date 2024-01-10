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

		@Parameter(names = "--help", help = true, description = "Print a short help text.")
		private boolean help;

		@Parameter(description = "<file...>", required = true)
		public List<String> modules = newArrayList();

		@Parameter(names = { "-d",
				"--deviation-module" }, description = "DISABLED! Use to apply the deviations defined in this file.")
		public String deviationModule;

		@Parameter(names = { "-f", "--format" }, description = "Output format.")
		public Format format;

		@Parameter(names = { "-p",
				"--path" }, description = "A colon (:) separated list of directories to search for imported modules. Default is the current directory.")
		public String path;

		@Parameter(names = {
				"--no-path-recurse" }, description = "If this parameter is given, directories in the search path are not recursively scanned for modules.")
		public boolean noPathRecurse = false;

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
			modules = loadModuleFileAndDependencies(cliArgs.modules, cliArgs.noPathRecurse, pathes);
		} catch (IOException e) {
			String msg = e.getMessage();
			if (msg == null) {
				msg = "An exception occured when loading module files: " + String.join(", ", cliArgs.modules);
			}
			System.err.println(msg);
			System.exit(11);
		}
		var processedData = yangProcessor.process(modules, cliArgs.includedFeatures, cliArgs.excludedFeatures);

		if (processedData == null || processedData.getModules() == null) {
			String msg = "No modules found in files: " + String.join(", ", cliArgs.modules);
			System.err.println(msg);
			System.exit(23);
		}

		var output = new StringBuilder();
		processedData.getLoadingErrors()
				.forEachRemaining(msg -> output.append(msg.toString()).append(System.lineSeparator()));
		if (cliArgs.format != null) {
			for (var module : processedData.getModules()) {
				if (cliArgs.modules.stream().anyMatch(file -> module.getUri().endsWith(file.trim()))) {
					yangProcessor.serialize(module, cliArgs.format, output);
				}
			}
		} else {
			processedData.getProcessingErrors()
					.forEachRemaining(msg -> output.append(msg.toString()).append(System.lineSeparator()));
		}
		System.out.println(output.toString());
	}

	private static List<AbstractModule> loadModuleFileAndDependencies(List<String> moduleFilePath,
			Boolean noPathRecurse, String... paths) throws IOException {
		var injector = new YangStandaloneSetup().createInjectorAndDoEMFRegistration();

		var moduleResources = new ArrayList<Resource>(moduleFilePath.size());
		var rs = injector.getInstance(XtextResourceSet.class);

		for (String path : moduleFilePath) {
			var moduleFile = new File(path);
			if (!moduleFile.exists()) {
				throw new IOException(
						"File " + path + " doesn't exists.");
			} else if (!moduleFile.isFile()) {
				throw new IOException("File " + path + " is not a file.");

			} else {
				// add main modules as first resources
				moduleResources.add(rs.createResource(URI.createFileURI(moduleFile.getAbsolutePath())));
			}
		}

		// add files from the current directory
		var implicitLookup = new File("").getAbsoluteFile();
		var extensionProvider = injector.getInstance(FileExtensionProvider.class);
		var fileExts = Collections.singleton("yang");
		if (extensionProvider != null && extensionProvider.getFileExtensions() != null) {
			if (!extensionProvider.getFileExtensions().isEmpty())
				fileExts = extensionProvider.getFileExtensions();
		}
		loadAdditionalFiles(implicitLookup, rs, fileExts, false);

		// handle --path argument
		if (paths != null) {
			for (String path : paths) {
				var folder = new File(path);
				if (!folder.exists()) {
					System.err.println("Path " + folder.getAbsolutePath() + " doesn't exist. Skipped.");
				} else if (!folder.isDirectory()) {
					System.err.println("Path " + folder.getAbsolutePath() + " is not a directory. Skipped.");
				}
				loadAdditionalFiles(folder.getAbsoluteFile(), rs, fileExts, !noPathRecurse);
			}
		}

		// load models
		for (Resource res : moduleResources) {
			res.load(rs.getLoadOptions());
		}

		// Collect all contained modules
		var modules = new ArrayList<AbstractModule>();
		for (Resource res : rs.getResources()) {
			// Resolve all proxies. Otherwise resolving might fail when copying EObjects
			EcoreUtil.resolveAll(res);
			var rootObj = res.getContents().get(0);
			if (rootObj instanceof AbstractModule) {
				modules.add((AbstractModule) rootObj);
			}
		}
		return modules;
	}

	private static void loadAdditionalFiles(File parent, XtextResourceSet rs, Set<String> fileExtensions,
			final boolean recursive) {
		for (File file : parent.listFiles()) {
			URI fileURI = URI.createFileURI(file.getAbsolutePath());
			if (file.isFile() && fileExtensions.contains(fileURI.fileExtension())) {
				if (rs.getResource(fileURI, false) == null) {
					rs.getResource(fileURI, true);
				}
			}
			if (recursive && file.isDirectory()) {
				loadAdditionalFiles(file, rs, fileExtensions, recursive);
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
