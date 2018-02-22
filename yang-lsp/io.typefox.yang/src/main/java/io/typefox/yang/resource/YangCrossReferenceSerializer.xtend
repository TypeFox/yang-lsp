package io.typefox.yang.resource

import org.eclipse.xtext.serializer.tokens.CrossReferenceSerializer
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.serializer.diagnostic.ISerializationDiagnostic.Acceptor
import io.typefox.yang.yang.ParentRef
import io.typefox.yang.yang.CurrentRef
import org.eclipse.xtext.nodemodel.INode
import io.typefox.yang.yang.RevisionDate
import static extension org.eclipse.xtext.EcoreUtil2.*
import io.typefox.yang.yang.AbstractImport
import io.typefox.yang.utils.YangExtensions
import com.google.inject.Inject
import io.typefox.yang.yang.Revision

class YangCrossReferenceSerializer extends CrossReferenceSerializer {
	
	@Inject extension YangExtensions
	
	override serializeCrossRef(EObject semanticObject, CrossReference crossref, EObject target, INode node, Acceptor errors) {
		if(semanticObject instanceof RevisionDate) {
			val import = semanticObject.getContainerOfType(AbstractImport)
			if (import?.module !== null)
				return import.module.substatementsOfType(Revision).head?.revision ?: import.module.revisionFromFileName
		}
		super.serializeCrossRef(semanticObject, crossref, target, node, errors)
	}
	
	override protected getCrossReferenceNameFromScope(EObject semanticObject, CrossReference crossref, EObject target, IScope scope, Acceptor errors) {
		if (semanticObject instanceof ParentRef)
			return '..'
		if (semanticObject instanceof CurrentRef)
			return '.'
		super.getCrossReferenceNameFromScope(semanticObject, crossref, target, scope, errors)
	}
	
}