package io.typefox.yang.tests.codeActions

import io.typefox.yang.tests.AbstractYangLSPTest
import org.junit.Test
import org.eclipse.xtext.ide.server.Document
import org.eclipse.lsp4j.WorkspaceEdit
import org.junit.Assert

class CodeActionTest extends AbstractYangLSPTest {
	
	@Test def void testFixVersion() {
		val doc = new Document(1, '''
			module foo {
				yang-version 2;
			}
		''')
		testCodeAction [
			model = doc.contents
			assertCodeActions = [
				val we = head.getLeft.arguments.head as WorkspaceEdit
				Assert.assertEquals('''
					module foo {
						yang-version 1.1;
					}
				'''.toString, doc.applyChanges(we.changes.values.head).contents)
			]
		]
	}
	
	@Test def void testFixVersion_01() {
		val doc = new Document(1, '''
			module foo {
				yang-version "2";
			}
		''')
		testCodeAction [
			model = doc.contents
			assertCodeActions = [
				val we = head.getLeft.arguments.head as WorkspaceEdit
				Assert.assertEquals('''
					module foo {
						yang-version 1.1;
					}
				'''.toString, doc.applyChanges(we.changes.values.head).contents)
			]
		]
	}
}