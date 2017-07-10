/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import io.typefox.sprotty.api.SEdge
import io.typefox.sprotty.api.SGraph
import io.typefox.sprotty.api.SModelRoot
import io.typefox.sprotty.layout.ElkLayoutEngine
import io.typefox.sprotty.layout.SprottyLayoutConfigurator
import java.util.Map
import org.eclipse.elk.alg.layered.options.LayeredOptions
import org.eclipse.elk.core.options.CoreOptions
import org.eclipse.elk.core.options.Direction
import org.eclipse.elk.graph.ElkConnectableShape
import org.eclipse.elk.graph.ElkEdge
import org.eclipse.elk.graph.util.ElkGraphUtil

class YangLayoutEngine extends ElkLayoutEngine {
	
	override layout(SModelRoot root) {
		if (root instanceof SGraph) {
			val configurator = new SprottyLayoutConfigurator
			configurator.configureByType('module')
				.setProperty(CoreOptions.DIRECTION, Direction.DOWN)
				.setProperty(CoreOptions.SPACING_NODE_NODE, 100.0)
				.setProperty(CoreOptions.SPACING_EDGE_NODE, 30.0)
				.setProperty(LayeredOptions.SPACING_EDGE_NODE_BETWEEN_LAYERS, 20.0)
				.setProperty(LayeredOptions.SPACING_NODE_NODE_BETWEEN_LAYERS, 30.0)
			layout(root, configurator)
		}
	}
	
	override protected resolveReferences(ElkEdge elkEdge, SEdge sedge, Map<String, ElkConnectableShape> id2NodeMap, LayoutContext context) {
		val source = id2NodeMap.get(sedge.sourceId)
		val target = id2NodeMap.get(sedge.targetId)
		if (source !== null && target !== null) {
			elkEdge.sources.add(source)
			elkEdge.targets.add(target)
			val container = ElkGraphUtil.findBestEdgeContainment(elkEdge)
			if (container !== null)
				elkEdge.setContainingNode(container)
			else
				elkEdge.setContainingNode(context.elkGraph)
		}
	}
	
}