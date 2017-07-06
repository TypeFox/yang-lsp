package io.typefox.yang.validation

import org.eclipse.xtext.validation.ResourceValidatorImpl
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.service.OperationCanceledError
import com.google.inject.Inject
import io.typefox.yang.scoping.ScopeContextProvider
import io.typefox.yang.yang.AbstractModule

class ResourceValidator extends ResourceValidatorImpl {
	
	@Inject ScopeContextProvider ctxProvider
	
	override validate(Resource resource, CheckMode mode, CancelIndicator mon) throws OperationCanceledError {
		for (m : resource.contents.filter(AbstractModule)) {		
			ctxProvider.getScopeContext(m).resolveAll
		}
		super.validate(resource, mode, mon)
	}
	
}