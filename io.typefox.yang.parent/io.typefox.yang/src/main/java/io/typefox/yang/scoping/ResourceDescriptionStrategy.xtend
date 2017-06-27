package io.typefox.yang.scoping

import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.util.IAcceptor
import org.eclipse.xtext.resource.IEObjectDescription
import io.typefox.yang.yang.Module
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.naming.QualifiedName
import io.typefox.yang.yang.Revision

class ResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {
	public static val REVISION = "rev"
	
	override createEObjectDescriptions(EObject m, IAcceptor<IEObjectDescription> acceptor) {
		switch m {
			Module case !m.subStatements.filter(Revision).empty: {
				acceptor.accept(new EObjectDescription(QualifiedName.create(m.name), m, #{
					REVISION -> m.subStatements.filter(Revision).head.revision
				}))
				return true
			}
			default : {
				return super.createEObjectDescriptions(m, acceptor)
			}
		}
	}
	
}