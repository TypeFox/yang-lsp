package io.typefox.yang.validation

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.linking.impl.LinkingDiagnosticMessageProvider
import org.eclipse.xtext.util.internal.EmfAdaptable

class LinkingErrorMessageProvider extends LinkingDiagnosticMessageProvider {
	
	static def void markOK(EObject obj) {
		if (ItsOK.findInEmfObject(obj) === null) {
			new ItsOK().attachToEmfObject(obj)
		}
	}
	
	@EmfAdaptable static class ItsOK {
	}
	
	override getUnresolvedProxyMessage(ILinkingDiagnosticContext context) {
		val adapter = ItsOK.findInEmfObject(context.context)
		if (adapter !== null) {
			return null
		}
		super.getUnresolvedProxyMessage(context)
	}

}