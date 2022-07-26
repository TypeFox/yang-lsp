package io.typefox.yang.resource

import com.google.inject.Inject
import io.typefox.yang.scoping.xpath.XpathResolver
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.yang.AbstractImport
import io.typefox.yang.yang.CurrentRef
import io.typefox.yang.yang.ParentRef
import io.typefox.yang.yang.Revision
import io.typefox.yang.yang.RevisionDate
import io.typefox.yang.yang.XpathNameTest
import io.typefox.yang.yang.YangPackage
import io.typefox.yang.yang.impl.XpathNameTestImpl
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.GrammarUtil
import org.eclipse.xtext.conversion.IValueConverterService
import org.eclipse.xtext.conversion.ValueConverterException
import org.eclipse.xtext.linking.impl.LinkingHelper
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.IScopeProvider
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.eclipse.xtext.serializer.diagnostic.ISerializationDiagnostic.Acceptor
import org.eclipse.xtext.serializer.tokens.CrossReferenceSerializer
import org.eclipse.xtext.serializer.tokens.SerializerScopeProviderBinding

import static io.typefox.yang.yang.YangPackage.Literals.*

import static extension org.eclipse.xtext.EcoreUtil2.*

class YangCrossReferenceSerializer extends CrossReferenceSerializer {

	@Inject extension YangExtensions

	@Inject LinkingHelper linkingHelper

	@Inject IQualifiedNameConverter qualifiedNameConverter

	@Inject @SerializerScopeProviderBinding
	IScopeProvider scopeProvider

	@Inject IValueConverterService valueConverter
	@Inject IQualifiedNameProvider qName

	override serializeCrossRef(EObject semanticObject, CrossReference crossref, EObject target, INode node,
		Acceptor errors) {
		if (semanticObject instanceof RevisionDate) {
			val import = semanticObject.getContainerOfType(AbstractImport)
			if (import?.module !== null)
				return import.module.substatementsOfType(Revision).head?.revision ?: import.module.revisionFromFileName
		}

		// The following code is copied and adapted from the superclass
		if ((target === null || target.eIsProxy) && node !== null) {
			return tokenUtil.serializeNode(node)
		}

		val ref = GrammarUtil.getReference(crossref, semanticObject.eClass)
		val scope = scopeProvider.getScope(semanticObject, ref)
		if (scope === null) {
			if (errors !== null)
				errors.accept(diagnostics.getNoScopeFoundDiagnostic(semanticObject, crossref, target))
			return null
		}

		var resolvedTarget = target
		if (target !== null && target.eIsProxy) {
			resolvedTarget = handleProxy(target, semanticObject, ref)
		}

		if (resolvedTarget !== null && node !== null) {
			val text = linkingHelper.getCrossRefNodeAsString(node, true)
			val qn = qualifiedNameConverter.toQualifiedName(text)
			if (ref == XPATH_NAME_TEST__REF && qn == XpathResolver.ASTERISK) {
				return text
			}
			val targetURI = EcoreUtil2.getPlatformResourceOrNormalizedURI(resolvedTarget)
			for (desc : scope.getElements(qn)) {
				if (targetURI == desc.EObjectURI)
					return tokenUtil.serializeNode(node)
			}
			val matchingName = getMatchingCrossReferenceName(crossref, resolvedTarget, qn, scope)
			if (matchingName !== null)
				return matchingName
		}
		return getCrossReferenceNameFromScope(semanticObject, crossref, resolvedTarget, scope, errors)
	}

	protected def String getMatchingCrossReferenceName(CrossReference crossref, EObject target, QualifiedName qn,
		IScope scope) {
		for (desc : scope.getElements(target)) {
			if (desc.name == qn) {
				val unconverted = qualifiedNameConverter.toString(desc.name)
				try {
					val ruleName = linkingHelper.getRuleNameFrom(crossref)
					return valueConverter.toString(unconverted, ruleName)
				} catch (ValueConverterException e) {
					// Try next
				}
			}
		}
		return null
	}

	override protected getCrossReferenceNameFromScope(EObject semanticObject, CrossReference crossref, EObject target,
		IScope scope, Acceptor errors) {
		if (semanticObject instanceof ParentRef)
			return '..'
		if (semanticObject instanceof CurrentRef)
			return '.'
		val isRefTo_XPATH_NAME_TEST__REF = semanticObject instanceof XpathNameTest &&
			GrammarUtil.getReference(crossref, semanticObject.eClass) === YangPackage.Literals.XPATH_NAME_TEST__REF
		val scopetoUse = if (isRefTo_XPATH_NAME_TEST__REF) {
				val prefix = (semanticObject as XpathNameTest).prefix
				new FilteringScope(scope, [ eObjDescr |
					val keepEntry = prefix.nullOrEmpty || eObjDescr.name.segmentCount != 2 ||
						prefix == eObjDescr.name.firstSegment
					return keepEntry
				])
			} else
				scope

		var elements = scopetoUse.getElements(target).toList
		
		if (target !== null && !target.eIsProxy) {
			if(elements.size === 0 && (isRefTo_XPATH_NAME_TEST__REF)) {
				// XXX super implementation called below will fail because scope is empty
				// Xpath segment element is not in scope, but resolved. Serialize existing node. See #224
				val existingNode = NodeModelUtils.findActualNodeFor(semanticObject)
				if (existingNode !== null) {
					return tokenUtil.serializeNode(existingNode)
				}
			}
			if (isRefTo_XPATH_NAME_TEST__REF && elements.size > 1) {
				// in case several objects are in scope, try to find one that matches the target object
				val targetURI = EcoreUtil2.getURI(target)
				var filtered = elements.filter[EObjectURI.equals(targetURI)].toList
				if (filtered.size > 1) {
					val targetQname = qName.getFullyQualifiedName(target)
					val simpleNameMatch = filtered.findFirst[it.name.lastSegment == targetQname.lastSegment]
					if (simpleNameMatch !== null) {
						filtered = #[simpleNameMatch]
					}
				}
				if (filtered.size > 0) {
					elements = filtered
				}
			}
		}

		val nameFromSuper = super.getCrossReferenceNameFromScope(semanticObject, crossref, target,
			new SimpleScope(elements), errors)
		return nameFromSuper.removeContainerPrefixIfNeeded(semanticObject)
	}

	private def String removeContainerPrefixIfNeeded(String name, EObject semanticObject) {
		if (semanticObject instanceof XpathNameTestImpl) {
			if (name.startsWith(semanticObject.prefix + ':')) {
				return name.substring(semanticObject.prefix.length + 1)
			}
		}
		return name
	}
}
