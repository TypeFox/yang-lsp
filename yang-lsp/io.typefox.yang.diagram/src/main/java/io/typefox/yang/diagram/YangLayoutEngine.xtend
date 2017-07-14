/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import io.typefox.sprotty.api.SGraph
import io.typefox.sprotty.api.SModelRoot
import io.typefox.sprotty.layout.ElkLayoutEngine
import io.typefox.sprotty.layout.SprottyLayoutConfigurator
import org.eclipse.elk.alg.layered.options.LayeredOptions
import org.eclipse.elk.core.options.CoreOptions
import org.eclipse.elk.core.options.Direction

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
	
}