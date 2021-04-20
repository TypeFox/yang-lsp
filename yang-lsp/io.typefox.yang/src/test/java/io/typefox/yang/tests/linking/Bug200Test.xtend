package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.List
import org.junit.Test

import static org.junit.Assert.assertNotNull
import static org.junit.Assert.assertTrue
import static org.junit.Assert.assertEquals

class Bug200Test extends AbstractYangTest {
	val augment_super = '''
		module augment-super {
		   namespace "urn:test";
		   prefix "as";
		   
		   include augment-sub0;
		   include augment-sub1;
		        
		   augment "/interfaces/ifEntry" {
		   } 
		 }
		
		
	'''

	val augment_sub1 = '''
		submodule augment-sub1 {
		  belongs-to augment-super {
		    prefix "as";
		  }
		
		  include augment-sub0;
		
		  augment "/interfaces" {
		    list ifEntry {
		    }
		  }
		} 
	'''
	val augment_sub0 = '''
		submodule augment-sub0 {
		  belongs-to augment-super {
		    prefix "as";
		  }
		  
		  container interfaces;
		
		} 
	'''

	@Test
	def void testBelongsToIncludeLinking_01() {
		// path doesn't matter but better for debugging
		val superRes = augment_super.load('super')
		val sub1Res = augment_sub1.load('sub1')
		val sub0Res = augment_sub0.load('sub0')
		val superModule = superRes.root // fully resolve
		superRes.assertNoErrors;
		sub1Res.assertNoErrors;
		sub0Res.assertNoErrors;
		val schemaNode = superModule.substatements.filter(Augment)?.head?.path?.schemaNode
		assertNotNull('Augment with schema node not found in augment_super', schemaNode)
		assertTrue('Schemanode must be a List', schemaNode instanceof List)
		assertEquals((schemaNode as List).name, "ifEntry")
	}

	@Test
	def void testBelongsToIncludeLinking_02() {
		// path doesn't matter but better for debugging
		val sub0Res = augment_sub0.load('sub0')
		val superRes = augment_super.load('super')
		val sub1Res = augment_sub1.load('sub1')
		sub0Res.root // fully resolve
		superRes.assertNoErrors;
		sub1Res.assertNoErrors;
		sub0Res.assertNoErrors;
	}

	@Test
	def void testBelongsToIncludeLinking_03() {
		println('''''')
		// path doesn't matter but better for debugging
		val sub1Res = augment_sub1.load('sub1')
		val superRes = augment_super.load('super')
		val sub0Res = augment_sub0.load('sub0')
		sub1Res.root // fully resolve
		superRes.assertNoErrors;
		sub1Res.assertNoErrors;
		sub0Res.assertNoErrors;
	}

}
