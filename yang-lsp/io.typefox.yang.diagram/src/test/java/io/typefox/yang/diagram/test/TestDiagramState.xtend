package io.typefox.yang.diagram.test

import io.typefox.sprotty.api.IDiagramState
import io.typefox.sprotty.api.SModelRoot
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.emf.ecore.resource.Resource

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
