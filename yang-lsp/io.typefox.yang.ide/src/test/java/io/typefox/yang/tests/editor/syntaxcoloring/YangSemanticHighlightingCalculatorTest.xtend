package io.typefox.yang.tests.editor.syntaxcoloring

import com.google.inject.Inject
import io.typefox.yang.tests.AbstractYangLSPTest
import java.util.UUID
import org.eclipse.lsp4j.ClientCapabilities
import org.eclipse.lsp4j.SemanticTokensCapabilities
import org.eclipse.lsp4j.TextDocumentClientCapabilities
import org.eclipse.xtext.ide.server.UriExtensions
import org.junit.Before
import org.junit.Ignore
import org.junit.Test

@Ignore("Fix semantic highlighting and implement new tests")
class YangSemanticHighlightingCalculatorTest extends AbstractYangLSPTest {

	@Inject
	extension UriExtensions;


	@Before
	def void before() {
		initialize[
			capabilities = new ClientCapabilities() => [
				textDocument = new TextDocumentClientCapabilities() => [
					semanticTokens = new SemanticTokensCapabilities(true) => [
						overlappingTokenSupport = true;
					];
				];
			];
		]
	}

	@Test
	def void checkStylesAndScopes() {
		/*
		 * val scopes = YangSemanticHighlightingCalculator.Scopes.declaredFields.filter [
			modifiers.static && modifiers.public && type === List
		];
		val styles = YangSemanticHighlightingCalculator.Styles.declaredFields.filter [
			modifiers.static && modifiers.public && type === String
		];
		assertEquals(scopes.size, styles.size);
		assertEquals(YangSemanticHighlightingCalculator.STYLE_MAPPINGS.size, styles.size);
		scopes.forEach [ scope |
			val scopeName = scope.name;
			val expectedStyleName = scopeName.replace('_SCOPES', '_STYLE');
			assertTrue('''Cannot find style '«expectedStyleName»' for scope: «scopeName».''', styles.exists [
				name == expectedStyleName
			]);
		];
		styles.forEach [ style |
			val styleName = style.name;
			val expectedScopeName = styleName.replace('_STYLE', '_SCOPES');
			assertTrue('''Cannot find scope '«expectedScopeName»' for style: «styleName».''', scopes.exists [
				name == expectedScopeName
			]);
		];*/
	}

	@Test
	def void checkDescription_singleLine() {
		/*'''
		module x {
		  description "desc";
		}'''.assertInfos('''
0 : []
1 : [14:6:«DESCRIPTION_SCOPES»]
2 : []''');*/
	}

	@Test
	def void checkDescription_multiLine() {
		/* 
		'''
		module x {
		  description 
		   "
		     blabla
		  
		      ";
		}'''.assertInfos('''
0 : []
1 : []
2 : [3:1:«DESCRIPTION_SCOPES»]
3 : [0:11:«DESCRIPTION_SCOPES»]
4 : [0:2:«DESCRIPTION_SCOPES»]
5 : [0:7:«DESCRIPTION_SCOPES»]
6 : []''');
*/
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
//		val uri = open(content, 'MyModel');
//		val params = semanticHighlightingParams;
//		assertEquals(1, params.size);
//		val entry = params.entrySet.findFirst[key.uri == uri];
//		assertNotNull(entry);
//		val actual = entry.value.map[it -> scopes].map[toExpectation].join('\n');
//		assertEquals(expected, actual);
	}

}
