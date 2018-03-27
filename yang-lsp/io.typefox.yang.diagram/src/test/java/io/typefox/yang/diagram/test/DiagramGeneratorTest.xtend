package io.typefox.yang.diagram.test

import io.typefox.yang.diagram.YangDiagramGenerator
import io.typefox.yang.tests.AbstractYangTest
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.util.CancelIndicator
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import com.google.inject.Inject

@RunWith(XtextRunner)
@InjectWith(YangDiagramInjectorProvider)
class DiagramGeneratorTest extends AbstractYangTest {
	
	@Inject YangDiagramGenerator generator
	
	protected def assertGeneratedTo(Resource source, CharSequence target) {
		val diagram = generator.generate(source, new TestDiagramState(source), CancelIndicator.NullImpl)
		Assert.assertEquals(target.toString.trim, diagram.toString)
	}

	@Test 
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
			  layoutOptions = LayoutOptions [
			    paddingLeft = 0.0
			    paddingRight = 0.0
			    paddingTop = 0.0
			    paddingBottom = 0.0
			    vGap = 0.0
			    hGap = 10.0
			    hAlign = "left"
			  ]
			  revision = 0
			  type = "graph"
			  id = "yang"
			  children = ArrayList (
			    YangNode [
			      expanded = false
			      trace = "synthetic:///__synthetic0.yang#/"
			      layout = "vbox"
			      layoutOptions = LayoutOptions [
			        paddingLeft = 5.0
			        paddingRight = 5.0
			        paddingTop = 5.0
			        paddingBottom = 5.0
			      ]
			      type = "node:module"
			      id = "mytest2:myt2"
			      children = ArrayList (
			        SCompartment [
			          layout = "hbox"
			          type = "comp:comp"
			          id = "mytest2:myt2-heading"
			          children = ArrayList (
			            SLabel [
			              text = "mytest2:myt2"
			              type = "label:heading"
			              id = "mytest2:myt2-label"
			              children = ArrayList ()
			            ],
			            SButton [
			              type = "button:expand"
			              id = "mytest2:myt2-expand"
			              children = ArrayList ()
			            ]
			          )
			        ]
			      )
			    ],
			    YangNode [
			      expanded = true
			      trace = "synthetic:///__synthetic1.yang#/"
			      layout = "vbox"
			      layoutOptions = LayoutOptions [
			        paddingLeft = 5.0
			        paddingRight = 5.0
			        paddingTop = 5.0
			        paddingBottom = 5.0
			      ]
			      type = "node:module"
			      id = "mytest:myt"
			      children = ArrayList (
			        SCompartment [
			          layout = "hbox"
			          type = "comp:comp"
			          id = "mytest:myt-heading"
			          children = ArrayList (
			            SLabel [
			              text = "mytest:myt"
			              type = "label:heading"
			              id = "mytest:myt-label"
			              children = ArrayList ()
			            ],
			            SButton [
			              type = "button:expand"
			              id = "mytest:myt-expand"
			              children = ArrayList ()
			            ]
			          )
			        ],
			        YangNode [
			          cssClass = "moduleNode"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "M"
			                      type = "label:tag"
			                      id = "mytest:myt-node-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "mytest"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-header-header-label"
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-/myt:testcontainer-augmentation"
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-/myt:testcontainer-augmentation-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation"
			          targetId = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-uses mytest2Group-pill"
			          type = "edge:composition"
			          id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation2mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-uses mytest2Group-pill-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          cssClass = "uses"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.7/@substatements.0"
			          layout = "vbox"
			          type = "node:pill"
			          id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-uses mytest2Group-pill"
			          children = ArrayList (
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 10.0
			                paddingRight = 10.0
			                paddingTop = 0.0
			                paddingBottom = 0.0
			                paddingFactor = 1.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-uses mytest2Group-pill-heading"
			              children = ArrayList (
			                SLabel [
			                  text = "uses mytest2Group"
			                  type = "label:heading"
			                  id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-uses mytest2Group-pill-heading-label"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation"
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-/myt2:bla-augmentation"
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-/myt2:bla-augmentation-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList"
			          targetId = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer"
			          type = "edge:composition"
			          id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList2mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          cssClass = "container"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.9/@substatements.0/@substatements.0/@substatements.1"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "C"
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "listContainer"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer-compartment"
			              children = ArrayList (
			                YangLabel [
			                  trace = "synthetic:///__synthetic1.yang#//@substatements.9/@substatements.0/@substatements.0/@substatements.1/@substatements.0"
			                  text = "meAlone: string"
			                  type = "ylabel:text"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer-meAlone"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-testcontainer-container-innerTestContainer"
			          targetId = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList"
			          type = "edge:composition"
			          id = "mytest:myt-node-container-testcontainer-container-innerTestContainer2mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          cssClass = "list"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.9/@substatements.0/@substatements.0"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "L"
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "innerTestList"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-compartment"
			              children = ArrayList (
			                YangLabel [
			                  trace = "synthetic:///__synthetic1.yang#//@substatements.9/@substatements.0/@substatements.0/@substatements.2"
			                  text = "* keyLeaf: string"
			                  type = "ylabel:text"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-keyLeaf"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-testcontainer"
			          targetId = "mytest:myt-node-container-testcontainer-container-innerTestContainer"
			          type = "edge:composition"
			          id = "mytest:myt-node-container-testcontainer2mytest:myt-node-container-testcontainer-container-innerTestContainer-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          cssClass = "container"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.9/@substatements.0"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-testcontainer-container-innerTestContainer"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "C"
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "innerTestContainer"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-compartment"
			              children = ArrayList (
			                YangLabel [
			                  trace = "synthetic:///__synthetic1.yang#//@substatements.9/@substatements.0/@substatements.1"
			                  text = "leafList[]: string"
			                  type = "ylabel:text"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-leafList"
			                  children = ArrayList ()
			                ],
			                YangLabel [
			                  trace = "synthetic:///__synthetic1.yang#//@substatements.9/@substatements.0/@substatements.2"
			                  text = "anotherLeaf: string"
			                  type = "ylabel:text"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-anotherLeaf"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-container-testcontainer"
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-container-testcontainer-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-groupingTest"
			          targetId = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill"
			          type = "edge:composition"
			          id = "mytest:myt-node-container-groupingTest2mytest:myt-node-container-groupingTest-uses anotherGroup-pill-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          cssClass = "uses"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.10/@substatements.0"
			          layout = "vbox"
			          type = "node:pill"
			          id = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill"
			          children = ArrayList (
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 10.0
			                paddingRight = 10.0
			                paddingTop = 0.0
			                paddingBottom = 0.0
			                paddingFactor = 1.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill-heading"
			              children = ArrayList (
			                SLabel [
			                  text = "uses anotherGroup"
			                  type = "label:heading"
			                  id = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill-heading-label"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-container-groupingTest"
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-container-groupingTest-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-externalGroupingTest"
			          targetId = "mytest:myt-node-container-externalGroupingTest-uses mytest2Group-pill"
			          type = "edge:composition"
			          id = "mytest:myt-node-container-externalGroupingTest2mytest:myt-node-container-externalGroupingTest-uses mytest2Group-pill-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          cssClass = "uses"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.11/@substatements.0"
			          layout = "vbox"
			          type = "node:pill"
			          id = "mytest:myt-node-container-externalGroupingTest-uses mytest2Group-pill"
			          children = ArrayList (
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 10.0
			                paddingRight = 10.0
			                paddingTop = 0.0
			                paddingBottom = 0.0
			                paddingFactor = 1.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-container-externalGroupingTest-uses mytest2Group-pill-heading"
			              children = ArrayList (
			                SLabel [
			                  text = "uses mytest2Group"
			                  type = "label:heading"
			                  id = "mytest:myt-node-container-externalGroupingTest-uses mytest2Group-pill-heading-label"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-container-externalGroupingTest"
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-container-externalGroupingTest-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          cssClass = "grouping"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.4"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-grouping-endpoint"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-grouping-endpoint-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-grouping-endpoint-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "G"
			                      type = "label:tag"
			                      id = "mytest:myt-node-grouping-endpoint-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "endpoint"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-grouping-endpoint-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-grouping-endpoint-compartment"
			              children = ArrayList (
			                YangLabel [
			                  trace = "synthetic:///__synthetic1.yang#//@substatements.4/@substatements.1"
			                  text = "ip: string"
			                  type = "ylabel:text"
			                  id = "mytest:myt-node-grouping-endpoint-ip"
			                  children = ArrayList ()
			                ],
			                YangLabel [
			                  trace = "synthetic:///__synthetic1.yang#//@substatements.4/@substatements.2"
			                  text = "port: string"
			                  type = "ylabel:text"
			                  id = "mytest:myt-node-grouping-endpoint-port"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        YangNode [
			          cssClass = "grouping"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.5"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-grouping-anotherGroup"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-grouping-anotherGroup-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-grouping-anotherGroup-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "G"
			                      type = "label:tag"
			                      id = "mytest:myt-node-grouping-anotherGroup-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "anotherGroup"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-grouping-anotherGroup-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-grouping-anotherGroup-compartment"
			              children = ArrayList (
			                YangLabel [
			                  trace = "synthetic:///__synthetic1.yang#//@substatements.5/@substatements.1"
			                  text = "anotherGroupLeaf: string"
			                  type = "ylabel:text"
			                  id = "mytest:myt-node-grouping-anotherGroup-anotherGroupLeaf"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        YangNode [
			          cssClass = "augment"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.6"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-/myt:testcontainer-augmentation"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-/myt:testcontainer-augmentation-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-/myt:testcontainer-augmentation-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "A"
			                      type = "label:tag"
			                      id = "mytest:myt-node-/myt:testcontainer-augmentation-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "/myt:testcontainer"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-/myt:testcontainer-augmentation-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-/myt:testcontainer-augmentation-compartment"
			              children = ArrayList (
			                YangLabel [
			                  trace = "synthetic:///__synthetic1.yang#//@substatements.6/@substatements.0"
			                  text = "augmentLeaf: string"
			                  type = "ylabel:text"
			                  id = "mytest:myt-node-/myt:testcontainer-augmentation-augmentLeaf"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        YangNode [
			          cssClass = "augment"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.7"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "A"
			                      type = "label:tag"
			                      id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "/myt:testcontainer/myt:innerTestContainer"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-compartment"
			              children = ArrayList ()
			            ]
			          )
			        ],
			        YangNode [
			          cssClass = "augment"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.8"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-/myt2:bla-augmentation"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-/myt2:bla-augmentation-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-/myt2:bla-augmentation-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "A"
			                      type = "label:tag"
			                      id = "mytest:myt-node-/myt2:bla-augmentation-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "/myt2:bla"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-/myt2:bla-augmentation-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-/myt2:bla-augmentation-compartment"
			              children = ArrayList (
			                YangLabel [
			                  trace = "synthetic:///__synthetic1.yang#//@substatements.8/@substatements.0"
			                  text = "blaLeaf: string"
			                  type = "ylabel:text"
			                  id = "mytest:myt-node-/myt2:bla-augmentation-blaLeaf"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        YangNode [
			          cssClass = "container"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.9"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-testcontainer"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-container-testcontainer-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-container-testcontainer-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "C"
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-testcontainer-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "testcontainer"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-container-testcontainer-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-container-testcontainer-compartment"
			              children = ArrayList (
			                YangLabel [
			                  trace = "synthetic:///__synthetic1.yang#//@substatements.9/@substatements.1"
			                  text = "testleaf: string"
			                  type = "ylabel:text"
			                  id = "mytest:myt-node-container-testcontainer-testleaf"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			        ],
			        YangNode [
			          cssClass = "container"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.10"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-groupingTest"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-container-groupingTest-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-container-groupingTest-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "C"
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-groupingTest-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "groupingTest"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-container-groupingTest-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-container-groupingTest-compartment"
			              children = ArrayList ()
			            ]
			          )
			        ],
			        YangNode [
			          cssClass = "container"
			          trace = "synthetic:///__synthetic1.yang#//@substatements.11"
			          layout = "vbox"
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-externalGroupingTest"
			          children = ArrayList (
			            YangHeaderNode [
			              layout = "hbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 8.0
			                paddingRight = 8.0
			                paddingTop = 8.0
			                paddingBottom = 8.0
			              ]
			              type = "comp:classHeader"
			              id = "mytest:myt-node-container-externalGroupingTest-header"
			              children = UnmodifiableRandomAccessList (
			                YangTag [
			                  layout = "stack"
			                  layoutOptions = LayoutOptions [
			                    paddingLeft = 0.0
			                    paddingRight = 0.0
			                    paddingTop = 0.0
			                    paddingBottom = 0.0
			                    resizeContainer = false
			                    vAlign = "center"
			                    hAlign = "center"
			                  ]
			                  type = "tag"
			                  id = "mytest:myt-node-container-externalGroupingTest-header-tag"
			                  children = UnmodifiableRandomAccessList (
			                    SLabel [
			                      text = "C"
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-externalGroupingTest-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "externalGroupingTest"
			                  type = "label:classHeader"
			                  id = "mytest:myt-node-container-externalGroupingTest-header-header-label"
			                ]
			              )
			            ],
			            SCompartment [
			              layout = "vbox"
			              layoutOptions = LayoutOptions [
			                paddingLeft = 12.0
			                paddingRight = 12.0
			                paddingTop = 12.0
			                paddingBottom = 12.0
			                vGap = 2.0
			              ]
			              type = "comp:comp"
			              id = "mytest:myt-node-container-externalGroupingTest-compartment"
			              children = ArrayList ()
			            ]
			          )
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-/myt:testcontainer-augmentation"
			          targetId = "mytest:myt-node-container-testcontainer"
			          type = "edge:augments"
			          id = "mytest:myt-node-/myt:testcontainer-augmentation2mytest:myt-node-container-testcontainer-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation"
			          targetId = "mytest:myt-node-container-testcontainer-container-innerTestContainer"
			          type = "edge:augments"
			          id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation2mytest:myt-node-container-testcontainer-container-innerTestContainer-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill"
			          targetId = "mytest:myt-node-grouping-anotherGroup"
			          type = "edge:uses"
			          id = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill2mytest:myt-node-grouping-anotherGroup-edge"
			          children = ArrayList ()
			        ]
			      )
			    ],
			    SEdge [
			      sourceId = "mytest2:myt2"
			      targetId = "mytest:myt"
			      type = "edge:import"
			      id = "mytest2:myt22mytest:myt-edge"
			      children = ArrayList ()
			    ]
			  )
			]
		''')
	}
}
