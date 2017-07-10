package io.typefox.yang.tests.integration

import io.typefox.yang.YangStandaloneSetup
import io.typefox.yang.parser.antlr.lexer.jflex.JFlexBasedInternalYangLexer
import java.io.File
import java.nio.file.Files
import java.util.Collection
import org.antlr.runtime.ANTLRFileStream
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.XtextSyntaxDiagnostic
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameters

@FinalFieldsConstructor
@RunWith(Parameterized)
class IntegrationTest {
	
	@Parameters(name= "{0}")
	static def Collection<Object[]> getFiles() {
		val params = newArrayList
		scanRecursively(new File("./test-data")) [
			val arr = <Object>newArrayOfSize(1)
			arr.set(0, it)
			params.add(arr)
		]
		return params
	}
	
	static def void scanRecursively(File file, (File)=>void acceptor) {
		if (file.isDirectory) {
			for (f : file.listFiles) {			
				scanRecursively(f, acceptor)
			}
		} else {
			if (file.name.endsWith('.yang')) {
				acceptor.apply(file)
			}
		}
	}
	
	val File file
	
	@Test def void testLexing() {
		val lexer = new JFlexBasedInternalYangLexer()
		lexer.charStream = new ANTLRFileStream(file.absolutePath)
		var t = lexer.nextToken
		val buffer = new StringBuffer
		val tokens = newArrayList
		while (t.type !== JFlexBasedInternalYangLexer.EOF) {
			if (t.type === JFlexBasedInternalYangLexer.RULE_ANY_OTHER) {
				Assert.fail('''
					Lexing «file.name» failed.
					```
						«buffer» !«t.text»!«(1..5).map[lexer.nextToken].join('')[text]»...
					```
				''')				
			}
			try {
				buffer.append(t.text)
				tokens.add(t) 
				t = lexer.nextToken
			} catch (Error e) {
			}
		}
	}
	val static injector = new YangStandaloneSetup().createInjectorAndDoEMFRegistration
	val rs = injector.getInstance(XtextResourceSet)
	
	@Test def void testParsing() {
		val resource = rs.getResource(URI.createFileURI(this.file.absolutePath), true)
		for (issue : resource.errors.filter(XtextSyntaxDiagnostic)) {
			val contents = new String(Files.readAllBytes(this.file.toPath))
			Assert.assertEquals(contents, '''«contents.substring(0, issue.offset)»!«contents.substring(issue.offset, issue.offset+issue.length)»!{«issue.message»}«contents.substring(issue.offset+issue.length)»'''.toString)
		}
		Assert.assertTrue(resource.errors.join(","), resource.errors.isEmpty)
	}
	
}