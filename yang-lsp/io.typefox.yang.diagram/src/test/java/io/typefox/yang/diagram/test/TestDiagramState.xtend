/*
 * Copyright (C) 2017-2020 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram.test

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.sprotty.IDiagramState
import org.eclipse.sprotty.SModelRoot
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class TestDiagramState implements IDiagramState {

	val String clientId

	val currentModel = new SModelRoot => [
		type = "NONE"
		id = "ROOT"
	]

	val expandedElements = <String>newHashSet

	new(Resource resource) {
		this.clientId = resource.URI.trimFileExtension.lastSegment
	}

	override getOptions() {
		emptyMap
	}

	override getSelectedElements() {
		emptySet
	}
}
