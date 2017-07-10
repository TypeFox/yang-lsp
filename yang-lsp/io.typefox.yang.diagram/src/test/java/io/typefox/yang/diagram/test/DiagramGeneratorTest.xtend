package io.typefox.yang.diagram.test

import com.google.inject.Inject
import io.typefox.yang.diagram.YangDiagramGenerator
import io.typefox.yang.tests.YangInjectorProvider
import io.typefox.yang.yang.AbstractModule
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.util.CancelIndicator
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(YangInjectorProvider)
class DiagramGeneratorTest {
	
	@Inject ParseHelper<AbstractModule> parseHelper
	
	protected def assertGeneratedTo(CharSequence source, CharSequence target) {
		val model = parseHelper.parse(source)
		val generator = new YangDiagramGenerator
		val diagram = generator.generateDiagram(model, CancelIndicator.NullImpl)
		Assert.assertEquals(target.toString.trim, diagram.toString)
	}

	@Test
	def void testGenerator() {
		'''
			module mytest {
			    yang-version 1.1;
			    namespace "urn:example:system";
			    prefix "myerert";
			
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
			            description "this is a simple test leaf!!";
			        }
			    }
			
			    container groupingTest {
			        uses anotherGroup;
			    }
			}
		'''.assertGeneratedTo('''
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
			      id = "mytest"
			      children = ArrayList (
			        SLabel [
			          position = Point [
			            x = 5.0
			            y = 5.0
			          ]
			          size = null
			          text = "myerert:mytest"
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
			                  id = "mytest-node-testcontainer-innerTestContainer-innerTestList-meAlone"
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
			                  text = "keyLeaf: string"
			                  type = "label:text"
			                  id = "mytest-node-testcontainer-innerTestContainer-keyLeaf"
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
			                  id = "mytest-node-testcontainer-leafList"
			                  children = ArrayList ()
			                ],
			                SLabel [
			                  position = null
			                  size = null
			                  text = "anotherLeaf: string"
			                  type = "label:text"
			                  id = "mytest-node-testcontainer-anotherLeaf"
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
			                  id = "mytest-node-ip"
			                  children = ArrayList ()
			                ],
			                SLabel [
			                  position = null
			                  size = null
			                  text = "port: string"
			                  type = "label:text"
			                  id = "mytest-node-port"
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
			                  id = "mytest-node-anotherGroupLeaf"
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
			                  id = "mytest-node-testleaf"
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
			              children = ArrayList ()
			            ]
			          )
			        ]
			      )
			    ]
			  )
			]
		''')
	}
}
