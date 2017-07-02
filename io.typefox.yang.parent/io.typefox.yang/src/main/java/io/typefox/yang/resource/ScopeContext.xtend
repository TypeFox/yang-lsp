package io.typefox.yang.resource

import java.util.HashMap
import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.MapBasedScope
import org.eclipse.xtext.util.internal.EmfAdaptable

@EmfAdaptable
@Accessors(PUBLIC_GETTER) class ScopeContext {

	static enum YangScopeKind {
		NODE,
		GROUPING,
		TYPES,
		IDENTITY,
		FEATURE,
		EXTENSION
	}

	IScope moduleScope
	Map<YangScopeKind, MapScope> scopes = new HashMap
	Map<String, ScopeContext> importedModules
	/**
	 * the scopes from other files belonging to the same module
	 */
	Set<ScopeContext> otherFileScopes

	new(IScope moduleScope) {
		this(moduleScope, new MapScope(), new MapScope(), new MapScope(), new MapScope(), new MapScope(),
			new MapScope(), newHashMap(), newLinkedHashSet())
	}

	protected new(IScope moduleScope, MapScope nodeScope, MapScope groupingScope, MapScope typeScope,
		MapScope identityScope, MapScope featureScope, MapScope extensionScope,
		Map<String, ScopeContext> importedModules, Set<ScopeContext> otherFileScopes) {
		this.moduleScope = moduleScope
		this.scopes.put(YangScopeKind.NODE, nodeScope)
		this.scopes.put(YangScopeKind.GROUPING, groupingScope)
		this.scopes.put(YangScopeKind.TYPES, typeScope)
		this.scopes.put(YangScopeKind.IDENTITY, identityScope)
		this.scopes.put(YangScopeKind.FEATURE, featureScope)
		this.scopes.put(YangScopeKind.EXTENSION, extensionScope)
		this.importedModules = importedModules
		this.otherFileScopes = otherFileScopes
	}

	def MapScope getLocal(YangScopeKind kind) {
		return this.scopes.get(kind)
	}

	def YangScope getFull(YangScopeKind kind) {
		return new YangScope(this, kind)
	}

	def ScopeContext newNodeNamespace(EObject node) {
		val result = new ScopeContext(moduleScope, new MapScope(getLocal(YangScopeKind.NODE)),
			new MapScope(getLocal(YangScopeKind.GROUPING)), new MapScope(getLocal(YangScopeKind.TYPES)),
			getLocal(YangScopeKind.IDENTITY), getLocal(YangScopeKind.FEATURE), getLocal(YangScopeKind.EXTENSION),
			importedModules, otherFileScopes)
		result.attachToEmfObject(node)
		return result;
	}

	static class YangScope implements IScope {

		ScopeContext ctx
		YangScopeKind kind

		new(ScopeContext ctx, YangScopeKind kind) {
			this.ctx = ctx
			this.kind = kind
		}

		override getElements(QualifiedName name) {
			// qualified names
			if (name.segmentCount == 2) {
				val first = name.firstSegment
				val imported = this.ctx.importedModules.get(first)
				if (imported === null) {
					return emptyList
				}
				return imported.getFull(kind).getElements(QualifiedName.create(name.lastSegment))
			}

			val result = ctx.otherFileScopes.map[getLocal(kind)].map[getElements(name)].fold(
				ctx.getLocal(kind).getElements(name))[$0 + $1]
			return result
		}

		override getAllElements() {
			return ctx.otherFileScopes.map[getLocal(kind)].map[allElements].fold(ctx.getLocal(kind).allElements) [
				$0 + $1
			]
		}

		override getElements(EObject object) {
			allElements.filter[EObjectOrProxy === object]
		}

		override getSingleElement(QualifiedName name) {
			this.getElements(name).head
		}

		override getSingleElement(EObject object) {
			this.getElements(object).head
		}

	}

	static class MapScope extends MapBasedScope {
		Map<QualifiedName, IEObjectDescription> elements = newHashMap

		new() {
			this(IScope.NULLSCOPE)
		}

		new(IScope parent) {
			this(parent, newHashMap)
		}

		new(IScope parent, Map<QualifiedName, IEObjectDescription> elements) {
			super(parent, elements, false)
			this.elements = elements
		}

		/**
		 * @return true, if the element could be added
		 */
		def boolean tryAddLocal(QualifiedName name, EObject element) {
			val existing = this.getSingleElement(name)
			if (existing !== null) {
				return false
			} else {
				this.elements.put(name, new EObjectDescription(name, element, emptyMap))
				return true
			}
		}
	}

}
