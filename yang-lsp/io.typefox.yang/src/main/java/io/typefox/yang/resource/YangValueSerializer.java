package io.typefox.yang.resource;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.Assignment;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.serializer.diagnostic.ISerializationDiagnostic.Acceptor;
import org.eclipse.xtext.serializer.tokens.IValueSerializer;
import org.eclipse.xtext.serializer.tokens.ValueSerializer;

import com.google.inject.Inject;

import io.typefox.yang.YangValueConverterService.StringConverter;
import io.typefox.yang.services.YangGrammarAccess;
import io.typefox.yang.yang.Pattern;
import io.typefox.yang.yang.YangPackage;

public class YangValueSerializer extends ValueSerializer implements IValueSerializer {

	@Inject
	private YangGrammarAccess grammar;

	@Override
	public String serializeAssignedValue(EObject context, RuleCall ruleCall, Object value, INode node,
			Acceptor errors) {
		// when serializing programmatically created model, wrap regex in quotes. See
		// #220
		String result = super.serializeAssignedValue(context, ruleCall, value, node, errors);
		if (node == null && result != null && context instanceof Pattern
				&& ruleCall.getRule() == grammar.getStringValueRule()) {
			if (ruleCall.eContainer() instanceof Assignment && YangPackage.eINSTANCE.getPattern_Regexp().getName()
					.equals(((Assignment) ruleCall.eContainer()).getFeature())) {
				if (result.length() > 2 && !StringConverter.isQuoted(result)) {
					return "'" + result + "'";
				}
			}
		}
		return result;
	}
}
