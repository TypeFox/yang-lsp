package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.yang.XpathExpression
import io.typefox.yang.yang.XpathNameTest
import org.junit.Test

import static org.junit.Assert.*

import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension org.eclipse.xtext.nodemodel.util.NodeModelUtils.*

class Bug163Test extends AbstractYangTest {
		
	@Test 
	def void testPathLink1() {
		val r = '''
			module m1 {
				yang-version 1.1;
				prefix m;
				namespace m;
			
				container c1 {
				    leaf a {
				        description "The referenced leaf";
				        type int32;
				    }
			
				    list list-a {
				        key "id";
				        leaf id {
				            type string;
				        }
				        leaf y1 {
				                type leafref {
				                    path "../../a";
				                }              
				        }
				        leaf y2 {
				                type leafref {
				                    path "/c1/a";
				                }              
				        }
				    }
			
				    action func {
				        input {
				            leaf x2 {
				                type leafref {
				                    path "../../a"; 
				                }
				            }
				            leaf x3 {
				                type leafref {
				                    path "/c1/a";
				                }
				            }
				        }
				    }
				}
			}
		'''.load()
		r.assertNoErrors()
		r.allContents.filter(XpathNameTest).forEach [
			val exprNode = getContainerOfType(XpathExpression).node
			assertFalse('''Unresolved reference: «exprNode.text» (line «exprNode.startLine»)''', ref.eIsProxy)
		]
	}
	
	@Test 
	def void testPathLink2() {
		val r = '''
			module m1 {
				prefix c;
				namespace c;
			
			    grouping gy-failure-profile-type {
			        leaf name {
			            type string;
			        }
			    }
			    grouping gy-profile-type {
			        leaf name {
			            type string;
			        }
			        leaf failure-profile {
			            type leafref {
			                path "../../gy-failure-profile/name";  
			            }
			        }
			    }
			
			    grouping pgw-type {
			        container credit-control {
			            list gy-failure-profile {
			                key "name";
			                uses gy-failure-profile-type;
			            }
			
			            list gy-profile {
			                key "name";
			                uses gy-profile-type;
			            }
			        }
			    }
			
			    container epg {
			        container pgw {
			            uses pgw-type;
			        }
			    }
			}
		'''.load()
		r.assertNoErrors()
		r.allContents.filter(XpathNameTest).forEach [
			val exprNode = getContainerOfType(XpathExpression).node
			assertFalse('''Unresolved reference: «exprNode.text» (line «exprNode.startLine»)''', ref.eIsProxy)
		]
	}
	
}