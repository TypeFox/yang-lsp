package io.typefox.yang.tests.processor;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertThrows;

import org.junit.Test;

import com.beust.jcommander.ParameterException;

import io.typefox.yang.processor.YangProcessor.Format;
import io.typefox.yang.processor.YangProcessorApp;
import io.typefox.yang.processor.YangProcessorApp.Args;
import io.typefox.yang.tests.AbstractYangTest;

public class ProcessorArgParseTest extends AbstractYangTest {

	private Args parseArgs(String... args) {
		return YangProcessorApp.parseArgs(new StringBuilder(), args);
	}

	@Test
	public void missingRequieredArgs() {
		assertThrows("Main parameters are required (\"Module file\")", ParameterException.class, () -> parseArgs());
	}

	@Test
	public void processHelpArg() {
		var out = new StringBuilder();
		YangProcessorApp.parseArgs(out, "--help");
		assertEquals("Usage: yang-tool [options] <filename>\n"
				+ "  Options:\n"
				+ "    -d, --deviation-module\n"
				+ "      DISABLED! Use to apply the deviations defined in this file.\n"
				+ "    -X, --exclude-features\n"
				+ "      Excluded features.\n"
				+ "      Default: []\n"
				+ "    -F, --features\n"
				+ "      Included features.\n"
				+ "      Default: []\n"
				+ "    -f, --format\n"
				+ "      Output format.\n"
				+ "      Possible Values: [tree, json]\n"
				+ "    --help\n"
				+ "      Print a short help text.\n"
				+ "    --no-path-recurse\n"
				+ "      If this parameter is given, directories in the search path are not \n"
				+ "      recursively scanned for modules.\n"
				+ "      Default: false\n"
				+ "    -p, --path\n"
				+ "      A colon (:) separated list of directories to search for imported \n"
				+ "      modules. Default is the current directory.\n"
				+ "", out.toString());
	}

	@Test
	public void processOnlyRequieredArgs() {
		var parsed = parseArgs("ietf-system.yang");
		assertEquals("ietf-system.yang", parsed.module);
		assertNull(parsed.format);
	}

	@Test
	public void processMainArgs() {
		var parsed = parseArgs("-f", "tree", "ietf-system.yang", "--deviation-module", "example-system-ext.yang");
		assertEquals(Format.tree, parsed.format);
		assertEquals("ietf-system.yang", parsed.module);
		assertEquals("example-system-ext.yang", parsed.deviationModule);
	}

	@Test
	public void usedUnsupportedFormat() {
		assertThrows("Invalid value for -f parameter. Allowed values:[tree, json]", ParameterException.class,
				() -> parseArgs("-f", "not-Supported-format", "ietf-system.yang"));
	}

	@Test
	public void processExcludedFeature() {
		var parsed = parseArgs("-f", "tree", "ietf-system.yang", "--deviation-module", "example-system-ext.yang", "-X",
				"example-system-ext:ldap-posix-filter");
		assertEquals(1, parsed.excludedFeatures.size());
		assertEquals("example-system-ext:ldap-posix-filter", parsed.excludedFeatures.get(0));
	}

	@Test
	public void processIncludedFeature() {
		var parsed = parseArgs("-f", "tree", "ietf-system.yang", "--deviation-module", "example-system-ext.yang", "-F",
				"example-system-ext:ldap-posix-filter");
		assertEquals(1, parsed.includedFeatures.size());
		assertEquals("example-system-ext:ldap-posix-filter", parsed.includedFeatures.get(0));
	}

}
