/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import io.typefox.sprotty.api.Dimension
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
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.DataSchemaNode
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.LeafList
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Statement
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


	def boolean isClassMember(Statement statement) {
//		val List<Class> types = #[Leaf, LeafList]
//		return types.contains(statement.class)
		return statement instanceof Leaf || statement instanceof LeafList
	}

	def List<SModelElement> createChildElements(SModelElement parent, List<Statement> statements, int level) {
		val rootChildren = new ArrayList()
		var int num = 0
		for (statement : statements) {
			num++
			var SModelElement element = null
			var boolean addChildren = true
			if (statement instanceof Module) {
				val prefix = statement.substatements.filter(Prefix).head
				element = configSElement(new SNode, statement.name, 'module')
				(element as SNode) => [
					// TODO position and size must be calculated
					position = new Point => [
						x = 100
						y = 100
					]
					size = new Dimension => [
						width = 500
						height = 800
					]
				]
				val SLabel moduleLabel = configSElement(new SLabel, element.id + '-label', 'heading')
				moduleLabel.position = new Point => [
					x = 5
					y = 5
				]
				moduleLabel.text = prefix.prefix + ':' + statement.name
				element.children.add(moduleLabel)
				
				val SNode moduleNotes = configSElement(new SNode, element.id + '-note', 'note')
				element.children.add(moduleNotes)

				val SNode moduleNode = configSElement(new SNode, element.id + '-node', 'class')
				val SLabel moduleNodeLabel = configSElement(new SLabel, moduleNode.id + '-label', 'heading')
				// TODO instead of [M] there should be a model for rendering an element with another background color... 
				moduleNodeLabel.text = '[M] ' + statement.name
				moduleNode.children.add(moduleNodeLabel)
				moduleNode.children.addAll(createChildElements(moduleNode, statement.substatements, (level + 1)))
				
				element.children.add(moduleNode)
				addChildren = false

			} else if (isClassMember(statement)) { 
				element = configSElement(new SLabel, parent.id + '-' + (statement as DataSchemaNode).name, 'text')
				(element as SLabel).text = (statement as DataSchemaNode).name
			} else if (statement instanceof Container) {
				element = configSElement(new SNode, parent.id + '-' + statement.name, 'class')
				val containerLabel = configSElement(new SLabel, element.id + '-label', 'heading')
				containerLabel.text = statement.name
				element.children.add(containerLabel)
				val compartment = configSElement(new SCompartment, element.id + '-compartment', 'comp')
				compartment.children.addAll(createChildElements(element, statement.substatements, (level + 1)))
				addChildren = false
				element.children.add(compartment)
				val SEdge compositionEdge = configSElement(new SEdge, parent.id + '2' + element.id + '-edge', 'composition')
				compositionEdge.sourceId = parent.id
				compositionEdge.targetId = element.id
				parent.children.add(compositionEdge)
			}
			if (element !== null) {
				if (addChildren)
					element.children.addAll(createChildElements(element, statement.substatements, (level + 1)))
				rootChildren.add(element)
			}
		}
		return rootChildren
	}

	def <E extends SModelElement> E configSElement(E element, String idStr, String typeStr) {
		element => [
			id = idStr
			type = findType(element) + ':' + typeStr
			children = new ArrayList<SModelElement>
		]
		return element
	}

	def String findType(SModelElement element) {
		switch (element.class) {
			case SNode: return 'node'
			case SLabel: return 'label'
			case SCompartment: return 'comp'
			case SEdge: return 'edge'
			default: return 'dontknow'
		}
	}

	def SModelRoot generateDiagram(AbstractModule module, CancelIndicator cancelIndicator) {
		val diagram = new SGraph => [
			type = 'graph'
			id = 'yang'
		]

		val rootChildren = createChildElements(diagram, #[module], 0)
		diagram.children = rootChildren
		return diagram
	}
}
