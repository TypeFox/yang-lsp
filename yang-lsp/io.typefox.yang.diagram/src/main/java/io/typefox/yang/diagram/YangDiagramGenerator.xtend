/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import io.typefox.sprotty.api.Point
import io.typefox.sprotty.api.SCompartment
import io.typefox.sprotty.api.SEdge
import io.typefox.sprotty.api.SGraph
import io.typefox.sprotty.api.SLabel
import io.typefox.sprotty.api.SModelElement
import io.typefox.sprotty.api.SModelRoot
import io.typefox.sprotty.api.SNode
import io.typefox.sprotty.server.xtext.IDiagramGenerator
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Action
import io.typefox.yang.yang.Anyxml
import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.Case
import io.typefox.yang.yang.Choice
import io.typefox.yang.yang.Config
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Grouping
import io.typefox.yang.yang.IfFeature
import io.typefox.yang.yang.Key
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.LeafList
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Must
import io.typefox.yang.yang.Namespace
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Presence
import io.typefox.yang.yang.SchemaNode
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Status
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Uses
import io.typefox.yang.yang.When
import io.typefox.yang.yang.YangVersion
import io.typefox.yang.yang.impl.ContainerImpl
import io.typefox.yang.yang.impl.GroupingImpl
import io.typefox.yang.yang.impl.ListImpl
import io.typefox.yang.yang.impl.ModuleImpl
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.util.CancelIndicator
import io.typefox.yang.yang.Import
import org.eclipse.emf.ecore.EObject

class YangDiagramGenerator implements IDiagramGenerator {

	// Map -> [{Statement-name: [{statement:model-element}...]}...]
	val Map<String, Map<Statement, SModelElement>> elementIndex = new HashMap
	val Map<Statement, ()=>void> postProcesses = new HashMap

	var SGraph diagramRoot

	override generate(Resource resource, CancelIndicator cancelIndicator) {
		val content = resource.contents.head
		if (content instanceof AbstractModule) {
			generateDiagram(content, cancelIndicator)
		}
	}

	def SModelRoot generateDiagram(AbstractModule module, CancelIndicator cancelIndicator) {
		diagramRoot = new SGraph => [
			type = 'graph'
			id = 'yang'
			children = new ArrayList<SModelElement>
		]

		val rootChildren = createChildElements(diagramRoot, diagramRoot, #[module])
		if (rootChildren.length > 0) {
			diagramRoot.children.addAll(rootChildren)
			postProcessing()
		}
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
		var int num = 0
		for (statement : statements) {
			num++
			var SModelElement element = null
			element = generateElement(statement, viewParentElement, modelParentElement)
			if (element !== null) {
				val statementClassName = statement.class.simpleName
				if (elementIndex.get(statementClassName) === null)
					elementIndex.put(statementClassName, new HashMap)
				elementIndex.get(statementClassName).put(statement, element)
				rootChildren.add(element)
			}
		}
		return rootChildren
	}

	protected def dispatch SModelElement generateElement(Module moduleStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		val prefix = moduleStmt.substatements.filter(Prefix).head
		val moduleElement = createModule(moduleStmt.name, prefix.prefix)

		// Module note
		val SNode moduleNotes = configSElement(SNode, moduleElement.id + '-note', 'note')
		moduleElement.children.add(moduleNotes)

		// Module node
		val SNode moduleNode = configSElement(SNode, moduleElement.id + '-node', 'class')
		moduleNode.layout = 'vbox'

		// Module node label
		val SLabel moduleNodeLabel = configSElement(SLabel, moduleNode.id + '-label', 'heading')
		// TODO instead of [M] there should be a model for rendering an element with another background color... 
		moduleNodeLabel.text = '[M] ' + moduleStmt.name
		moduleNode.children.add(moduleNodeLabel)

		moduleElement.children.add(moduleNode)
		moduleElement.children.addAll(createChildElements(moduleNode, moduleElement, moduleStmt.substatements))

		return moduleElement
	}

	protected def dispatch SModelElement generateElement(Container containerStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		return createClassElement(containerStmt, viewParentElement, modelParentElement)
	}

	protected def dispatch SModelElement generateElement(io.typefox.yang.yang.List listStmt,
		SModelElement viewParentElement, SModelElement modelParentElement) {
		return createClassElement(listStmt, viewParentElement, modelParentElement)
	}

	protected def dispatch SModelElement generateElement(Key keyStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		postProcesses.put(keyStmt, [
// TODO: iterate over keyStmt.references, get the leaf statements, get the related leaf elements and extend the text
		])

		null
	}

	protected def dispatch SModelElement generateElement(Grouping groupingStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		createClassElement(groupingStmt, viewParentElement, modelParentElement)
	}

	protected def dispatch SModelElement generateElement(Augment augmentStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Choice choiceStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Case caseStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Uses usesStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {

		postProcesses.put(usesStmt, [
			val groupings = elementIndex.get('GroupingImpl')
			val groupingElement = if(groupings !== null) groupings.get(usesStmt.grouping.node)
			// is there a grouping element in this module? If not it is usage relates to an external module grouping
			if (groupingElement !== null)
				modelParentElement.children.add(createEdge(viewParentElement, groupingElement, 'uses'))
		])

		if (modelParentElement instanceof SCompartment) {
			val SLabel memberElement = configSElement(SLabel,
				viewParentElement.id + '-uses-' + usesStmt.grouping.node.name, 'text')
			memberElement.text = 'uses ' + usesStmt.grouping.node.name
			return memberElement
		}
	}

	protected def dispatch SModelElement generateElement(Import importStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		val prefix = importStmt.substatements.filter(Prefix).head
		val module = createModule(importStmt.module.name, prefix.prefix)
		diagramRoot.children.add(module)

		postProcesses.put(importStmt, [
			modelParentElement.children.add(createEdge(module, viewParentElement, 'import'))
		])

		return null
	}

	protected def dispatch SModelElement generateElement(Description descriptionStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Config configStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Must mustStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Presence presenceStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(When whenStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Status statusStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(IfFeature ifFeatureStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Leaf leafStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		createClassMemberElement(leafStmt, viewParentElement, modelParentElement)
	}

	protected def dispatch SModelElement generateElement(LeafList leafListStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		createClassMemberElement(leafListStmt, viewParentElement, modelParentElement)
	}

	protected def dispatch SModelElement generateElement(Action actionStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Anyxml anyxmlStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Namespace namespaceStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(Prefix prefixStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def dispatch SModelElement generateElement(YangVersion yangVersionStmt, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}
	
	protected def dispatch SModelElement generateElement(EObject node, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		// TODO
	}

	protected def <E extends SModelElement> E configSElement(Class<E> elementClass, String idStr, String typeStr) {
		elementClass.constructor.newInstance => [
			id = idStr
			type = findType(it) + ':' + typeStr
			children = new ArrayList<SModelElement>
		]
	}

	protected def SNode createModule(String name, String prefix) {
		// Module
		val moduleElement = configSElement(SNode, name, 'module')

		// Module label
		val SLabel moduleLabel = configSElement(SLabel, moduleElement.id + '-label', 'heading')
		moduleLabel.position = new Point => [
			x = 5
			y = 5
		]
		moduleLabel.text = prefix + ':' + name
		moduleElement.children.add(moduleLabel)
		return moduleElement
	}

	protected def SModelElement createClassMemberElement(SchemaNode statement, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		if (modelParentElement instanceof SCompartment) {
			val SLabel memberElement = configSElement(SLabel, viewParentElement.id + '-' + statement.name, 'text')
			val Type type = statement.substatements.filter(Type).head
			val String nameAddition = if(statement instanceof LeafList) '[]' else ''
			memberElement.text = statement.name + nameAddition + ': ' + type.typeRef.builtin
			return memberElement
		}
	}

	protected def SModelElement createClassElement(SchemaNode statement, SModelElement viewParentElement,
		SModelElement modelParentElement) {
		if (modelParentElement instanceof SNode) {
			val classElement = configSElement(SNode, viewParentElement.id + '-' + statement.name, 'class')
			classElement.layout = 'vbox'

			val classLabel = configSElement(SLabel, classElement.id + '-label', 'heading')
			classLabel.text = '[' + findTag(statement) + '] ' + statement.name
			classElement.children.add(classLabel)

			// add class members to compartment element
			val compartment = configSElement(SCompartment, classElement.id + '-compartment', 'comp')
			compartment.layout = 'vbox'
			compartment.children.addAll(createChildElements(classElement, compartment, statement.substatements))
			classElement.children.add(compartment)

			// add composition elements 
			modelParentElement.children.addAll(
				createChildElements(classElement, modelParentElement, statement.substatements))

			if (!(statement instanceof Grouping)) {
				val SEdge compositionEdge = configSElement(SEdge,
					viewParentElement.id + '2' + classElement.id + '-edge', 'composition')
				compositionEdge.sourceId = viewParentElement.id
				compositionEdge.targetId = classElement.id
				modelParentElement.children.add(compositionEdge)
			}

			return classElement
		}
	}

	protected def SEdge createEdge(SModelElement fromElement, SModelElement toElement, String edgeType) {
		val SEdge edge = configSElement(SEdge, fromElement.id + '2' + toElement.id + '-edge', edgeType)
		edge.sourceId = fromElement.id
		edge.targetId = toElement.id
		return edge
	}

	protected def String findTag(Statement statement) {
		switch statement {
			ListImpl: 'L'
			ContainerImpl: 'C'
			ModuleImpl: 'M'
			GroupingImpl: 'G'
			default: ''
		}
	}

	protected def String findType(SModelElement element) {
		switch element {
			SNode: 'node'
			SLabel: 'label'
			SCompartment: 'comp'
			SEdge: 'edge'
			default: 'dontknow'
		}
	}

	protected def void postProcessing() {
		new HashMap(postProcesses).forEach [ statement, process |
			process.apply
		]
	}

}
