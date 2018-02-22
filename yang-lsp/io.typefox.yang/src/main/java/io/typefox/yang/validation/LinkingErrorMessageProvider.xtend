package io.typefox.yang.validation

import com.google.inject.Inject
import io.typefox.yang.yang.XpathNameTest
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.diagnostics.DiagnosticMessage
import org.eclipse.xtext.linking.impl.LinkingDiagnosticMessageProvider
import org.eclipse.xtext.util.internal.EmfAdaptable
import org.eclipse.xtext.validation.IssueSeveritiesProvider
import org.eclipse.xtext.diagnostics.Severity
import io.typefox.yang.yang.CurrentRef
import io.typefox.yang.yang.ParentRef

class LinkingErrorMessageProvider extends LinkingDiagnosticMessageProvider {
	
	static def void markOK(EObject obj) {
		if (ItsOK.findInEmfObject(obj) === null) {
			new ItsOK().attachToEmfObject(obj)
		}
	}
	
	static def boolean isOK(EObject obj) {
		ItsOK.findInEmfObject(obj) !== null
	}
	
	@EmfAdaptable static class ItsOK {
	}
	
	@Inject IssueSeveritiesProvider severitiesProvider
	
	override getUnresolvedProxyMessage(ILinkingDiagnosticContext context) {
		if(isOK(context.context))
			return null
		if (context.context instanceof XpathNameTest || context.context instanceof CurrentRef || context.context instanceof ParentRef) {
			val severities = severitiesProvider.getIssueSeverities(context.context.eResource)
			val severity = severities.getSeverity(IssueCodes.XPATH_LINK_ERROR)
			if (severity === Severity.ERROR || severity === Severity.WARNING) {
				val msg = "Couldn't resolve reference to data node '" + context.linkText + "'.";
				return new DiagnosticMessage(msg, severities.getSeverity(IssueCodes.XPATH_LINK_ERROR), IssueCodes.XPATH_LINK_ERROR); 
			}
			return null
		}
		super.getUnresolvedProxyMessage(context)
	}

}