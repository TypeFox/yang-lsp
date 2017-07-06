package io.typefox.yang.utils

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtend.lib.annotations.Delegate
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.validation.ValidationMessageAcceptor

/**
 * Validation message acceptor extension that holds information whether an error has been 
 * accepted by the wrapped delegate or not.
 * 
 * @author akos.kitta
 */
@FinalFieldsConstructor
class ValidationMessageAcceptorExt implements ValidationMessageAcceptor {

	@Delegate
	val ValidationMessageAcceptor delegate;
	var errorFlag = false;

	/**
	 * Wraps the delegate into an acceptor extension. If the delegate argument is already an
	 * instance of an acceptor extension, then returns with the argument. 
	 */
	def static ValidationMessageAcceptorExt wrappedAcceptor(ValidationMessageAcceptor delegate) {
		if (delegate instanceof ValidationMessageAcceptorExt) {
			return delegate;
		}
		return new ValidationMessageAcceptorExt(delegate);
	}

	override acceptError(String message, EObject object, EStructuralFeature feature, int index, String code,
		String... issueData) {

		errorFlag = true;
		delegate.acceptError(message, object, feature, index, code, issueData);
	}

	override acceptError(String message, EObject object, int offset, int length, String code, String... issueData) {
		errorFlag = true;
		delegate.acceptError(message, object, offset, length, code, issueData);
	}

	/**
	 * Returns {@code true} if at least one error has been accepted. If not, returns {@code false}.
	 */
	def boolean hasError() {
		return errorFlag;
	}

}
