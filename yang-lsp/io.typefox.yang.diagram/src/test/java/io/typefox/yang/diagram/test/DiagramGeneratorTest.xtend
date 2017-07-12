package io.typefox.yang.diagram.test

import io.typefox.yang.diagram.YangDiagramGenerator
import io.typefox.yang.tests.AbstractYangTest
import io.typefox.yang.tests.YangInjectorProvider
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.util.CancelIndicator
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.Ignore

@RunWith(XtextRunner)
@InjectWith(YangInjectorProvider)
class DiagramGeneratorTest extends AbstractYangTest{
	
	protected def assertGeneratedTo(Resource source, CharSequence target) {
		val generator = new YangDiagramGenerator
		val diagram = generator.generateDiagram(source.root, CancelIndicator.NullImpl)
		Assert.assertEquals(target.toString.trim, diagram.toString)
	}

	@Test @Ignore
	def void testGenerator() {
		load('''
		module mytest2 {
		    yang-version 1.1;
		    namespace "urn:example2:system";
		    prefix "myt2";
		
		    grouping mytest2Group {
		        description "Group of mytest2, man!";
		        leaf mytest2GroupLeaf {
		            type string;
		        }
		     }
		
		    container bla {
		        leaf blubb {
		            type string;
		            description "ein test";
		        }
		    }
		
		}''')
		val r2 = load('''
			module mytest {
			    yang-version 1.1;
			    namespace "urn:example:system";
			    prefix "myt";
			
			    import mytest2{
			        prefix "myt2";
			    }
			
			    grouping endpoint {
			       description "A reusable endpoint group.";
			       leaf ip {
			         type string;
			       }
			       leaf port {
			         type string;
			       }
			     }
			
			     grouping anotherGroup {
			         description "Another group, yo!";
			         leaf anotherGroupLeaf {
			             type string;
			         }
			     }
			
			     augment "/myt:testcontainer" {
			         leaf augmentLeaf {
			             type string;
			         }
			     }
			
			     augment "/myt:testcontainer/myt:innerTestContainer" {
			         uses myt2:mytest2Group;
			     }
			
			     augment "/myt2:bla" {
			         leaf blaLeaf {
			             type string;
			         }
			     }
			
			     container testcontainer {
			        container innerTestContainer {
			            list innerTestList {
			                key "keyLeaf";
			                container listContainer {
			                    leaf meAlone {
			                        type string;
			                    }
			                }
			                leaf keyLeaf {
			                    type string;
			                }
			            }
			            leaf-list leafList {
			                type string;
			            }
			            leaf anotherLeaf {
			                type string;
			            }
			        }
			        leaf testleaf {
			            type string;
			            description "this is a simple test leaf!";
			        }
			    }
			
			    container groupingTest {
			        uses anotherGroup;
			    }
			
			    container externalGroupingTest {
			        uses myt2:mytest2Group;
			    }
			}
		''')
		
		r2.assertGeneratedTo('''
			SGraph [
			  position = null
			  size = null
			  canvasBounds = null
			  type = "graph"
			  id = "yang"
			  children = ArrayList (
			    SNode [
			      position = null
			      size = null
			      layout = null
			      resizeContainer = null
			      type = "node:module"
			      id = "mytest2"
			      children = ArrayList (
			        SLabel [
			          position = Point [
			            x = 5.0
			            y = 5.0
			          ]
			          size = null
			          text = "myt2:mytest2"
			          type = "label:heading"
			          id = "mytest2-label"
			          children = ArrayList ()
			        ]
			      )
			    ],
			    SNode [
			      position = null
			      size = null
			      layout = null
			      resizeContainer = null
			      type = "node:module"
			      id = "mytest"
			      children = ArrayList (
			        SLabel [
			          position = Point [
			            x = 5.0
			            y = 5.0
			          ]
			          size = null
			          text = "myt:mytest"
			          type = "label:heading"
			          id = "mytest-label"
			          children = ArrayList ()
			        ],
			        SNode [
			          position = null
			          size = null
			          layout = null
			          resizeContainer = null
			          type = "node:note"
			          id = "mytest-note"
			          children = ArrayList ()
			        ],
			        SNode [
			          position = null
			          size = null
			          layout = "vbox"
			          resizeContainer = null
			          type = "node:class"
			          id = "mytest-node"
			          children = ArrayList (
			            SLabel [
			              position = null
			              size = null
			              text = "[M] mytest"
			              type = "label:heading"
			              id = "mytest-node-label"
			              children = ArrayList ()
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest-node-testcontainer-innerTestContainer-innerTestList"
			          targetId = "mytest-node-testcontainer-innerTestContainer-innerTestList-listContainer"
			          routingPoints = null
			          type = "edge:composition"
			          id = "mytest-node-testcontainer-innerTestContainer-innerTestList2mytest-node-testcontainer-innerTestContainer-innerTestList-listContainer-edge"
			          children = ArrayList ()
			        ],
			        SNode [
			          position = null
			          size = null
			          layout = "vbox"
			          resizeContainer = null
			          type = "node:class"
			          id = "mytest-node-testcontainer-innerTestContainer-innerTestList-listContainer"
			          children = ArrayList (
			            SLabel [
			              position = null
			              size = null
			              text = "[C] listContainer"
			              type = "label:heading"
			              id = "mytest-node-testcontainer-innerTestContainer-innerTestList-listContainer-label"
			              children = ArrayList ()
			            ],
			            SCompartment [
			              layout = "vbox"
			              resizeContainer = null
			              type = "comp:comp"
			              id = "mytest-node-testcontainer-innerTestContainer-innerTestList-listContainer-compartment"
			              children = ArrayList (
			                SLabel [
			                  position = null
			                  size = null
			                  text = "meAlone: string"
			                  type = "label:text"
			                  id = "mytest-node-testcontainer-innerTestContainer-innerTestList-listContainer-meAlone"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest-node-testcontainer-innerTestContainer"
			          targetId = "mytest-node-testcontainer-innerTestContainer-innerTestList"
			          routingPoints = null
			          type = "edge:composition"
			          id = "mytest-node-testcontainer-innerTestContainer2mytest-node-testcontainer-innerTestContainer-innerTestList-edge"
			          children = ArrayList ()
			        ],
			        SNode [
			          position = null
			          size = null
			          layout = "vbox"
			          resizeContainer = null
			          type = "node:class"
			          id = "mytest-node-testcontainer-innerTestContainer-innerTestList"
			          children = ArrayList (
			            SLabel [
			              position = null
			              size = null
			              text = "[L] innerTestList"
			              type = "label:heading"
			              id = "mytest-node-testcontainer-innerTestContainer-innerTestList-label"
			              children = ArrayList ()
			            ],
			            SCompartment [
			              layout = "vbox"
			              resizeContainer = null
			              type = "comp:comp"
			              id = "mytest-node-testcontainer-innerTestContainer-innerTestList-compartment"
			              children = ArrayList (
			                SLabel [
			                  position = null
			                  size = null
			                  text = "KEY: keyLeaf: string"
			                  type = "label:text"
			                  id = "mytest-node-testcontainer-innerTestContainer-innerTestList-keyLeaf"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest-node-testcontainer"
			          targetId = "mytest-node-testcontainer-innerTestContainer"
			          routingPoints = null
			          type = "edge:composition"
			          id = "mytest-node-testcontainer2mytest-node-testcontainer-innerTestContainer-edge"
			          children = ArrayList ()
			        ],
			        SNode [
			          position = null
			          size = null
			          layout = "vbox"
			          resizeContainer = null
			          type = "node:class"
			          id = "mytest-node-testcontainer-innerTestContainer"
			          children = ArrayList (
			            SLabel [
			              position = null
			              size = null
			              text = "[C] innerTestContainer"
			              type = "label:heading"
			              id = "mytest-node-testcontainer-innerTestContainer-label"
			              children = ArrayList ()
			            ],
			            SCompartment [
			              layout = "vbox"
			              resizeContainer = null
			              type = "comp:comp"
			              id = "mytest-node-testcontainer-innerTestContainer-compartment"
			              children = ArrayList (
			                SLabel [
			                  position = null
			                  size = null
			                  text = "leafList[]: string"
			                  type = "label:text"
			                  id = "mytest-node-testcontainer-innerTestContainer-leafList"
			                  children = ArrayList ()
			                ],
			                SLabel [
			                  position = null
			                  size = null
			                  text = "anotherLeaf: string"
			                  type = "label:text"
			                  id = "mytest-node-testcontainer-innerTestContainer-anotherLeaf"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest-node"
			          targetId = "mytest-node-testcontainer"
			          routingPoints = null
			          type = "edge:composition"
			          id = "mytest-node2mytest-node-testcontainer-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest-node"
			          targetId = "mytest-node-groupingTest"
			          routingPoints = null
			          type = "edge:composition"
			          id = "mytest-node2mytest-node-groupingTest-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest-node"
			          targetId = "mytest-node-externalGroupingTest"
			          routingPoints = null
			          type = "edge:composition"
			          id = "mytest-node2mytest-node-externalGroupingTest-edge"
			          children = ArrayList ()
			        ],
			        SNode [
			          position = null
			          size = null
			          layout = "vbox"
			          resizeContainer = null
			          type = "node:class"
			          id = "mytest-node-endpoint"
			          children = ArrayList (
			            SLabel [
			              position = null
			              size = null
			              text = "[G] endpoint"
			              type = "label:heading"
			              id = "mytest-node-endpoint-label"
			              children = ArrayList ()
			            ],
			            SCompartment [
			              layout = "vbox"
			              resizeContainer = null
			              type = "comp:comp"
			              id = "mytest-node-endpoint-compartment"
			              children = ArrayList (
			                SLabel [
			                  position = null
			                  size = null
			                  text = "ip: string"
			                  type = "label:text"
			                  id = "mytest-node-endpoint-ip"
			                  children = ArrayList ()
			                ],
			                SLabel [
			                  position = null
			                  size = null
			                  text = "port: string"
			                  type = "label:text"
			                  id = "mytest-node-endpoint-port"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SNode [
			          position = null
			          size = null
			          layout = "vbox"
			          resizeContainer = null
			          type = "node:class"
			          id = "mytest-node-anotherGroup"
			          children = ArrayList (
			            SLabel [
			              position = null
			              size = null
			              text = "[G] anotherGroup"
			              type = "label:heading"
			              id = "mytest-node-anotherGroup-label"
			              children = ArrayList ()
			            ],
			            SCompartment [
			              layout = "vbox"
			              resizeContainer = null
			              type = "comp:comp"
			              id = "mytest-node-anotherGroup-compartment"
			              children = ArrayList (
			                SLabel [
			                  position = null
			                  size = null
			                  text = "anotherGroupLeaf: string"
			                  type = "label:text"
			                  id = "mytest-node-anotherGroup-anotherGroupLeaf"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SNode [
			          position = null
			          size = null
			          layout = "vbox"
			          resizeContainer = null
			          type = "node:class"
			          id = "mytest-node-testcontainer"
			          children = ArrayList (
			            SLabel [
			              position = null
			              size = null
			              text = "[C] testcontainer"
			              type = "label:heading"
			              id = "mytest-node-testcontainer-label"
			              children = ArrayList ()
			            ],
			            SCompartment [
			              layout = "vbox"
			              resizeContainer = null
			              type = "comp:comp"
			              id = "mytest-node-testcontainer-compartment"
			              children = ArrayList (
			                SLabel [
			                  position = null
			                  size = null
			                  text = "testleaf: string"
			                  type = "label:text"
			                  id = "mytest-node-testcontainer-testleaf"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SNode [
			          position = null
			          size = null
			          layout = "vbox"
			          resizeContainer = null
			          type = "node:class"
			          id = "mytest-node-groupingTest"
			          children = ArrayList (
			            SLabel [
			              position = null
			              size = null
			              text = "[C] groupingTest"
			              type = "label:heading"
			              id = "mytest-node-groupingTest-label"
			              children = ArrayList ()
			            ],
			            SCompartment [
			              layout = "vbox"
			              resizeContainer = null
			              type = "comp:comp"
			              id = "mytest-node-groupingTest-compartment"
			              children = ArrayList (
			                SLabel [
			                  position = null
			                  size = null
			                  text = "uses anotherGroup"
			                  type = "label:text"
			                  id = "mytest-node-groupingTest-uses-anotherGroup"
			                  children = ArrayList ()
			                ],
			                SEdge [
			                  sourceId = "mytest-node-groupingTest"
			                  targetId = "mytest-node-anotherGroup"
			                  routingPoints = null
			                  type = "edge:uses"
			                  id = "mytest-node-groupingTest2mytest-node-anotherGroup-edge"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SNode [
			          position = null
			          size = null
			          layout = "vbox"
			          resizeContainer = null
			          type = "node:class"
			          id = "mytest-node-externalGroupingTest"
			          children = ArrayList (
			            SLabel [
			              position = null
			              size = null
			              text = "[C] externalGroupingTest"
			              type = "label:heading"
			              id = "mytest-node-externalGroupingTest-label"
			              children = ArrayList ()
			            ],
			            SCompartment [
			              layout = "vbox"
			              resizeContainer = null
			              type = "comp:comp"
			              id = "mytest-node-externalGroupingTest-compartment"
			              children = ArrayList (
			                SLabel [
			                  position = null
			                  size = null
			                  text = "uses mytest2Group"
			                  type = "label:text"
			                  id = "mytest-node-externalGroupingTest-uses-mytest2Group"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest2"
			          targetId = "mytest-node"
			          routingPoints = null
			          type = "edge:import"
			          id = "mytest22mytest-node-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest-node-groupingTest"
			          targetId = "mytest-node-anotherGroup"
			          routingPoints = null
			          type = "edge:uses"
			          id = "mytest-node-groupingTest2mytest-node-anotherGroup-edge"
			          children = ArrayList ()
			        ]
			      )
			    ]
			  )
			]
		''')
	}
}
