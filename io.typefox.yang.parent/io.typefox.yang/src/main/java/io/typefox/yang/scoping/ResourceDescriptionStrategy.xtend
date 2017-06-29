package io.typefox.yang.scoping

import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Revision
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.util.IAcceptor
import io.typefox.yang.yang.YangFactory
import org.eclipse.emf.ecore.InternalEObject
import org.eclipse.emf.ecore.util.EcoreUtil

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
			val proxy = YangFactory.eINSTANCE.createAbstractModule()
			(proxy as InternalEObject).eSetProxyURI(EcoreUtil.getURI(m))
			acceptor.accept(new EObjectDescription(QualifiedName.create(m.name), proxy, data))
			return false
		}
		return true
	}
	
}