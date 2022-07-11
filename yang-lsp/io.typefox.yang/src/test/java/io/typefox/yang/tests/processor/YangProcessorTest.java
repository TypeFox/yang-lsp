package io.typefox.yang.tests.processor;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.junit.Test;

import com.google.common.collect.Maps;
import com.google.gson.GsonBuilder;

import io.typefox.yang.processor.ProcessedDataTree;
import io.typefox.yang.processor.YangProcessor;
import io.typefox.yang.tests.AbstractYangTest;
import io.typefox.yang.yang.AbstractModule;

public class YangProcessorTest extends AbstractYangTest {

	@Test
	public void processModulesTest() throws IOException {

		var resourceMap = Maps.<String, Resource>newHashMap();
		List<String> files = newArrayList();
		try (InputStream in = this.getClass().getClassLoader().getResourceAsStream("processor");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			String resource;
			while ((resource = br.readLine()) != null) {
				if (resource.endsWith(".yang"))
					files.add(resource);
			}
		}

		files.stream().forEach(it -> resourceMap.put(it,
				resourceSet.getResource(URI.createFileURI("src/test/resources/processor/" + it), true)));
		var resource = resourceMap.get("ietf-system.yang");
		EcoreUtil.resolveAll(resource);
		assertNoErrors(resource);

		List<AbstractModule> modules = newArrayList();
		resourceSet.getResources().forEach((res) -> {
			if (!res.getContents().isEmpty() && res.getContents().get(0) instanceof AbstractModule) {
				modules.add((AbstractModule) res.getContents().get(0));
			}
		});

		ProcessedDataTree dataTree = new YangProcessor().process(modules, null, null);
		String expectation = null;

		try (InputStream in = this.getClass().getClassLoader()
				.getResourceAsStream("io/typefox/yang/tests/processor/expectation.json");
				BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
			var writer = new StringWriter();
			br.transferTo(writer);
			expectation = writer.getBuffer().toString();
		}
		var sysModule = dataTree.getModules().stream().filter(mod -> "ietf-system".equals(mod.getName())).findFirst();
		assertEquals(expectation, new GsonBuilder().setPrettyPrinting().create().toJson(sysModule));
	}
}
