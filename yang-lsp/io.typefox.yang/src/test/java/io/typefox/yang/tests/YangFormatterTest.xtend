package io.typefox.yang.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.formatter.FormatterTestHelper
import org.junit.Test

class YangFormatterTest extends AbstractYangTest {

	@Inject extension protected FormatterTestHelper

	@Test
	def void testFormatting_01() {
		assertFormatted[
			expectation = '''
				module mytestid {
				    yang-version 1.1;
				}
			'''
			toBeFormatted = '''
				module mytestid { yang-version 1.1 ; }
			'''
		]
	}
}
