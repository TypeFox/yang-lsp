package io.typefox.yang.resource

import org.eclipse.xtext.serializer.tokens.CrossReferenceSerializer
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.serializer.diagnostic.ISerializationDiagnostic.Acceptor
import io.typefox.yang.yang.ParentRef
import io.typefox.yang.yang.CurrentRef

class YangCrossReferenceSerializer extends CrossReferenceSerializer {
	
	override protected getCrossReferenceNameFromScope(EObject semanticObject, CrossReference crossref, EObject target, IScope scope, Acceptor errors) {
		if (semanticObject instanceof ParentRef)
			return '..'
		if (semanticObject instanceof CurrentRef)
			return '.'
		super.getCrossReferenceNameFromScope(semanticObject, crossref, target, scope, errors)
	}
	
}