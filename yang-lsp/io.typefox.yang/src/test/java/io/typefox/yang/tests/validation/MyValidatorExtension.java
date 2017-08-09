package io.typefox.yang.tests.validation;

import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.util.IAcceptor;
import org.eclipse.xtext.validation.Issue;

import io.typefox.yang.validation.IValidatorExtension;
import io.typefox.yang.validation.IssueFactory;
import io.typefox.yang.yang.AbstractModule;
import io.typefox.yang.yang.YangPackage;

public class MyValidatorExtension implements IValidatorExtension {

	public static final String BAD_NAME = "bad_name";

	@Override
	public void validate(AbstractModule module, IAcceptor<Issue> issueAcceptor, CancelIndicator cancelIndicator) {
		if (module.getName().equals("foo")) {
			issueAcceptor.accept(IssueFactory.createIssue(module, YangPackage.Literals.ABSTRACT_MODULE__NAME, "'foo' is a bad name", BAD_NAME));
		}
	}

}
