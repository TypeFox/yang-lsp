package io.typefox.yang.scoping

import com.google.inject.Inject
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.yang.AbstractImport
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.BelongsTo
import io.typefox.yang.yang.Revision
import io.typefox.yang.yang.YangPackage
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.AliasedEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.IScopeProvider
import org.eclipse.xtext.scoping.Scopes
import io.typefox.yang.yang.SchemaNodeIdentifier

class YangSerializerScopeProvider implements IScopeProvider {

	@Inject YangScopeProvider delegate
	@Inject extension YangExtensions yangExtensions

	override getScope(EObject context, EReference reference) {
		val delegateScope = delegate.getScope(context, reference)
		if (YangPackage.Literals.SCHEMA_NODE.isSuperTypeOf(reference.EReferenceType)) {
			val module = context.eResource.contents.head
			if (module instanceof AbstractModule) {
				// we allow the default input/outputs only in the second segment of an identifier
				val isFirstIdentifierSegment = (context.eContainer instanceof SchemaNodeIdentifier)
				return new NameConvertingScope(module, delegateScope, isFirstIdentifierSegment, yangExtensions)
			}
		}
		if (reference.EReferenceType === YangPackage.Literals.REVISION) {
			val import = EcoreUtil2.getContainerOfType(context, AbstractImport)
			val rs = context.eResource.resourceSet
			val ctx = delegate.findScopeInAdapters(context, reference)
			return Scopes.scopeFor(
				ctx.moduleScope.getElements(QualifiedName.create(import.module.name)).map [
					rs.getEObject(EObjectURI, true)
				].filter(AbstractModule).sortBy[eResource.URI.toString].map[substatements.filter(Revision).head].
					filterNull, [QualifiedName.create(it.revision)], IScope.NULLSCOPE)
		}

		return delegateScope
	}

	@FinalFieldsConstructor
	static class NameConvertingScope implements IScope {
		val AbstractModule module
		val IScope delegate
		val boolean isFirstIdentifierSegment
		val extension YangExtensions

		override getAllElements() {
			delegate.allElements.convertNames
		}

		override getElements(QualifiedName name) {
			delegate.getElements(name).convertNames
		}

		override getElements(EObject object) {
			delegate.getElements(object).convertNames
		}

		override getSingleElement(QualifiedName name) {
			delegate.getSingleElement(name).convertName
		}

		override getSingleElement(EObject object) {
			delegate.getSingleElement(object).convertName
		}

		protected def Iterable<IEObjectDescription> convertNames(Iterable<IEObjectDescription> descs) {
			descs.toList.map [
				convertName(it)
			].filterNull
		}

		protected def IEObjectDescription convertName(IEObjectDescription original) {
			if (YangPackage.Literals.RPC.isSuperTypeOf(original.EClass) ||
					YangPackage.Literals.ACTION.isSuperTypeOf(original.EClass)) {
				// filter default inputs/outputs
				val lastSegment = original.qualifiedName.lastSegment
				val isInputOrOutput = (lastSegment == 'input' || lastSegment == 'output')
				if(isFirstIdentifierSegment == isInputOrOutput) 
					return null					
			}
			if (original.qualifiedName.segmentCount < 2)
				return original
			val simpleName = QualifiedName.create(original.qualifiedName.lastSegment)
			val moduleName = original.qualifiedName.segments.get(original.qualifiedName.segmentCount - 2)
			if (moduleName == module.name)
				return new AliasedEObjectDescription(simpleName, original)
			if (module.name == moduleName)
				return toPrefixedDescription(module.prefix, original);
			for (sub : module.substatements) {
				switch sub {
					AbstractImport case sub.module.name == moduleName:
						return toPrefixedDescription(sub.prefix, original)
					BelongsTo case sub.module.name == moduleName:
						return toPrefixedDescription(sub.prefix, original)
				}
			}
			val simpleNamedElement = delegate.getSingleElement(simpleName)
			if (simpleNamedElement === null || simpleNamedElement == original)
				return new AliasedEObjectDescription(simpleName, original)
			return null
		}

		protected def toPrefixedDescription(String prefix, IEObjectDescription original) {
			new AliasedEObjectDescription(QualifiedName.create(prefix, original.qualifiedName.lastSegment), original)
		}
	}

}
