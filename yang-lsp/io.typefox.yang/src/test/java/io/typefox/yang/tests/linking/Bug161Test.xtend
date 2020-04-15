package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.Deviation
import org.junit.Test

import static org.junit.Assert.*

import static extension org.eclipse.xtext.nodemodel.util.NodeModelUtils.*

class Bug161Test extends AbstractYangTest {

	@Test 
	def void testAugmentInDeepUsesGrouping() {
		val ksExt = '''
			module ik {
			  yang-version 1.1;
			  prefix m;
			  namespace m;
			
			  grouping ct_akpwcg {
			    container pkt {
			      leaf lf_hpri_key {
			        type empty;
			      }
			    }
			  }
			  grouping ks_akpwcg {
			    uses ct_akpwcg {
			      augment pkt {
			        container c_en_pri_key {
			          uses evg;
			        }
			      }
			    }
			  }
			  grouping evg {
			    leaf value {
			       type binary;
			    }
			  }
			  uses ks_akpwcg;
			
			  deviation /pkt/lf_hpri_key {
			    deviate not-supported;
			  }
			
			  deviation /pkt/c_en_pri_key {
			    deviate not-supported;
			  }
			}
		'''.load()
		ksExt.assertNoErrors()

		val deviations = ksExt.root.eAllContents.filter(Deviation).toSet
		assertEquals(2, deviations.size)
		deviations.forEach[ dev |
			val refNode = dev.reference.node
			assertFalse('''Unresolved reference: «refNode.text» (line «refNode.startLine»)''',
				dev.reference.schemaNode.eIsProxy)
		]
	}

}