package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Extension
import io.typefox.yang.yang.Unknown
import org.junit.Assert
import org.junit.Test

class ExtensionLinkingTest extends AbstractYangTest {

	@Test def void testLocalExtension() {
		val m = load('''
			module xt7 {
			  prefix x;
			  namespace "urn:test:xt7";
			
			  leaf foo {
			    type int16;
			    x:foo "some string";
			  }
			
			  x:foo "another string";
			
			  extension foo {
			    argument bar {
			      yin-element false;
			    }
			  }
			}
		''')
		val unk = m.root.substatementsOfType(Unknown).head
		Assert.assertSame(unk.extension, m.root.substatements.filter(Extension).head)
	}
}
