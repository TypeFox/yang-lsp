package io.typefox.yang.validation

import io.typefox.yang.yang.AbstractModule
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.IAcceptor
import org.eclipse.xtext.validation.Issue

interface IValidatorExtension {
	
	def void validate(AbstractModule module, IAcceptor<Issue> issueAcceptor, CancelIndicator cancelIndicator);
}