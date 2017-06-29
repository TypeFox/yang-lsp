package io.typefox.yang.tests.integration

import org.eclipse.xtext.testing.AbstractLanguageServerTest
import org.junit.Test
import java.io.File

class GoodTests extends AbstractLanguageServerTest {
	
	new() {
		super('yang')
	}
	
	@Test def void runGoodTests() {
		initialize[
			rootUri = new File("./test-data/good").absoluteFile.toURI.toString
		]
		assertEquals("", diagnostics.values.join("\n")[join("\n")])
	}
	
}