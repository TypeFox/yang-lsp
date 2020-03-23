/*
 * Copyright (C) 2017-2020 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram.test

import com.google.inject.Inject
import io.typefox.yang.diagram.YangDiagramGenerator
import io.typefox.yang.tests.AbstractYangTest
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.sprotty.util.IdCache
import org.eclipse.sprotty.xtext.IDiagramGenerator
import org.eclipse.sprotty.xtext.ls.IssueProvider
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.util.CancelIndicator
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(YangDiagramInjectorProvider)
class DiagramGeneratorTest extends AbstractYangTest {
	
	@Inject YangDiagramGenerator generator
	
	protected def assertGeneratedTo(Resource resource, CharSequence target) {
		val context = new IDiagramGenerator.Context(resource, new TestDiagramState(resource),
				new IdCache, new IssueProvider(emptyList), CancelIndicator.NullImpl)
		val diagram = generator.generate(context)
		Assert.assertEquals(target.toString.replace('\r','').trim, diagram.toString)
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
			      layout = "vbox"
			      selected = false
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
			              selected = false
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
			      trace = "synthetic:///__synthetic0.yang?0:0-19:1#/"
			    ],
			    YangNode [
			      expanded = true
			      layout = "vbox"
			      selected = false
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
			              selected = false
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
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node"
			          cssClasses = UnmodifiableRandomAccessList (
			            "moduleNode"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "mytest"
			                  selected = false
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
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-/myt:testcontainer-augmentation-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation"
			          targetId = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-uses mytest2Group-pill"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation2mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-uses mytest2Group-pill-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          type = "node:pill"
			          id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-uses mytest2Group-pill"
			          cssClasses = UnmodifiableRandomAccessList (
			            "uses"
			          )
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
			                  selected = false
			                  type = "label:heading"
			                  id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-uses mytest2Group-pill-heading-label"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?33:9-33:32#//@substatements.7/@substatements.0"
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-/myt2:bla-augmentation"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-/myt2:bla-augmentation-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList"
			          targetId = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList2mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer"
			          cssClasses = UnmodifiableRandomAccessList (
			            "container"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "listContainer"
			                  selected = false
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
			                SLabel [
			                  text = "meAlone: string"
			                  selected = false
			                  type = "label:text"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-container-listContainer-meAlone"
			                  children = ArrayList ()
			                  trace = "synthetic:///__synthetic1.yang?47:20-49:21#//@substatements.9/@substatements.0/@substatements.0/@substatements.1/@substatements.0"
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?46:16-50:17#//@substatements.9/@substatements.0/@substatements.0/@substatements.1"
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-testcontainer-container-innerTestContainer"
			          targetId = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node-container-testcontainer-container-innerTestContainer2mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList"
			          cssClasses = UnmodifiableRandomAccessList (
			            "list"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "innerTestList"
			                  selected = false
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
			                SLabel [
			                  text = "* keyLeaf: string"
			                  selected = false
			                  type = "label:text"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-list-innerTestList-keyLeaf"
			                  children = ArrayList ()
			                  trace = "synthetic:///__synthetic1.yang?51:16-53:17#//@substatements.9/@substatements.0/@substatements.0/@substatements.2"
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?44:12-54:13#//@substatements.9/@substatements.0/@substatements.0"
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-testcontainer"
			          targetId = "mytest:myt-node-container-testcontainer-container-innerTestContainer"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node-container-testcontainer2mytest:myt-node-container-testcontainer-container-innerTestContainer-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-testcontainer-container-innerTestContainer"
			          cssClasses = UnmodifiableRandomAccessList (
			            "container"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "innerTestContainer"
			                  selected = false
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
			                SLabel [
			                  text = "leafList[]: string"
			                  selected = false
			                  type = "label:text"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-leafList"
			                  children = ArrayList ()
			                  trace = "synthetic:///__synthetic1.yang?55:12-57:13#//@substatements.9/@substatements.0/@substatements.1"
			                ],
			                SLabel [
			                  text = "anotherLeaf: string"
			                  selected = false
			                  type = "label:text"
			                  id = "mytest:myt-node-container-testcontainer-container-innerTestContainer-anotherLeaf"
			                  children = ArrayList ()
			                  trace = "synthetic:///__synthetic1.yang?58:12-60:13#//@substatements.9/@substatements.0/@substatements.2"
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?43:8-61:9#//@substatements.9/@substatements.0"
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-container-testcontainer"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-container-testcontainer-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-groupingTest"
			          targetId = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node-container-groupingTest2mytest:myt-node-container-groupingTest-uses anotherGroup-pill-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          type = "node:pill"
			          id = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill"
			          cssClasses = UnmodifiableRandomAccessList (
			            "uses"
			          )
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
			                  selected = false
			                  type = "label:heading"
			                  id = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill-heading-label"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?69:8-69:26#//@substatements.10/@substatements.0"
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-container-groupingTest"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-container-groupingTest-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-externalGroupingTest"
			          targetId = "mytest:myt-node-container-externalGroupingTest-uses mytest2Group-pill"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node-container-externalGroupingTest2mytest:myt-node-container-externalGroupingTest-uses mytest2Group-pill-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          type = "node:pill"
			          id = "mytest:myt-node-container-externalGroupingTest-uses mytest2Group-pill"
			          cssClasses = UnmodifiableRandomAccessList (
			            "uses"
			          )
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
			                  selected = false
			                  type = "label:heading"
			                  id = "mytest:myt-node-container-externalGroupingTest-uses mytest2Group-pill-heading-label"
			                  children = ArrayList ()
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?73:8-73:31#//@substatements.11/@substatements.0"
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node"
			          targetId = "mytest:myt-node-container-externalGroupingTest"
			          selected = false
			          type = "edge:composition"
			          id = "mytest:myt-node2mytest:myt-node-container-externalGroupingTest-edge"
			          children = ArrayList ()
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-grouping-endpoint"
			          cssClasses = UnmodifiableRandomAccessList (
			            "grouping"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-grouping-endpoint-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "endpoint"
			                  selected = false
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
			                SLabel [
			                  text = "ip: string"
			                  selected = false
			                  type = "label:text"
			                  id = "mytest:myt-node-grouping-endpoint-ip"
			                  children = ArrayList ()
			                  trace = "synthetic:///__synthetic1.yang?11:7-13:8#//@substatements.4/@substatements.1"
			                ],
			                SLabel [
			                  text = "port: string"
			                  selected = false
			                  type = "label:text"
			                  id = "mytest:myt-node-grouping-endpoint-port"
			                  children = ArrayList ()
			                  trace = "synthetic:///__synthetic1.yang?14:7-16:8#//@substatements.4/@substatements.2"
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?9:4-17:6#//@substatements.4"
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-grouping-anotherGroup"
			          cssClasses = UnmodifiableRandomAccessList (
			            "grouping"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-grouping-anotherGroup-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "anotherGroup"
			                  selected = false
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
			                SLabel [
			                  text = "anotherGroupLeaf: string"
			                  selected = false
			                  type = "label:text"
			                  id = "mytest:myt-node-grouping-anotherGroup-anotherGroupLeaf"
			                  children = ArrayList ()
			                  trace = "synthetic:///__synthetic1.yang?21:9-23:10#//@substatements.5/@substatements.1"
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?19:5-24:6#//@substatements.5"
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-/myt:testcontainer-augmentation"
			          cssClasses = UnmodifiableRandomAccessList (
			            "augment"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-/myt:testcontainer-augmentation-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "/myt:testcontainer"
			                  selected = false
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
			                SLabel [
			                  text = "augmentLeaf: string"
			                  selected = false
			                  type = "label:text"
			                  id = "mytest:myt-node-/myt:testcontainer-augmentation-augmentLeaf"
			                  children = ArrayList ()
			                  trace = "synthetic:///__synthetic1.yang?27:9-29:10#//@substatements.6/@substatements.0"
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?26:5-30:6#//@substatements.6"
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation"
			          cssClasses = UnmodifiableRandomAccessList (
			            "augment"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "/myt:testcontainer/myt:innerTestContainer"
			                  selected = false
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
			          trace = "synthetic:///__synthetic1.yang?32:5-34:6#//@substatements.7"
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-/myt2:bla-augmentation"
			          cssClasses = UnmodifiableRandomAccessList (
			            "augment"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-/myt2:bla-augmentation-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "/myt2:bla"
			                  selected = false
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
			                SLabel [
			                  text = "blaLeaf: string"
			                  selected = false
			                  type = "label:text"
			                  id = "mytest:myt-node-/myt2:bla-augmentation-blaLeaf"
			                  children = ArrayList ()
			                  trace = "synthetic:///__synthetic1.yang?37:9-39:10#//@substatements.8/@substatements.0"
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?36:5-40:6#//@substatements.8"
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-testcontainer"
			          cssClasses = UnmodifiableRandomAccessList (
			            "container"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-testcontainer-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "testcontainer"
			                  selected = false
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
			                SLabel [
			                  text = "testleaf: string"
			                  selected = false
			                  type = "label:text"
			                  id = "mytest:myt-node-container-testcontainer-testleaf"
			                  children = ArrayList ()
			                  trace = "synthetic:///__synthetic1.yang?62:8-65:9#//@substatements.9/@substatements.1"
			                ]
			              )
			            ]
			          )
			          trace = "synthetic:///__synthetic1.yang?42:5-66:5#//@substatements.9"
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-groupingTest"
			          cssClasses = UnmodifiableRandomAccessList (
			            "container"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-groupingTest-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "groupingTest"
			                  selected = false
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
			          trace = "synthetic:///__synthetic1.yang?68:4-70:5#//@substatements.10"
			        ],
			        YangNode [
			          layout = "vbox"
			          selected = false
			          layoutOptions = LayoutOptions [
			            paddingLeft = 0.0
			            paddingRight = 0.0
			            paddingTop = 0.0
			            paddingBottom = 0.0
			          ]
			          type = "node:class"
			          id = "mytest:myt-node-container-externalGroupingTest"
			          cssClasses = UnmodifiableRandomAccessList (
			            "container"
			          )
			          children = ArrayList (
			            SCompartment [
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
			                      selected = false
			                      type = "label:tag"
			                      id = "mytest:myt-node-container-externalGroupingTest-header-tag-text"
			                    ]
			                  )
			                ],
			                SLabel [
			                  text = "externalGroupingTest"
			                  selected = false
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
			          trace = "synthetic:///__synthetic1.yang?72:4-74:5#//@substatements.11"
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-/myt:testcontainer-augmentation"
			          targetId = "mytest:myt-node-container-testcontainer"
			          selected = false
			          type = "edge:augments"
			          id = "mytest:myt-node-/myt:testcontainer-augmentation2mytest:myt-node-container-testcontainer-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation"
			          targetId = "mytest:myt-node-container-testcontainer-container-innerTestContainer"
			          selected = false
			          type = "edge:augments"
			          id = "mytest:myt-node-/myt:testcontainer/myt:innerTestContainer-augmentation2mytest:myt-node-container-testcontainer-container-innerTestContainer-edge"
			          children = ArrayList ()
			        ],
			        SEdge [
			          sourceId = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill"
			          targetId = "mytest:myt-node-grouping-anotherGroup"
			          selected = false
			          type = "edge:uses"
			          id = "mytest:myt-node-container-groupingTest-uses anotherGroup-pill2mytest:myt-node-grouping-anotherGroup-edge"
			          children = ArrayList ()
			        ]
			      )
			      trace = "synthetic:///__synthetic1.yang?0:0-75:1#/"
			    ],
			    SEdge [
			      sourceId = "mytest2:myt2"
			      targetId = "mytest:myt"
			      selected = false
			      type = "edge:import"
			      id = "mytest2:myt22mytest:myt-edge"
			      children = ArrayList ()
			    ]
			  )
			]
		''')
	}
}
