package io.typefox.yang.tests.validation

import io.typefox.yang.tests.AbstractYangTest
import java.io.File
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.workspace.FileProjectConfig
import org.eclipse.xtext.workspace.ProjectConfigAdapter
import org.junit.Assert
import org.junit.Test

class ValidationExtensionTest extends AbstractYangTest {
	
	static val BAD_NAME = "bad_name"
	
	@Test def void testExtensionNotRegistered() {
		val m  = load('''
			module foo {
				
			}
		''')
		assertNoErrors(m.root, BAD_NAME)
	}
	
	@Test def void testExtensionRegistered() {
		val root = new File("./src/test/resources/project").canonicalFile
		ProjectConfigAdapter.install(resourceSet, new FileProjectConfig(root))
		
		val m  = load('''
			module foo {
				
			}
		''')
		val validate = this.validator.validate(m.root.eResource)
		val issue = validate.findFirst[code == BAD_NAME]
		Assert.assertEquals(Severity.WARNING, issue.severity)
	}
	
	@Test def void testExtensionIssueRange() {
		val root = new File("./src/test/resources/project").canonicalFile
		ProjectConfigAdapter.install(resourceSet, new FileProjectConfig(root))
		
		val m  = load('''
			module foo {
				
			}
		''')
		val validate = this.validator.validate(m.root.eResource)
		val issue = validate.findFirst[code == BAD_NAME]
		Assert.assertNotNull("Expected issue with code " + BAD_NAME, issue)
		// "foo" starts at offset 7, length 3 in "module foo {"
		Assert.assertEquals(7, issue.offset.intValue)
		Assert.assertEquals(3, issue.length.intValue)
		// start line/column
		Assert.assertEquals(1, issue.lineNumber.intValue)
		Assert.assertEquals(8, issue.column.intValue)
		// end line/column must point to end of "foo", not default to [0,0]
		Assert.assertEquals(1, issue.lineNumberEnd.intValue)
		Assert.assertEquals(11, issue.columnEnd.intValue)
	}
}