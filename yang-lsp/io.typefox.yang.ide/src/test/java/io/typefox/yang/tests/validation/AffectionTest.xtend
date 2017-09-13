package io.typefox.yang.tests.validation

import io.typefox.yang.tests.AbstractYangLSPTest
import org.junit.Test
import org.junit.Assert
import org.eclipse.lsp4j.DidChangeTextDocumentParams
import org.eclipse.lsp4j.VersionedTextDocumentIdentifier
import org.eclipse.lsp4j.TextDocumentContentChangeEvent

import static extension io.typefox.yang.utils.IterableExtensions2.nullToEmpty

class AffectionTest extends AbstractYangLSPTest {
	
	@Test def void testReferencedModuleRenamed_01() {
		initialize
		open('inmemory:/foo/foo.yang', '''
			module foo {
				
			}
		''')
		val uri = 'inmemory:/foo/bar.yang'
		open(uri, '''
			module bar {
				prefix b;
				namespace urn:b;
				import foo {
					prefix f;
				}
			}
		''')
		expectDiagnostics(uri, "")
		change('inmemory:/foo/foo.yang', '''
			module foo2 {
				
			}
		''')
		expectDiagnostics(uri, "Couldn't resolve reference to AbstractModule 'foo'.:3")
		change('inmemory:/foo/foo.yang', '''
			module foo {
				
			}
		''')
		expectDiagnostics(uri, "")
	}
	
	@Test def void testReferencedGroupingChanged() {
		initialize
		open('inmemory:/foo/foo.yang', '''
			module foo {
				grouping bar {
				}
			}
		''')
		val uri = 'inmemory:/foo/bar.yang'
		open(uri, '''
			module bar {
				prefix b;
				namespace urn:b;
				import foo {
					prefix f;
				}
				
				uses f:bar;
			}
		''')
		expectDiagnostics(uri, "")
		change('inmemory:/foo/foo.yang', '''
			module foo {
				grouping bar2 {
				}
			}
		''')
		expectDiagnostics(uri, "Couldn't resolve reference to Grouping 'f:bar'.:7")
		change('inmemory:/foo/foo.yang', '''
			module foo {
				grouping bar {
				}
			}
		''')
		expectDiagnostics(uri, "")
	}
	
	protected def expectDiagnostics(String uri, String expected) {
		val diagnostics = diagnostics;
		var issues = diagnostics.get(uri).nullToEmpty
		Assert.assertEquals(expected, issues.sortBy[range.start.line].sortBy[message].join(',\n')[message+":"+range.start.line])
	}
	
	protected def void change(String uri, String content) {
		this.languageServer.didChange(new DidChangeTextDocumentParams => [
			textDocument = new VersionedTextDocumentIdentifier => [
				it.uri = uri
			]
			contentChanges = #[new TextDocumentContentChangeEvent => [
				text = content
			]]
		])
	}
}