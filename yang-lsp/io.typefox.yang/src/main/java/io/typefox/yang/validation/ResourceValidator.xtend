package io.typefox.yang.validation

import com.google.inject.Inject
import io.typefox.yang.scoping.ScopeContextProvider
import io.typefox.yang.utils.ExtensionProvider
import io.typefox.yang.yang.AbstractModule
import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.preferences.PreferenceKey
import org.eclipse.xtext.service.OperationCanceledError
import org.eclipse.xtext.service.OperationCanceledManager
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.IAcceptor
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.validation.Issue.IssueImpl
import org.eclipse.xtext.validation.IssueSeveritiesProvider
import org.eclipse.xtext.validation.ResourceValidatorImpl
import org.eclipse.xtext.util.internal.Log

@Log
class ResourceValidator extends ResourceValidatorImpl {
	
	@Inject ScopeContextProvider ctxProvider
	@Inject ExtensionProvider extensionProvider
	@Inject OperationCanceledManager operationCanceledManager
	@Inject IssueSeveritiesProvider issueSeveritiesProvider
	
	override validate(Resource resource, CheckMode mode, CancelIndicator mon) throws OperationCanceledError {
		for (m : resource.contents.filter(AbstractModule)) {		
			ctxProvider.getScopeContext(m).resolveAll
		}
		super.validate(resource, mode, mon)
	}
	
	public static val VALIDATORS = new PreferenceKey('extension.validators', '')
	
	override protected validate(Resource resource, CheckMode mode, CancelIndicator monitor, IAcceptor<Issue> acceptor) {
		val validators = extensionProvider.getExtensions(VALIDATORS, resource, IValidatorExtension)
		if (!validators.isNullOrEmpty) {
			val issueSeverities = issueSeveritiesProvider.getIssueSeverities(resource)
			val IAcceptor<Issue> wrappedAcceptor = [ issue |
				if (issue instanceof IssueImpl) {
					val configured = issueSeverities.getSeverity(issue.code)
					if (configured !== null) {
						issue.severity = configured
					}
				}
				acceptor.accept(issue)
			]
			for (validator : validators) {
				try {				
					validator.validate(resource.contents.head as AbstractModule, wrappedAcceptor, monitor)
				} catch (Exception e) {
					operationCanceledManager.propagateIfCancelException(e)
					LOG.error('Error running validator extension', e)
				}
			}
		}
		super.validate(resource, mode, monitor, acceptor)
	}
	
	override protected void collectResourceDiagnostics(Resource resource, CancelIndicator monitor,
		IAcceptor<Issue> acceptor) {
		val resourceUriAwareDelegate = [ Issue issue |
			if (issue instanceof IssueImpl) {
				if (issue.uriToProblem === null) {
					issue.uriToProblem = resource.URI
				}
			}
			acceptor.accept(issue)
		]
		super.collectResourceDiagnostics(resource, monitor, resourceUriAwareDelegate)
	}
	
	override protected createAcceptor(List<Issue> result) {
		val delegate = super.createAcceptor(result)
		return [
			delegate.accept(it)
		]
	}
	
}