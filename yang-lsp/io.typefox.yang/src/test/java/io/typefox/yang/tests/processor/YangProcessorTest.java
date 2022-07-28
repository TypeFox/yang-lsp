package io.typefox.yang.tests.processor;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.util.List;
import java.util.Optional;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.junit.Test;

import com.google.common.collect.Maps;
import com.google.gson.GsonBuilder;

import io.typefox.yang.processor.DataTreeSerializer;
import io.typefox.yang.processor.ProcessedDataTree;
import io.typefox.yang.processor.ProcessedDataTree.ModuleData;
import io.typefox.yang.processor.YangProcessor;
import io.typefox.yang.tests.AbstractYangTest;
import io.typefox.yang.yang.AbstractModule;

public class YangProcessorTest extends AbstractYangTest {

	@Test
	public void processModules_NoDeviation_TreeTest() throws IOException {

		var sysModule = processData(false);

		String expectation = null;

		/// CLI tree test
		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("io/typefox/yang/tests/processor/expectation-nodev.txt");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		assertEqualsReduceSpace(expectation, new DataTreeSerializer().serialize(sysModule.get()).toString());

	}

	@Test
	public void processModules_TreeTest() throws IOException {

		var sysModule = processData(true);

		String expectation = null;

		/// CLI tree test
		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("io/typefox/yang/tests/processor/expectation.txt");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		assertEqualsReduceSpace(expectation, new DataTreeSerializer().serialize(sysModule.get()).toString());

	}

	@Test
	public void processModules_TreeTest_FeatureInclude() throws IOException {

		var sysModule = processData(true, newArrayList("example-system-ext:", "sys:"), null);

		String expectation = null;

		// CLI tree test expect output like:
		// pyang -f tree ietf-system.yang --deviation-module example-system-ext.yang -F
		// example-system-ext:
		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("io/typefox/yang/tests/processor/expectation-feature-only-example.txt");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		assertEqualsReduceSpace(expectation, new DataTreeSerializer().serialize(sysModule.get()).toString());

	}

	@Test
	public void processModules_TreeTest_FeatureExclude() throws IOException {

		var sysModule = processData(true, null, newArrayList("ietf-tls-client:x509-certificate-auth"));

		String expectation = null;

		// CLI tree test expect output like:
		// pyang -f tree ietf-system.yang --deviation-module example-system-ext.yang -X
		// example-system-ext:ldap-posix-filter
		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("io/typefox/yang/tests/processor/expectation-feature-exclude-f.txt");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		assertEqualsReduceSpace(expectation, new DataTreeSerializer().serialize(sysModule.get()).toString());

	}

	@Test
	public void processModules_NoDeviation_JsonTest() throws IOException {

		var sysModule = processData(false);

		String expectation = null;

		// Json output test
		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("io/typefox/yang/tests/processor/expectation-nodev.json");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		assertEquals(expectation, new GsonBuilder().setPrettyPrinting().create().toJson(sysModule.get()));

	}

	@Test
	public void processModules_JsonTest() throws IOException {

		var sysModule = processData(true);

		String expectation = null;

		// Json output test
		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("io/typefox/yang/tests/processor/expectation.json");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		assertEquals(expectation, new GsonBuilder().setPrettyPrinting().create().toJson(sysModule.get()));

	}

	private Optional<ModuleData> processData(boolean withDeviation) throws IOException {
		return processData(withDeviation, null, null);
	}

	private Optional<ModuleData> processData(boolean withDeviation, List<String> includedFeatures,
			List<String> excludedFeatures) throws IOException {
		var resourceMap = Maps.<String, Resource>newHashMap();
		List<String> files = newArrayList();
		try (InputStream in = this.getClass().getClassLoader().getResourceAsStream("processor");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			String resource;
			while ((resource = br.readLine()) != null) {
				if (resource.endsWith(".yang") && (withDeviation || !resource.equals("example-system-ext.yang")))
					files.add(resource);
			}
		}

		files.stream().forEach(it -> resourceMap.put(it,
				resourceSet.createResource(URI.createFileURI("src/test/resources/processor/" + it))));
		var resource = resourceMap.get("ietf-system.yang");
		resource.load(resourceSet.getLoadOptions());
		EcoreUtil.resolveAll(resource);
		assertNoErrors(resource);

		List<AbstractModule> modules = newArrayList();
		resourceSet.getResources().forEach((res) -> {
			if (!res.getContents().isEmpty() && res.getContents().get(0) instanceof AbstractModule) {
				modules.add((AbstractModule) res.getContents().get(0));
			}
		});

		ProcessedDataTree dataTree = new YangProcessor().process(modules, includedFeatures, excludedFeatures);
		var sysModule = dataTree.getModules().stream().filter(mod -> "ietf-system".equals(mod.getSimpleName())).findFirst();
		return sysModule;

	}

	private void assertEqualsReduceSpace(String expectation, String actual) {
		if(expectation != null) {
			expectation = expectation.replaceAll(" {4,}", "   ");
		}
		if(actual != null) {
			actual = actual.replaceAll(" {4,}", "   ");
		}
		assertEquals(expectation, actual);
	}

}
