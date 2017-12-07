package io.typefox.yang.scoping

import com.google.inject.Inject
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Revision
import io.typefox.yang.yang.YangFactory
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.InternalEObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.util.IAcceptor

class ResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {

	public static val REVISION = "rev"

	@Inject
	extension YangExtensions;

	override createEObjectDescriptions(EObject m, IAcceptor<IEObjectDescription> acceptor) {
		if (m instanceof AbstractModule) {
			var data = emptyMap
			if (!m.substatementsOfType(Revision).empty) {
				data = #{
					REVISION -> m.substatementsOfType(Revision).map[revision].join(',')
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
