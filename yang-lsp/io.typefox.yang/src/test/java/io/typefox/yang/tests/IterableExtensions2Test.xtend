package io.typefox.yang.tests

import java.util.List
import org.junit.Test

import static io.typefox.yang.utils.IterableExtensions2.*

import static extension org.junit.Assert.assertEquals

/**
 * Test for the iterables extensions.
 * 
 * @author akos.kitta
 */
class IterableExtensions2Test {

	@Test(expected=NullPointerException)
	def void check_toPrettyString_01() {
		toPrettyString(null as List<?>, 'does not matter');
	}

	@Test
	def void check_toPrettyString_02() {
		''.assertEquals(toPrettyString(emptyList, 'does not matter'));
	}

	@Test
	def void check_toPrettyString_03() {
		'a'.assertEquals(toPrettyString(#['a'], 'does not matter'));
	}

	@Test
	def void check_toPrettyString_04() {
		'a, b'.assertEquals(toPrettyString(#['a', 'b'], null));
	}

	@Test
	def void check_toPrettyString_05() {
		'a, b, c'.assertEquals(toPrettyString(#['a', 'b', 'c'], null));
	}

	@Test
	def void check_toPrettyString_06() {
		'a, b or c'.assertEquals(toPrettyString(#['a', 'b', 'c'], 'or'));
	}

}
