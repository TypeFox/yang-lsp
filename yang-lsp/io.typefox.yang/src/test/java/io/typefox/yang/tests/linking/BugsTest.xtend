package io.typefox.yang.tests.linking

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

class BugsTest extends AbstractYangTest {
	/**
	 * https://github.com/theia-ide/yang-lsp/issues/33
	 */
	@Test def void testIssue33() {
		loadWithSyntaxErrors('''
			module moduleName {
			  // yang-version 1.1;
			  
			 //yan
			  y
			 
			  namespace "urn:someUri";
			  prefix "foo";
			
			
			
			description "bar";
			
			organization "org";
			
			grouping foo {
			        list feuillage {
			            description "Local feuillage docstring";
			            uses bar {
			                refine blatt {
			                    default "beech";
			                }
			            }
			            uses baz {
			                refine "leaves" {
			                    default cz;
			                }
			                refine "leaves/cz/lupen" {
			                    min-elements 0;
			                }
			                refine "leaves/dustbin/dustbin/hoja" {
			                    description "Refined description of hoja";
			                }
			            }
			            key "feuille";
			        }
			        anyxml rubbish;
			    }
			  
			}
		''').root
	}
	
}