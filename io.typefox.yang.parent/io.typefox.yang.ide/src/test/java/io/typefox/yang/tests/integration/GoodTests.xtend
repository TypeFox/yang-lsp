package io.typefox.yang.tests.integration

import java.io.File
import java.nio.file.Files
import java.util.Collection
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.lsp4j.Diagnostic
import org.eclipse.lsp4j.Position
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.testing.AbstractLanguageServerTest
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameters
import org.junit.Ignore

@FinalFieldsConstructor
@RunWith(Parameterized)
class GoodTests {
	
	static class DiagnosticsTest extends AbstractLanguageServerTest {		
		new() {
			super('yang')
		}
	
		def Collection<Object[]> getUrisAndDiagnostics() {
			initialize[
				rootUri = new File("./test-data/good").absoluteFile.toURI.toString
			]
			return diagnostics.entrySet.map[ 
				val result = <Object>newArrayOfSize(3)
				result.set(0, it.key)
				result.set(1, it.value)
				result.set(2, URI.createURI(it.key).lastSegment)
				return result
			].toList
		}
	}
	
	@Parameters(name="{2}")
	def static Collection<Object[]> getURIAndDiagnostics() {
		val test = new DiagnosticsTest()
		test.setup
		return test.getUrisAndDiagnostics()
	}
	
	val String uri
	val List<Diagnostic> diagnostics
	val protected String simpleName // only used in value of @Parameters
	
	@Ignore("TODO")
	@Test def void runGoodTests() {
		val issues = diagnostics.sortBy[range.start.line].sortBy[range.start.character].toList
		val inserts = newArrayList()
		val lines = Files.readAllLines(new File(URI.createURI(uri).toFileString).toPath)
		for (issueNo : 0..<issues.size) {
			val issue = issues.get(issueNo)
			inserts += new Insert(toOffset(issue.range.start, lines),"[")
			inserts += new Insert(toOffset(issue.range.end, lines),"]("+issue.message+")")
		}
		val sorted = inserts.sortBy[offset]
		val original = lines.join("\n")
		var annotated = ""
		var lastInsert = 0
		for (insert : sorted) {
			annotated += original.substring(lastInsert, insert.offset)
			annotated += insert.content
			lastInsert = insert.offset 
		}
		annotated += original.substring(lastInsert)
		Assert.assertEquals(original, annotated)
	}
	
	@Data static class Insert {
		int offset
		String content
	}
	
	def int toOffset(Position pos, List<String> strings) {
		var offset = 0
		for (line : 0..<strings.size) {
			if (pos.line === line) {
				return offset + pos.character + pos.line
			} else {
				offset += strings.get(line).length
			}
		}
		throw new IndexOutOfBoundsException
	}
}