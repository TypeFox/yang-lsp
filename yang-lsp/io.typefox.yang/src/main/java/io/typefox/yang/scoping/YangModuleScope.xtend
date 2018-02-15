package io.typefox.yang.scoping

import io.typefox.yang.yang.YangPackage
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.ISelectable
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.SelectableBasedScope

class YangModuleScope extends SelectableBasedScope {
	
	protected new(IScope outer, ISelectable selectable) {
		super(outer, selectable, null, YangPackage.Literals.ABSTRACT_MODULE, false)
	}
	
	override protected getLocalElementsByEObject(EObject object, URI uri) {
		allLocalElements.filter[ input | 
			input.EObjectOrProxy === object || uri == input.EObjectURI
		]
	}
	
}