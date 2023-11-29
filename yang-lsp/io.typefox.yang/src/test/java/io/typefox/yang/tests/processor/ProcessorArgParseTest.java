package io.typefox.yang.tests.processor;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThrows;

import org.junit.Test;

import com.beust.jcommander.ParameterException;

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
				+ "      Deviation module file\n"
				+ "    -X, --exclude-features\n"
				+ "      Excluded features\n"
				+ "      Default: []\n"
				+ "    -F, --features\n"
				+ "      Included features\n"
				+ "      Default: []\n"
				+ "    -f, --format\n"
				+ "      Output format: tree, json\n"
				+ "    --help\n"
				+ "\n", out.toString());
	}

	@Test
	public void processOnlyRequieredArgs() {
		var parsed = parseArgs("ietf-system.yang");
		assertEquals("ietf-system.yang", parsed.module);
	}

	@Test
	public void processMainArgs() {
		var parsed = parseArgs("-f", "tree", "ietf-system.yang", "--deviation-module", "example-system-ext.yang");
		assertEquals("tree", parsed.format);
		assertEquals("ietf-system.yang", parsed.module);
		assertEquals("example-system-ext.yang", parsed.deviationModule);
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
