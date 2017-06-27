package io.typefox.yang.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope

@Data class PriorizingScope implements IScope {
	
	IScope parent
	(IEObjectDescription) => boolean prio
	
	protected def Iterable<IEObjectDescription> priorize(Iterable<IEObjectDescription> candidates) {
		return candidates.filter(prio) + candidates.filter[!prio.apply(it)]
	}
	
	override getAllElements() {
		parent.allElements.priorize
	}
	
	override getElements(QualifiedName name) {
		parent.getElements(name).priorize
	}
	
	override getElements(EObject object) {
		parent.getElements(object).priorize
	}
	
	override getSingleElement(QualifiedName name) {
		getElements(name).head
	}
	
	override getSingleElement(EObject object) {
		getElements(object).head
	}
	
}