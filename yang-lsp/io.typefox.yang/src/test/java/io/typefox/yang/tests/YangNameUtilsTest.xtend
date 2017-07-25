package io.typefox.yang.tests

import org.junit.Test

import static extension io.typefox.yang.utils.YangNameUtils.escapeModuleName
import static extension org.junit.Assert.*

/**
 * Test for the YANG name utilities class.
 * 
 * @author akos.kitta
 */
class YangNameUtilsTest {

	@Test
	def void check_escapeModuleName_01() {
		"foo-bar".assertEquals("foo bar".escapeModuleName);
	}

	@Test
	def void check_escapeModuleName_02() {
		"foo-bar".assertEquals("  foo bar".escapeModuleName);
	}

	@Test
	def void check_escapeModuleName_03() {
		"foo-bar".assertEquals("foo bar  ".escapeModuleName);
	}

	@Test
	def void check_escapeModuleName_04() {
		"foo-bar".assertEquals("foo bar".escapeModuleName);
	}

	@Test
	def void check_escapeModuleName_05() {
		"foo-bar".assertEquals("foo   bar".escapeModuleName);
	}

	@Test
	def void check_escapeModuleName_07() {
		"foo-bar".assertEquals("foo\n\nbar".escapeModuleName);
	}

	@Test
	def void check_escapeModuleName_08() {
		"foo-bar".assertEquals("foo bar\t\n".escapeModuleName);
	}

	@Test
	def void check_escapeModuleName_06() {
		"foo-bar-baz".assertEquals("foo  bar  baz".escapeModuleName);
	}

}
