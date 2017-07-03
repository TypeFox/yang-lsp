package io.typefox.yang.tests.linking

import org.junit.Test
import org.junit.Assert
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef

class TypeLinkingTest extends AbstractLinkingTest {
	
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