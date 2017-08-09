package io.typefox.yang.validation

import com.google.common.base.Splitter
import com.google.inject.Inject
import io.typefox.yang.scoping.ScopeContextProvider
import io.typefox.yang.settings.PreferenceValuesProvider
import io.typefox.yang.utils.ExtensionClassPathProvider
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

class ResourceValidator extends ResourceValidatorImpl {
	
	@Inject ScopeContextProvider ctxProvider
	@Inject PreferenceValuesProvider preferenceProvider
	@Inject ExtensionClassPathProvider extensionClassPathProvider
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
		val prefs = preferenceProvider.getPreferenceValues(resource)
		val validators = prefs.getPreference(VALIDATORS)
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
			val classLoader = extensionClassPathProvider.getExtensionLoader(resource)
			for (validatorClassName : Splitter.on(":").split(validators)) {
				try {				
					val clazz = classLoader.loadClass(validatorClassName)	
					(clazz.newInstance as IValidatorExtension).validate(resource.contents.head as AbstractModule, wrappedAcceptor, monitor)
				} catch (ClassNotFoundException e) {
					acceptor.accept(new IssueImpl() => [
						lineNumber = 1
						message = "Couldn't load validator extension '"+validatorClassName+"'. Did you add the jar to the 'extension.classpath' entry?"
					])
				} catch (ClassCastException e) {
					acceptor.accept(new IssueImpl() => [
						lineNumber = 1
						message = "The configured validator extension '"+validatorClassName+"' doesn't implement '"+IValidatorExtension.name+"'."
					])
				} catch (Exception e) {
					operationCanceledManager.propagateIfCancelException(e)
					// ignore
				}
			}
		}
		super.validate(resource, mode, monitor, acceptor)
	}
	
	override protected createAcceptor(List<Issue> result) {
		val delegate = super.createAcceptor(result)
		return [
			delegate.accept(it)
		]
	}
	
}