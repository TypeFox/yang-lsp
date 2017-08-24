/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import com.google.inject.Inject
import io.typefox.sprotty.api.IDiagramState
import io.typefox.sprotty.api.LayoutOptions
import io.typefox.sprotty.api.SCompartment
import io.typefox.sprotty.api.SEdge
import io.typefox.sprotty.api.SGraph
import io.typefox.sprotty.api.SLabel
import io.typefox.sprotty.api.SModelElement
import io.typefox.sprotty.api.SModelRoot
import io.typefox.sprotty.api.SNode
import io.typefox.sprotty.server.xtext.IDiagramGenerator
import io.typefox.sprotty.server.xtext.tracing.ITraceProvider
import io.typefox.sprotty.server.xtext.tracing.Traceable
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Action
import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.Base
import io.typefox.yang.yang.Case
import io.typefox.yang.yang.Choice
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Grouping
import io.typefox.yang.yang.Identity
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Include
import io.typefox.yang.yang.Input
import io.typefox.yang.yang.Key
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.LeafList
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Notification
import io.typefox.yang.yang.Output
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Rpc
import io.typefox.yang.yang.SchemaNode
import io.typefox.yang.yang.SchemaNodeIdentifier
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Submodule
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import io.typefox.yang.yang.Uses
import io.typefox.yang.yang.impl.ActionImpl
import io.typefox.yang.yang.impl.AugmentImpl
import io.typefox.yang.yang.impl.CaseImpl
import io.typefox.yang.yang.impl.ChoiceImpl
import io.typefox.yang.yang.impl.ContainerImpl
import io.typefox.yang.yang.impl.GroupingImpl
import io.typefox.yang.yang.impl.IdentityImpl
import io.typefox.yang.yang.impl.InputImpl
import io.typefox.yang.yang.impl.ListImpl
import io.typefox.yang.yang.impl.ModuleImpl
import io.typefox.yang.yang.impl.NotificationImpl
import io.typefox.yang.yang.impl.OutputImpl
import io.typefox.yang.yang.impl.RpcImpl
import io.typefox.yang.yang.impl.SubmoduleImpl
import io.typefox.yang.yang.impl.TypedefImpl
import io.typefox.yang.yang.impl.UsesImpl
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.util.CancelIndicator
import io.typefox.sprotty.api.SButton

class YangDiagramGenerator implements IDiagramGenerator {
	static val LOG = Logger.getLogger(YangDiagramGenerator)

	static val COMPOSITION_EDGE_TYPE = 'composition'
	static val STRAIGHT_EDGE_TYPE = 'straight'
	static val DASHED_EDGE_TYPE = 'dashed'
	static val IMPORT_EDGE_TYPE = 'import'
	static val USES_EDGE_TYPE = 'uses'
	static val AUGMENTS_EDGE_TYPE = 'augments'

	var Map<Statement, SModelElement> elementIndex
	var List<()=>void> postProcesses

	var SGraph diagramRoot
	
	@Inject ITraceProvider traceProvider
	
	IDiagramState state
	
	AbstractModule diagramModule
	
	Map<String, YangNode> id2modules = newHashMap
	
	override generate(Resource resource, IDiagramState state, CancelIndicator cancelIndicator) {
		val content = resource.contents.head
		this.state = state
		if (content instanceof AbstractModule) {
			LOG.info("Generating diagram for input: '" + resource.URI.lastSegment + "'")
			return generateDiagram(content, cancelIndicator)
		}
		return null
	}

	def SModelRoot generateDiagram(AbstractModule module, CancelIndicator cancelIndicator) {
		diagramModule = module
		elementIndex = new HashMap
		postProcesses = new ArrayList
		diagramRoot = new SGraph => [
			type = 'graph'
			id = 'yang'
			children = new ArrayList<SModelElement>
			layoutOptions = new LayoutOptions [
				HAlign = 'left'
				HGap = 10.0
				VGap = 0.0
				paddingLeft = 0.0
				paddingRight = 0.0
				paddingTop = 0.0
				paddingBottom = 0.0
			]
		]

		val rootChildren = createChildElements(diagramRoot, diagramRoot, #[module])
		diagramRoot.children.addAll(rootChildren)		
		postProcessing()
		return diagramRoot
	}

	/**
	 * @param viewParentElement SModelElement
	 * @param modelParentElement SModelElement
	 * @param statements List<Statement>
	 */
	protected def List<SModelElement> createChildElements(SModelElement viewParentElement,
		SModelElement modelParentElement, List<Statement> statements) {
		val rootChildren = new ArrayList()
		for (statement : statements) {
			var SModelElement element = null
			element = generateElement(statement, viewParentElement, modelParentElement)
			if (element !== null) {
				val eid = element.id
				LOG.info("CREATED ELEMENT FOR statement:" + statement.toString + " WITH ID " + eid)
				if (elementIndex.filter[k, v|v.id == eid].size > 0) {
					LOG.info(eid + " ALREADY EXISTS!!!")
				}
				elementIndex.put(statement, element)
				if(!rootChildren.contains(element)) {
					rootChildren.add(element)
					element.trace(statement)
				}
			}
		}
		return rootChildren
	}
	
	protected def void trace(SModelElement element, Statement statement) {
		if (element instanceof Traceable) 
			traceProvider.trace(element, statement)
	}

	protected def dispatch SModelElement generateElement(Module moduleStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		return createModule(moduleStmt)
	}

	protected def dispatch SModelElement generateElement(Submodule submoduleStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		createModule(submoduleStmt)
	}

	protected def dispatch SModelElement generateElement(Container containerStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		return createClassElement(containerStmt, viewParentElement, modelParentElement, COMPOSITION_EDGE_TYPE)
	}

	protected def dispatch SModelElement generateElement(io.typefox.yang.yang.List listStmt,
		SModelElement viewParentElement, SModelElement modelParentElement) {
		return createClassElement(listStmt, viewParentElement, modelParentElement, COMPOSITION_EDGE_TYPE)
	}

	protected def dispatch SModelElement generateElement(Key keyStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		if (modelParentElement instanceof SCompartment) {
			val keyReferences = keyStmt.references
			postProcesses.add([
				(keyReferences).forEach [ keyReference |
					val leafElement = elementIndex.get(keyReference.node) as SLabel
					val label = leafElement.text
					leafElement.text = '* ' + label
				]
			])
		}
		return null
	}

	protected def dispatch SModelElement generateElement(Grouping groupingStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		createClassElement(groupingStmt, viewParentElement, modelParentElement, null)
	}

	protected def dispatch SModelElement generateElement(Typedef typedefStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		createClassElement(typedefStmt, viewParentElement, modelParentElement, null)
	}

	protected def dispatch SModelElement generateElement(Identity identityStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		val base = identityStmt.substatements.filter(Base).head
		if (base === null)
			return createClassElement(identityStmt, viewParentElement, modelParentElement, USES_EDGE_TYPE)
		else {
			postProcesses.add([
				val identityElement = createClassElement(identityStmt, viewParentElement, modelParentElement, null)
				modelParentElement.children.add(identityElement)
				identityElement.trace(identityStmt)
				val baseIdentityElement = elementIndex.get(base.reference)
				if (baseIdentityElement !== null)
					modelParentElement.children.add(
						createEdge(baseIdentityElement, identityElement, STRAIGHT_EDGE_TYPE))
			])
			return null
		}
	}

	protected def dispatch SModelElement generateElement(Augment augmentStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		if (modelParentElement instanceof SNode) {
			val SchemaNodeIdentifier schemaNodeIdentifier = augmentStmt.path
			val node = NodeModelUtils.getNode(schemaNodeIdentifier)
			val path = node.leafNodes.filter[!hidden].map[text].join
			val targetNode = schemaNodeIdentifier.schemaNode
			val augmentElementId = viewParentElement.id + '-' + targetNode.name + '-augmentation'
			var SModelElement augmentElement = null
			var sameAugmentTarget = elementIndex.values.findFirst [ element |
				element.id == augmentElementId
			]
			if (sameAugmentTarget !== null) {
				val sameAugmentTargetCompartment = sameAugmentTarget.children.findFirst [ element |
					element.type == 'comp:comp'
				]
				sameAugmentTargetCompartment.children.addAll(
					createChildElements(sameAugmentTarget, sameAugmentTargetCompartment, augmentStmt.substatements))
			} else {
				augmentElement = createClassElement(augmentStmt, path, augmentElementId, viewParentElement,
					modelParentElement, COMPOSITION_EDGE_TYPE, findClass(augmentStmt))
				postProcesses.add([
					val targetElement = elementIndex.get(targetNode)
					val a = elementIndex.get(augmentStmt)
					if (targetElement !== null) {
						modelParentElement.children.add(createEdge(a, targetElement, AUGMENTS_EDGE_TYPE))
					}
				])
			}
			return augmentElement
		}
	}

	protected def dispatch SModelElement generateElement(Choice choiceStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		if (modelParentElement instanceof SNode) {
			val choiceNode = createNodeWithHeadingLabel(viewParentElement.id, choiceStmt.name, 'choice')
			val SEdge toChoiceEdge = createEdge(viewParentElement, choiceNode, DASHED_EDGE_TYPE)
			modelParentElement.children.add(toChoiceEdge)
			if (choiceNode !== null) {
				choiceStmt.substatements.forEach([
					if (!(it instanceof Case)) {
						if (it instanceof SchemaNode) {
							val caseElement = createNodeWithHeadingLabel(choiceNode.id + "-" + it.name + "-case",
								it.name, 'case')
							val caseCompartment = createClassMemberCompartment(caseElement.id)
							caseElement.children.add(caseCompartment)
							modelParentElement.children.add(caseElement)
							val toCaseEdge = createEdge(choiceNode, caseElement, DASHED_EDGE_TYPE)
							modelParentElement.children.add(toCaseEdge)

							caseCompartment.children.addAll(createChildElements(caseElement, caseCompartment, #[it]))

							modelParentElement.children.addAll(
								createChildElements(caseElement, modelParentElement, #[it]))
						}
					} else {
						val caseNode = createTypedElementWithEdge(modelParentElement, choiceNode, (it as SchemaNode), 'case',
														DASHED_EDGE_TYPE)
						modelParentElement.children.add(caseNode)
						caseNode.trace(it)
					}
				])
				choiceNode.layoutOptions = new LayoutOptions [
					HAlign = 'center'
					paddingLeft = 5.0
					paddingRight = 5.0
					paddingTop = 5.0
					paddingBottom = 5.0
					paddingFactor = 2.0
				]
				return choiceNode
			}
		}
	}

	protected def dispatch SModelElement generateElement(Case caseStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		val caseNode = createTypedElementWithEdge(modelParentElement, viewParentElement, caseStmt, 'case',
			DASHED_EDGE_TYPE)
		if (caseNode !== null) {
			caseNode.layoutOptions = new LayoutOptions [
				HAlign = 'center'
				paddingBottom = 10.0
				paddingTop = 10.0
				paddingLeft = 8.0
				paddingRight = 8.0
			]
			caseNode.trace(caseStmt)
		}
		return caseNode
	}

	protected def dispatch SModelElement generateElement(Uses usesStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		if (modelParentElement instanceof SNode) {
			val usesElement = createNodeWithHeadingLabel(viewParentElement.id, 'uses ' + usesStmt.grouping.node.name,
				'pill')
			usesElement.cssClass = findClass(usesStmt)
			modelParentElement.children.addAll(
				createChildElements(usesElement, modelParentElement, usesStmt.substatements))

			val SEdge edge = createEdge(viewParentElement, usesElement, COMPOSITION_EDGE_TYPE)
			modelParentElement.children.add(edge)

			postProcesses.add([
				val groupingElement = elementIndex.get(usesStmt.grouping.node)
				val ue = usesElement
				// is there a grouping element in this module? If not its usage relates to an external module grouping
				if (groupingElement !== null)
					modelParentElement.children.add(createEdge(ue, groupingElement, USES_EDGE_TYPE))
			])
			return usesElement
		}
	}

	protected def dispatch SModelElement generateElement(Rpc rpcStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		if (modelParentElement instanceof SNode) {
			val rpcElement = createNodeWithHeadingLabel(viewParentElement.id, 'rpc ' + rpcStmt.name, 'pill')
			rpcElement.cssClass = findClass(rpcStmt)
			modelParentElement.children.addAll(
				createChildElements(rpcElement, modelParentElement, rpcStmt.substatements))

			val SEdge edge = createEdge(viewParentElement, rpcElement, STRAIGHT_EDGE_TYPE)
			modelParentElement.children.add(edge)

			return rpcElement
		}
	}

	protected def dispatch SModelElement generateElement(Action actionStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		if (modelParentElement instanceof SNode) {
			val actionElement = createNodeWithHeadingLabel(viewParentElement.id, 'action ' + actionStmt.name, 'pill')
			actionElement.cssClass = findClass(actionStmt)
			modelParentElement.children.addAll(
				createChildElements(actionElement, modelParentElement, actionStmt.substatements))

			val SEdge edge = createEdge(viewParentElement, actionElement, STRAIGHT_EDGE_TYPE)
			modelParentElement.children.add(edge)

			return actionElement
		}
	}

	protected def dispatch SModelElement generateElement(Input inputStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		var id = viewParentElement.id + "-input"
		var n = 1
		while(elementIndex.get(id) !== null){
		    n++
		    id += '-'+n
		}
		return createClassElement(inputStmt, '', id, viewParentElement, modelParentElement, STRAIGHT_EDGE_TYPE, findClass(inputStmt) )
	}

	protected def dispatch SModelElement generateElement(Output outputStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		var id = viewParentElement.id + "-output"
		var n = 1
		while(elementIndex.get(id) !== null){
		    n++
		    id += '-'+n
		}
		return createClassElement(outputStmt, '', id, viewParentElement, modelParentElement, STRAIGHT_EDGE_TYPE, findClass(outputStmt) )
	}

	protected def dispatch SModelElement generateElement(Notification notificationStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		return createClassElement(notificationStmt, viewParentElement, modelParentElement, STRAIGHT_EDGE_TYPE)
	}

	protected def dispatch SModelElement generateElement(Import importStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		val moduleElement = createModule(importStmt.module)
		if(!diagramRoot.children.contains(moduleElement)) {
			diagramRoot.children.add(moduleElement)
			moduleElement.trace(importStmt.module)
		}
		postProcesses.add([
			diagramRoot.children.add(createEdge(moduleElement, modelParentElement, IMPORT_EDGE_TYPE))
		])
		return null
	}

	protected def dispatch SModelElement generateElement(Include includeStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		if(!(includeStmt.eContainer instanceof Submodule)) 
			createModule(includeStmt.module)
	}

	protected def dispatch SModelElement generateElement(Leaf leafStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		createClassMemberElement(leafStmt, viewParentElement, modelParentElement)
	}

	protected def dispatch SModelElement generateElement(LeafList leafListStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		createClassMemberElement(leafListStmt, viewParentElement, modelParentElement)
	}

	protected def dispatch SModelElement generateElement(EObject node, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		return null
	}

	protected def SNode initModule(YangNode moduleElement, AbstractModule moduleStmt) {
		if ((state.currentModel.type == 'NONE' && moduleStmt == diagramModule) 
			|| state.expandedElements.contains(moduleElement.id)) {
			// Module node
			val moduleNode = configSElement(YangNode, moduleElement.id + '-node', 'class')
			moduleNode.layout = 'vbox'
			moduleNode.layoutOptions = new LayoutOptions [
				paddingLeft = 0.0
				paddingRight = 0.0
				paddingTop = 0.0
				paddingBottom = 0.0
			]
			moduleNode.cssClass = 'moduleNode'
	
			moduleNode.children.add(createClassHeader(moduleNode.id, findTag(moduleStmt), moduleStmt.name))
	
			moduleElement.children.add(moduleNode)
			moduleElement.children.addAll(createChildElements(moduleNode, moduleElement, moduleStmt.substatements))
			moduleElement.expanded = true		
			state.expandedElements.add(moduleElement.id)	
		} else {
			moduleElement.expanded = false
		}
		return moduleElement
	}

	protected def <E extends SModelElement> E configSElement(Class<E> elementClass, String idStr, String typeStr) {
		elementClass.constructor.newInstance => [
			id = idStr
			type = findType(it) + ':' + typeStr
			children = new ArrayList<SModelElement>
		]
	}

	protected def YangHeaderNode createClassHeader(String id, String tag, String name) {
		val classHeader = configSElement(YangHeaderNode, id + '-header', 'classHeader')
		classHeader.layout = 'hbox'
		classHeader.layoutOptions = new LayoutOptions [
			paddingLeft = 8.0
			paddingRight = 8.0
			paddingTop = 8.0
			paddingBottom = 8.0
		]
		classHeader.children = #[
			new SLabel [ l |
				l.type = "label:classTag"
				l.id = classHeader.id + '-tag'
				l.text = tag
			],
			new SLabel [ l |
				l.type = "label:classHeader"
				l.id = classHeader.id + '-header-label'
				l.text = name
			]
		]
		return classHeader
	}

	protected def createModule(AbstractModule moduleStmt) {
		val prefix = moduleStmt.substatements.filter(Prefix).head
		val id = moduleStmt.name + if(prefix !== null) ':' + prefix.prefix else ''
		val existingModule = id2modules.get(id)
		if(existingModule !== null)
			return existingModule
		val moduleElement = createModule(id)
		id2modules.put(id, moduleElement)
		initModule(moduleElement, moduleStmt)
		return moduleElement
	}

	protected def YangNode createModule(String name) {
		val moduleElement = configSElement(YangNode, name, 'module')
		moduleElement.layout = 'vbox'
		moduleElement.layoutOptions = new LayoutOptions [
			paddingTop = 5.0
			paddingBottom = 5.0
			paddingLeft = 5.0
			paddingRight = 5.0
		]

		val SCompartment moduleHeadingCompartment = configSElement(SCompartment, moduleElement.id + '-heading', 'comp')
		moduleHeadingCompartment.layout = 'hbox'
		moduleElement.children.add(moduleHeadingCompartment)
		val SLabel moduleLabel = configSElement(SLabel, moduleElement.id + '-label', 'heading')
		moduleLabel.text = name
		moduleHeadingCompartment.children.add(moduleLabel)
		val expandButton = configSElement(SButton, moduleElement.id + '-expand', 'expand')
		moduleHeadingCompartment.children.add(expandButton) 
		return moduleElement
	}

	protected def SModelElement createClassMemberElement(SchemaNode statement, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		if (modelParentElement instanceof SCompartment) {
			val YangLabel memberElement = configSElement(YangLabel, viewParentElement.id + '-' + statement.name, 'text')
			val Type type = statement.substatements.filter(Type).head
			val String nameAddition = if(statement instanceof LeafList) '[]' else ''
			memberElement.text = statement.name + nameAddition + ': ' + type.typeRef.builtin
			memberElement.trace(statement)
			return memberElement
		}
	}

	protected def SModelElement createClassElement(SchemaNode statement, SModelElement viewParentElement,
		SModelElement modelParentElement, String edgeType) {
		val cssClass = findClass(statement)
		createClassElement(statement, statement.name, viewParentElement.id + '-' + cssClass + '-' + statement.name,
			viewParentElement, modelParentElement, edgeType, cssClass)
	}

	protected def SModelElement createClassElement(Statement statement, String label, String id,
		SModelElement viewParentElement, SModelElement modelParentElement, String edgeType, String cssClass) {
		if (modelParentElement instanceof SNode) {
			val classElement = configSElement(YangNode, id, 'class')
			classElement.layout = 'vbox'
			classElement.layoutOptions = new LayoutOptions [
				paddingLeft = 0.0
				paddingRight = 0.0
				paddingTop = 0.0
				paddingBottom = 0.0
			]
			classElement.cssClass = cssClass

			classElement.children.add(createClassHeader(classElement.id, findTag(statement), label))

			// add class members to compartment element
			val compartment = configSElement(SCompartment, classElement.id + '-compartment', 'comp')
			compartment.layout = 'vbox'
			compartment.layoutOptions = new LayoutOptions [
				paddingLeft = 12.0
				paddingRight = 12.0
				paddingTop = 12.0
				paddingBottom = 12.0
				VGap = 2.0
			]

			compartment.children.addAll(createChildElements(classElement, compartment, statement.substatements))
			classElement.children.add(compartment)

			// add composition elements 
			modelParentElement.children.addAll(
				createChildElements(classElement, modelParentElement, statement.substatements))

			if (edgeType !== null) {
				val SEdge compositionEdge = configSElement(SEdge,
					viewParentElement.id + '2' + classElement.id + '-edge', edgeType)
				compositionEdge.sourceId = viewParentElement.id
				compositionEdge.targetId = classElement.id
				modelParentElement.children.add(compositionEdge)
			}

			return classElement
		}
	}

	protected def SNode createTypedElementWithEdge(SModelElement modelParentElement, SModelElement viewParentElement,
		SchemaNode stmt, String type, String edgeType) {
		if (modelParentElement instanceof SNode) {

			val name = stmt.name

			val classElement = createNodeWithHeadingLabel(viewParentElement.id, name, type)

			// add class members to compartment element
			val compartment = createClassMemberCompartment(classElement.id)
			compartment.children.addAll(createChildElements(classElement, compartment, stmt.substatements))
			classElement.children.add(compartment)

			modelParentElement.children.addAll(
				createChildElements(classElement, modelParentElement, stmt.substatements))

			val SEdge edge = createEdge(viewParentElement, classElement, edgeType)
			modelParentElement.children.add(edge)

			return classElement
		}
	}

	protected def SCompartment createClassMemberCompartment(String id) {
		val compartment = configSElement(SCompartment, id + '-compartment', 'comp')
		compartment.layout = 'vbox'
		compartment.layoutOptions = new LayoutOptions [
			paddingFactor = 1.0
			paddingLeft = 0.0
			paddingRight = 0.0
			paddingTop = 0.0
			paddingBottom = 0.0
		]
		return compartment
	}

	protected def YangNode createNodeWithHeadingLabel(String id, String name, String type) {
		val classElement = configSElement(YangNode, id + '-' + name + '-' + type, type)
		classElement.layout = 'vbox'

		val headingContainer = configSElement(SCompartment, classElement.id + '-heading', 'comp')
		headingContainer.layout = 'vbox'
		headingContainer.layoutOptions = new LayoutOptions [
			paddingFactor = 1.0
			paddingLeft = 10.0
			paddingRight = 10.0
			paddingTop = 0.0
			paddingBottom = 0.0
		]

		val heading = configSElement(SLabel, headingContainer.id + '-label', 'heading')
		heading.text = name
		headingContainer.children.add(heading)
		classElement.children.add(headingContainer)
		return classElement
	}

	protected def SEdge createEdge(SModelElement fromElement, SModelElement toElement, String edgeType) {
		val SEdge edge = configSElement(SEdge, fromElement.id + '2' + toElement.id + '-edge', edgeType)
		edge.sourceId = fromElement.id
		edge.targetId = toElement.id
		return edge
	}

	protected def String findClass(Statement statement) {
		switch statement {
			TypedefImpl: 'typedef'
			ChoiceImpl: 'choice'
			CaseImpl: 'case'
			UsesImpl: 'uses'
			AugmentImpl: 'augment'
			ListImpl: 'list'
			ContainerImpl: 'container'
			ModuleImpl: 'module'
			SubmoduleImpl: 'submodule'
			GroupingImpl: 'grouping'
			IdentityImpl: 'identity'
			RpcImpl: 'rpc'
			InputImpl: 'input'
			OutputImpl: 'output'
			NotificationImpl: 'notification'
			ActionImpl: 'action'
			default: ''
		}
	}

	protected def String findTag(Statement statement) {
		switch statement {
			AugmentImpl: 'A'
			ListImpl: 'L'
			ContainerImpl: 'C'
			ModuleImpl: 'M'
			SubmoduleImpl: 'S'
			GroupingImpl: 'G'
			TypedefImpl: 'T'
			IdentityImpl: 'I'
			UsesImpl: 'U'
			NotificationImpl: 'N'
			InputImpl: 'in'
			OutputImpl: 'out'
			default: ''
		}
	}

	protected def String findType(SModelElement element) {
		switch element {
			SNode: 'node'
			YangLabel: 'ylabel'
			SLabel: 'label'
			SCompartment: 'comp'
			SEdge: 'edge'
			SButton: 'button'
			default: 'dontknow'
		}
	}

	protected def void postProcessing() {
		postProcesses.forEach[process|process.apply]
	}

}
