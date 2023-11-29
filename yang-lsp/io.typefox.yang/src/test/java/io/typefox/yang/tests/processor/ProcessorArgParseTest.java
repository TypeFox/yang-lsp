package io.typefox.yang.tests.processor;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import org.junit.Test;

import io.typefox.yang.processor.YangProcessor;
import io.typefox.yang.tests.AbstractYangTest;

public class ProcessorArgParseTest extends AbstractYangTest {

	@Test
	public void processMainArgs() throws IOException {
		var parsed = YangProcessor.parseArgs("-f", "tree", "ietf-system.yang", "--deviation-module",
				"example-system-ext.yang");
		assertEquals("tree", parsed.format);
		assertEquals("ietf-system.yang", parsed.module);
		assertEquals("example-system-ext.yang", parsed.deviationModule);
	}

	@Test
	public void processExcludedFeature() throws IOException {
		var parsed = YangProcessor.parseArgs("-f", "tree", "ietf-system.yang", "--deviation-module",
				"example-system-ext.yang", "-X", "example-system-ext:ldap-posix-filter");
		assertEquals(1, parsed.excludedFeatures.size());
		assertEquals("example-system-ext:ldap-posix-filter", parsed.excludedFeatures.get(0));
	}

	@Test
	public void processIncludedFeature() throws IOException {
		var parsed = YangProcessor.parseArgs("-f", "tree", "ietf-system.yang", "--deviation-module",
				"example-system-ext.yang", "-F", "example-system-ext:ldap-posix-filter");
		assertEquals(1, parsed.includedFeatures.size());
		assertEquals("example-system-ext:ldap-posix-filter", parsed.includedFeatures.get(0));
	}

}
