package io.typefox.yang.scoping

import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Revision
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.util.IAcceptor

class ResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {
	public static val REVISION = "rev"
	
	override createEObjectDescriptions(EObject m, IAcceptor<IEObjectDescription> acceptor) {
		if (m instanceof AbstractModule) {
			val revision = m.subStatements.filter(Revision).head
			var data = emptyMap
			if (revision !== null) {
				data = #{
					REVISION -> m.subStatements.filter(Revision).head.revision
				}
			}
			acceptor.accept(new EObjectDescription(QualifiedName.create(m.name), m, data))
			return false
		}
		return true
	}
	
}