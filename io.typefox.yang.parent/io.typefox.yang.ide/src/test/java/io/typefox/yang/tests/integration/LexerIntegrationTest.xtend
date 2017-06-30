package io.typefox.yang.tests.integration

import io.typefox.yang.parser.antlr.lexer.jflex.JFlexBasedInternalYangLexer
import java.io.File
import java.util.Collection
import org.antlr.runtime.ANTLRFileStream
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameters

@FinalFieldsConstructor
@RunWith(Parameterized)
class LexerIntegrationTest {
	
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
				t = lexer.nextToken
				
			} catch (Error e) {
			}
		}
	}
	
}