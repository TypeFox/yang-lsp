/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import io.typefox.sprotty.api.SModelRoot
import io.typefox.yang.yang.YangFile
import org.eclipse.xtext.util.CancelIndicator

class YangDiagramGenerator {
	
	def SModelRoot generateDiagram(YangFile file, CancelIndicator cancelIndicator) {
		val diagram = new SModelRoot
		diagram.type = 'graph'
		diagram.id = 'yang'
		return diagram
	}
	
}
