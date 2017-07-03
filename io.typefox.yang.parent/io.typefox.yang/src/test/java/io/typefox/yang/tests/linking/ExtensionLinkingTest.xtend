package io.typefox.yang.tests.linking

import io.typefox.yang.yang.Extension
import io.typefox.yang.yang.Unknown
import org.junit.Assert
import org.junit.Test

class ExtensionLinkingTest extends AbstractLinkingTest {

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
		val unk = m.root.subStatements.filter(Unknown).head
		Assert.assertSame(unk.extension, m.root.subStatements.filter(Extension).head)
	}
}
