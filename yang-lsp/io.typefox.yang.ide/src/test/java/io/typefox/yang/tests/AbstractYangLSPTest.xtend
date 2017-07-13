package io.typefox.yang.tests

import org.eclipse.xtext.testing.AbstractLanguageServerTest

abstract class AbstractYangLSPTest extends AbstractLanguageServerTest {
	
	new() {
		super('yang')
	}
	
}