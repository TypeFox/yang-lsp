package io.typefox.yang.scoping

import com.google.inject.Inject
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Revision
import io.typefox.yang.yang.Submodule
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
			val leadingRevision = m.substatementsOfType(Revision).head?.revision ?: m.revisionFromFileName
			if (leadingRevision !== null) {
				data = #{
					REVISION -> leadingRevision
				}
			}
			val proxy = switch(m) {
				Module: YangFactory.eINSTANCE.createModule()
				Submodule: YangFactory.eINSTANCE.createSubmodule()
				default: YangFactory.eINSTANCE.createAbstractModule()
			}
			(proxy as InternalEObject).eSetProxyURI(EcoreUtil.getURI(m))
			acceptor.accept(new EObjectDescription(QualifiedName.create(m.name), proxy, data))
			return false
		}
		return true
	}

}
