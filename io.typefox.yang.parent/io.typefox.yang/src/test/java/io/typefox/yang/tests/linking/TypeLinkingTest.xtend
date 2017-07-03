package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import org.junit.Assert
import org.junit.Test

class TypeLinkingTest extends AbstractYangTest {
	
	@Test def void testTypeLinking() {
		val m = load('''
			module foo {
				prefix "yt4";
				leaf xx { type con1_typ1; }
				leaf xxx { type yt4:con1_typ1; }
				typedef con1_typ1 {
					type string;
				}
			}
		''')
		val leafs = m.root.subStatements.filter(Leaf).iterator
		val typeDef = m.root.subStatements.filter(Typedef).head
		Assert.assertSame(typeDef, leafs.next.subStatements.filter(Type).head.typeRef.type)
		Assert.assertSame(typeDef, leafs.next.subStatements.filter(Type).head.typeRef.type)
	}
}