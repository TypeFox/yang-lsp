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
import io.typefox.yang.processor.ProcessedDataModel;
import io.typefox.yang.processor.ProcessedDataModel.ModuleData;
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
				.getResourceAsStream("processor/expectation/expectation-nodev.txt");
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
				.getResourceAsStream("processor/expectation/expectation.txt");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		assertEqualsReduceSpace(expectation, new DataTreeSerializer().serialize(sysModule.get()).toString());

	}

	/*
	 Should return the same result as processModules_TreeTest()
	 */
	@Test
	public void processModules_TreeTest_FeatureIncludeAllListed() throws IOException {
		
		var sysModule = processData(true, newArrayList(
				"example-system-ext:ldap",
				"example-system-ext:ldap-authentication",
				"example-system-ext:ldap-clear",
				"example-system-ext:ldap-posix-filter",
				"example-system-ext:ldap-custom-filter",
				"example-system-ext:ldap-sasl-external",
				"example-system-ext:local-target-classes",
				"example-system-ext:authentication-failure-alarm",
				"example-system-ext:ntp-security",
				"example-system-ext:oauth2-client-authentication"
				), null);
		
		String expectation = null;
		
		// CLI tree test expect output like:
		/*
		  pyang -f tree ietf-system.yang --deviation-module example-system-ext.yang \
			-F example-system-ext:ldap,ldap-authentication,ldap-clear,ldap-posix-filter,ldap-custom-filter,ldap-sasl-external,local-target-classes,authentication-failure-alarm,ntp-security,oauth2-client-authentication\
			 > pyang-enable-all-as-features.txt
		 */
		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("processor/expectation/expectation.txt");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		assertEqualsReduceSpace(expectation, new DataTreeSerializer().serialize(sysModule.get()).toString());
	}

	@Test
	public void processModules_TreeTest_FeatureIncludeEmptyModule() throws IOException {

		var sysModule = processData(true, newArrayList("example-system-ext:"), null);

		String expectation = null;

		// CLI tree test expect output like:
		// pyang -f tree ietf-system.yang --deviation-module example-system-ext.yang -F example-system-ext:
		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("processor/expectation/expectation-disable-all-features-for-module.txt");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		assertEqualsReduceSpace(expectation, new DataTreeSerializer().serialize(sysModule.get()).toString());

	}
	
	

	/*
	 * enables ietf-keystore:local-definitions-supported feature.
	 * Which effectively disables other ietf-keystore: features: 
	 * 	ietf-keystore:keystore-supported and ietf-keystore:key-generation
	 */
	@Test
	public void processModules_TreeTest_FeatureIncludeOne() throws IOException {

		var sysModule = processData(true, newArrayList("ietf-keystore:local-definitions-supported"), null,
				"ietf-keystore@2019-11-20.yang");

		String expectation = null;

		// CLI tree test expect output like:
		// pyang -f tree -p . ietf-keystore@2019-11-20.yang --deviation-module
		// example-system-ext.yang -F ietf-keystore:local-definitions-supported
		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("processor/expectation/expectation-one-feature-only-example.txt");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		assertEqualsReduceSpace(expectation, new DataTreeSerializer().serialize(sysModule.get()).toString());

	}

	@Test
	public void processModules_TreeTest_FeatureExclude() throws IOException {

		var sysModule = processData(true, null, newArrayList("example-system-ext:ldap-posix-filter"));

		String expectation = null;

		// CLI tree test expect output like:
		// pyang -f tree ietf-system.yang --deviation-module example-system-ext.yang -X
		// example-system-ext:ldap-posix-filter
		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("processor/expectation/expectation-feature-exclude-f.txt");
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
				.getResourceAsStream("processor/expectation/expectation-nodev.json");
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
				.getResourceAsStream("processor/expectation/expectation.json");
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
		return processData(withDeviation, includedFeatures, excludedFeatures, "ietf-system.yang");
	}

	private Optional<ModuleData> processData(boolean withDeviation, List<String> includedFeatures,
			List<String> excludedFeatures, String entryFile) throws IOException {

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
		var resource = resourceMap.get(entryFile);
		resource.load(resourceSet.getLoadOptions());
		EcoreUtil.resolveAll(resource);
		assertNoErrors(resource);

		List<AbstractModule> modules = newArrayList();
		resourceSet.getResources().forEach((res) -> {
			if (!res.getContents().isEmpty() && res.getContents().get(0) instanceof AbstractModule) {
				modules.add((AbstractModule) res.getContents().get(0));
			}
		});

		ProcessedDataModel dataTree = new YangProcessor().process(modules, includedFeatures, excludedFeatures);
		var sysModule = dataTree.getModules().stream().filter(mod -> mod.getUri().endsWith(entryFile)).findFirst();
		return sysModule;

	}

	private void assertEqualsReduceSpace(String expectation, String actual) {
		if (expectation != null) {
			expectation = expectation.replaceAll(" {4,}", "   ");
		}
		if (actual != null) {
			actual = actual.replaceAll(" {4,}", "   ");
		}
		assertEquals(expectation, actual);
	}

	/*
	public static void main(String[] args) {
		var features = "ericsson-keystore-ext:cmp,manual-renewal,pkcs10,pkcs12,pkcs8,scep ietf-keystore:key-generation,keystore-supported,local-definitions-supported ietf-truststore:local-definitions-supported ietf-truststore:raw-public-keys ietf-truststore:ssh-host-keys ietf-truststore:truststore-supported ietf-truststore:x509-certificates";
		var cmd = new StringBuilder("pyang -f tree -p . ietf-keystore.yang --deviation-module ericsson-keystore-ext.yang ");
		for (String string : features.split(" ")) {
			cmd.append(" --features=" + string);
		}
		System.out.println(cmd.toString());
	}*/
}
