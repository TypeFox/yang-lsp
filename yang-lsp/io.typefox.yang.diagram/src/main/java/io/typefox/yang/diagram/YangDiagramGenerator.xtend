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
import io.typefox.yang.yang.Case
import io.typefox.yang.yang.Choice
import io.typefox.yang.yang.Config
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Grouping
import io.typefox.yang.yang.IfFeature
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.LeafList
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Must
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Presence
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Status
import io.typefox.yang.yang.Uses
import io.typefox.yang.yang.When
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.util.CancelIndicator

class YangDiagramGenerator implements IDiagramGenerator {
	
	override generate(Resource resource, CancelIndicator cancelIndicator) {
		val content = resource.contents.head
		if (content instanceof AbstractModule) {
			generateDiagram(content, cancelIndicator)
		}
	}


	protected def SModelRoot generateDiagram(AbstractModule module, CancelIndicator cancelIndicator) {
		val diagram = new SGraph => [
			type = 'graph'
			id = 'yang'
		]

		val rootChildren = createChildElements(diagram, diagram, module.substatements)
		diagram.children = rootChildren
		return diagram
	}

	/**
	 * @param yangParent SModelElement
	 * @param sprottyParent SModelElement
	 * @param statements List<Statement>
	 */
	protected def List<SModelElement> createChildElements(SModelElement yangParent, SModelElement sprottyParent,
		List<Statement> statements) {
		val rootChildren = new ArrayList()
		var int num = 0
		for (statement : statements) {
			num++
			var SModelElement element = null
			element = generateElement(statement, yangParent, sprottyParent)
			if (element !== null)
				rootChildren.add(element)
		}
		return rootChildren
	}

	protected def dispatch SModelElement generateElement(Module moduleStmt, SModelElement yangParent,
		SModelElement diagramParent) {
		// Module
		val moduleElement = configSElement(SNode, moduleStmt.name, 'module')

		// Module label
		val prefix = moduleStmt.substatements.filter(Prefix).head
		val SLabel moduleLabel = configSElement(SLabel, moduleElement.id + '-label', 'heading')
		moduleLabel.position = new Point => [
			x = 5
			y = 5
		]
		moduleLabel.text = prefix.prefix + ':' + moduleStmt.name
		moduleElement.children.add(moduleLabel)

		// Module note
		val SNode moduleNotes = configSElement(SNode, moduleElement.id + '-note', 'note')
		moduleElement.children.add(moduleNotes)

		// Module node
		val SNode moduleNode = configSElement(SNode, moduleElement.id + '-node', 'class')
		val SLabel moduleNodeLabel = configSElement(SLabel, moduleNode.id + '-label', 'heading')
		// TODO instead of [M] there should be a model for rendering an element with another background color... 
		moduleNodeLabel.text = '[M] ' + moduleStmt.name
		moduleNode.children.add(moduleNodeLabel)
		moduleNode.children.addAll(createChildElements(moduleElement, moduleElement, moduleStmt.substatements))

		moduleElement.children.add(moduleNode)

		return moduleElement
	}

	protected def dispatch SModelElement generateElement(Container containerStmt, SModelElement yangParent,
		SModelElement diagramParent) {
		if (diagramParent instanceof Module) {

			val containerElement = configSElement(SNode, yangParent.id + '-' + containerStmt.name, 'class')

			val containerLabel = configSElement(SLabel, containerElement.id + '-label', 'heading')
			containerLabel.text = containerStmt.name
			containerElement.children.add(containerLabel)

			val compartment = configSElement(SCompartment, containerElement.id + '-compartment', 'comp')
			// nicht alle Statements dürfen hier hinzugefügt werden...zb container nicht, leaf ja
			compartment.children.addAll(createChildElements(yangParent, compartment, containerStmt.substatements))
			containerElement.children.add(compartment)

			val SEdge compositionEdge = configSElement(SEdge, yangParent.id + '2' + containerElement.id + '-edge',
				'composition')
			compositionEdge.sourceId = yangParent.id
			compositionEdge.targetId = containerElement.id
			diagramParent.children.add(compositionEdge)

			return containerElement
		}
	}

	protected def dispatch SModelElement generateElement(Grouping grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(io.typefox.yang.yang.List grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Choice grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Case grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Uses grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Description grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Config grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Must grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Presence grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(When grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Status grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(IfFeature grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Leaf leafStmt, SModelElement yangParent,
		SModelElement diagramParent) {
		if (diagramParent instanceof SCompartment) {
			val SLabel leafElement = configSElement(SLabel, yangParent.id + '-' + leafStmt.name, 'text')
			leafElement.text = leafStmt.name
			return leafElement
		}
	}

	protected def dispatch SModelElement generateElement(LeafList grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Action grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def dispatch SModelElement generateElement(Anyxml grouping, SModelElement yangParent,
		SModelElement diagramParent) {
	}

	protected def <E extends SModelElement> E configSElement(Class<E> elementClass, String idStr, String typeStr) {
		elementClass.constructor.newInstance => [
			id = idStr
			type = findType(it) + ':' + typeStr
			children = new ArrayList<SModelElement>
		]
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

}
