/*
 * Copyright (C) 2017 TypeFox and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import io.typefox.sprotty.api.SEdge
import io.typefox.sprotty.api.SModelRoot
import io.typefox.sprotty.api.SNode
import io.typefox.yang.yang.YangFile
import org.eclipse.xtext.util.CancelIndicator
import io.typefox.sprotty.api.Point
import io.typefox.sprotty.api.SLabel
import io.typefox.sprotty.api.SCompartment

class YangDiagramGenerator {

	def SModelRoot generateDiagram(YangFile file, CancelIndicator cancelIndicator) {
		val container1 = new SLayoutNode => [
			id = 'node0'
			type = 'node:class'
			position = new Point(30, 10)
			layout = 'vbox'
			children = #[
				new SLabel => [
					id = 'container1'
					type = 'label=heading'
					text = 'Container: Foo'
				],
				new SCompartment => [
					id = 'container1_leafs'
					type = 'comp:comp'
					layout = 'vbox'
					children = #[
						new SLabel => [
							id = 'container1_leaf1'
							type = 'label:text'
							text = 'leaf1: string'
						],
						new SLabel [
							id = 'container1_leaf2'
							type = 'label:text'
							text = 'leaf2: boolean'
						],
						new SLabel [
							id = 'container1_leaflist1'
							type = 'label:text'
							text = 'leaflist1: string[]'
						]
					]
				]
			]
		]

		val diagram = new SModelRoot => [
			type = 'graph'
			id = 'yang'
			children = #[]
		]
		return diagram
	}

}
