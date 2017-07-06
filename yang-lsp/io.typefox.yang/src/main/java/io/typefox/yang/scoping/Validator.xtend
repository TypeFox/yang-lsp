package io.typefox.yang.scoping

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.validation.EObjectDiagnosticImpl
import org.eclipse.xtext.validation.IssueSeveritiesProvider

class Validator {
	@Inject IssueSeveritiesProvider severitiesProvider

	def addIssue(EObject obj, EStructuralFeature feature, String errorMessage, String issueCode) {
		val resource = obj.eResource as XtextResource
		val severity = severitiesProvider.getIssueSeverities(resource).getSeverity(issueCode)
		val list = switch severity {
			case ERROR:
				resource.errors
			case WARNING:
				resource.warnings
			default:
				null
		}
		if (list !== null) {
			val diagnostic = new EObjectDiagnosticImpl(severity, issueCode, errorMessage, obj, feature, -1,
				newArrayOfSize(0))
			if (!list.contains(diagnostic))
				list.add(diagnostic)
		}
	}
}
