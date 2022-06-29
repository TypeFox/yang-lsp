package io.typefox.yang.tests.editor.syntaxcoloring

import com.google.inject.Inject
import io.typefox.yang.ide.editor.syntaxcoloring.TokenType
import io.typefox.yang.tests.AbstractYangLSPTest
import java.util.List
import java.util.UUID
import org.eclipse.lsp4j.ClientCapabilities
import org.eclipse.lsp4j.SemanticTokensCapabilities
import org.eclipse.lsp4j.SemanticTokensClientCapabilitiesRequests
import org.eclipse.lsp4j.SemanticTokensParams
import org.eclipse.lsp4j.TextDocumentClientCapabilities
import org.eclipse.lsp4j.TextDocumentIdentifier
import org.eclipse.xtext.ide.server.LanguageServerImpl
import org.eclipse.xtext.ide.server.UriExtensions
import org.eclipse.xtext.util.Modules2
import org.junit.Before
import org.junit.Test

import static org.junit.Assert.*

class YangSemanticHighlightingCalculatorTest extends AbstractYangLSPTest {

	@Inject
	extension UriExtensions;

	@Before
	def void before() {
		initialize[
			capabilities = new ClientCapabilities() => [
				textDocument = new TextDocumentClientCapabilities() => [
					semanticTokens = new SemanticTokensCapabilities(false) => [
						tokenTypes = TokenType.values.map[it.toString]
						requests = new SemanticTokensClientCapabilitiesRequests() => [
							full = true
							range = true
						]
						overlappingTokenSupport = false;
					];
				];
			];
		]
	}

	override protected getServerModule() {
		val module = super.getServerModule()

		return Modules2.mixin(module) [
			bind(LanguageServerImpl).to(YangTestLanguageServerImpl)
		]
	}

	@Test
	def void checkDescription_singleLine() {
		'''
		module x {
		  namespace "foo";
		  prefix "bar";
		  
		  description "desc";
		}'''.assertInfos('''
			(line: 4, col: 14, length: 6) [type: yang-description-statement->namespace, modifier: 0]
		''');
	}

	@Test
	def void checkDescription_multiLine() {

		'''
		module x {
		  namespace "foo";
		  prefix "bar";
		  
		  description 
		   "
		     blabla
		  
		      ";
		}'''.assertInfos('''
			(line: 5, col: 3, length: 24) [type: yang-description-statement->namespace, modifier: 0]
		''');

	}

	protected def String open(CharSequence content) {
		return open(content, UUID.randomUUID.toString);
	}

	protected def String open(CharSequence content, String fileName) {
		val file = root.toPath.resolve('''«fileName».«fileExtension»''').toFile;
		val uri = file.toURI.toUriString;
		uri.open(content.toString);
		return uri;
	}

	protected def void assertInfos(CharSequence content, String expected) {
		val uri = open(content, 'MyModel');
		val params = semanticTokens(uri);
		assertEquals(1, params.size);
		val actual = params.join('\n');
		assertEquals(expected, actual);
	}

	private def List<String> semanticTokens(String uri) {
		val tokens = languageServer.semanticTokensFull(new SemanticTokensParams(new TextDocumentIdentifier(uri))).get.
			data
		if (tokens.empty) {
			return emptyList
		}
		val regions = newArrayList
		for (var int i = 0; i < tokens.size; i = i + 5) {
			// TODO for multiple regions decode line/offset information
			var line = tokens.get(i)
			var col = tokens.get(i + 1)
			var length = tokens.get(i + 2)
			val tType = TokenType.values.get(tokens.get(i + 3))
			var type = tType.yangStyle + "->" + tType.toString
			var mod = tokens.get(i + 4)
			regions.add('''
				(line: «line», col: «col», length: «length») [type: «type», modifier: «mod»]
			''')
		}
		return regions;
	}

}
