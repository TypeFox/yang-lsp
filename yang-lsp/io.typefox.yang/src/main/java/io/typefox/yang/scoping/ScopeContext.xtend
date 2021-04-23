package io.typefox.yang.scoping

import com.google.common.collect.Iterables
import com.google.inject.Provider
import io.typefox.yang.scoping.ScopeContext.LazyScope
import io.typefox.yang.scoping.ScopeContext.MapScope
import io.typefox.yang.yang.Deviation
import java.util.LinkedHashSet
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.AliasedEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.MapBasedScope
import org.eclipse.xtext.util.internal.Log

interface IScopeContext {
	
	def IScope getModuleScope()
	def QualifiedName getLocalPrefix()
	def String getModuleName()
	
	def Map<String, IScopeContext> getImportedModules()
	def Set<IScopeContext> getModuleBelongingSubModules()
	
	def MapScope getGroupingScope()
	def MapScope getTypeScope()
	def MapScope getIdentityScope()
	def MapScope getFeatureScope()
	def MapScope getExtensionScope()
	def MapScope getSchemaNodeScope()
	
	def void onResolveDefinitions(Runnable callback)
	def void onComputeNodeScope(Runnable callback)
	def void runAfterAll(Runnable callback)
	
	def void resolveDefinitionPhase()
	def void resolveAll()
}

/**
 * this context is used when a 'uses' statement is resolved and the schema nodes from the referenced grouping are inlined.
 */
@Data class GroupingInliningScopeContext implements IScopeContext {
	@Delegate IScopeContext original
	
	override onResolveDefinitions(Runnable runnable) {
		// do nothing
	}
	
	override MapScope getGroupingScope() { new MapScope }
	override MapScope getTypeScope() { new MapScope }
	override MapScope getIdentityScope() { new MapScope }
	override MapScope getFeatureScope() { new MapScope }
	override MapScope getExtensionScope() {new MapScope }
}

@Data class DeviationScopeContext implements IScopeContext {
	@Delegate IScopeContext original
	Deviation deviation
}

@FinalFieldsConstructor 
@Accessors(PUBLIC_GETTER)
class LocalScopeContext implements IScopeContext {
	@Delegate val IScopeContext parent
	
	val MapScope groupingScope = new MapScope(new LazyScope[getParent.getGroupingScope])
	val MapScope typeScope = new MapScope(new LazyScope[getParent.getTypeScope])
	
	override getGroupingScope() {
		return groupingScope
	}
	override getTypeScope() {
		return typeScope
	}
}

class LocalNodeScopeContext extends LocalScopeContext {
	
	new(IScopeContext parent) {
		super(parent)
	}
	
	MapScope schemaNodeScope; 
	
	override getSchemaNodeScope() {
		if (schemaNodeScope === null) {
			val lazyParent = new LazyScope[parent.schemaNodeScope]
			this.schemaNodeScope = new MapScope(lazyParent) {
				override allowShadowParent() {
					 true
				}
			}
			lazyParent.scope
		}
		return schemaNodeScope
	}
}

@Log
class ScopeContext implements IScopeContext {

	@Accessors val IScope moduleScope
	
	@Accessors val MapScope groupingScope = new MapScope(new LazyScope[computeParentDefinitionScope[getGroupingScope]])
	@Accessors val MapScope typeScope = new MapScope(new LazyScope[computeParentDefinitionScope[getTypeScope]])
	@Accessors val MapScope identityScope = new MapScope(new LazyScope[computeParentDefinitionScope[getIdentityScope]])
	@Accessors val MapScope featureScope = new MapScope(new LazyScope[computeParentDefinitionScope[getFeatureScope]])
	@Accessors val MapScope extensionScope = new MapScope(new LazyScope[computeParentDefinitionScope[getExtensionScope]])
	MapScope schemaNodeScope
	
	List<Runnable> resolveDefinitions = newArrayList
	List<Runnable> computeNodeScope = newArrayList
	List<Runnable> afterAll = newArrayList
							  
	@Accessors val Map<String, IScopeContext> importedModules = newHashMap
	@Accessors val QualifiedName localPrefix
	@Accessors val String moduleName
	protected val String createdFrom
	/**
	 * The scopes from other files belonging to the same module
	 */
	@Accessors val Set<IScopeContext> moduleBelongingSubModules = new LinkedHashSet

	new(IScope moduleScope, String prefix, String moduleName, String createdFrom) {
		this.moduleScope = moduleScope
		this.localPrefix = if (prefix !== null) QualifiedName.create(prefix)
		this.moduleName = moduleName
		this.createdFrom = createdFrom
	}
	
	override getSchemaNodeScope() {
		resolveDefinitionPhase
		return this.schemaNodeScope
	}
	
	override void resolveDefinitionPhase() {
		if (resolveDefinitions === null) {
			return;
		}
		val copy = resolveDefinitions
		resolveDefinitions = null
		copy.forEach[run]
				
		val copy2 = computeNodeScope
		computeNodeScope = null
		// assign the node scope
		this.schemaNodeScope = new MapScope(computeParentSchemaNodeScope)
		copy2.forEach[run]
	}
	
	override void resolveAll() {
		if (afterAll === null) {
			return;
		}
		resolveDefinitionPhase
		val copy = afterAll
		afterAll = null
		copy.forEach[run]
	}
	
	private def IScope computeParentSchemaNodeScope() {
		var result = newArrayList()
		for (subModule : moduleBelongingSubModules) {
			val subModuleScope = subModule.schemaNodeScope
			if (subModuleScope !== null) {
				result.add(subModuleScope.localOnly)
			} else {
				//try again later if subModule is currently resolving
				result.add(new LazyScope[subModule.schemaNodeScope] {
					override getScope() {
						val scope = super.getScope()
						if (scope === null)
							return IScope.NULLSCOPE
						return scope
					}
				}) 
			}
		}
		for (imported : importedModules.values) {
			val scope = imported.schemaNodeScope
			if (scope !== null) {			
				result.add(scope)
			}
		}
		return new CompositeScope(result)
	}
	
	private def IScope computeParentDefinitionScope((IScopeContext)=>MapScope fun) {
		var result = newArrayList()
		if (localPrefix !== null) {				
			result.add(new PrefixingScope(fun.apply(this).localOnly, localPrefix))
		}
		for (subModule : moduleBelongingSubModules) {
			val scope = fun.apply(subModule).localOnly
			result.add(scope)
			if (localPrefix !== null) {				
				result.add(new PrefixingScope(scope, localPrefix))
			}
		}
		for (imported : importedModules.entrySet) {
			val scope = fun.apply(imported.value).localOnly
			val prefix = QualifiedName.create(imported.key)
			result.add(new PrefixingScope(scope, prefix))
			for (submodule : imported.value.moduleBelongingSubModules) {
				if (submodule != this) {
					val subScope = fun.apply(submodule).localOnly
					result.add(new PrefixingScope(subScope, prefix))
				}
			}
		}
		return new CompositeScope(result)
	}
	
	override void onResolveDefinitions(Runnable run) {
		if (this.resolveDefinitions === null) {
			if (this.computeNodeScope === null) {
				throw new IllegalStateException("Cannot add to phase, since the next phase has already been executed. Ignoring the callback")
			}
			run.run
		} else {	
			this.resolveDefinitions.add(run)
		}
	}
	
	override void onComputeNodeScope(Runnable run) {
		if (this.computeNodeScope === null) {
			if (this.afterAll === null) {
				throw new IllegalStateException("Cannot add to phase, since the next phase has already been executed. Ignoring the callback")
			}
			run.run
		} else {		
			this.computeNodeScope.add(run)
		}
	}
	
	override void runAfterAll(Runnable run) {
		if (this.afterAll === null) {
			run.run
		} else {			
			this.afterAll.add(run)
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
		def AddResult tryAddLocal(QualifiedName name, EObject element) {
			tryAddLocal(name, element, emptyMap)
		}
		
		def AddResult tryAddLocal(QualifiedName name, EObject element, Map<String,String> userData) {
			val description = new EObjectDescription(name, element, userData)
			val existingLocal = this.elements.put(name, description)
			if (existingLocal !== null) {
				// put it back if it was existing locally
				this.elements.put(name, existingLocal)
				return AddResult.DUPLICATE_LOCAL
			}
			// now check parents
			val existing = parent.getSingleElement(name)
			if (existing !== null && !allowShadowParent) {
				return AddResult.DUPLICATE_PARENT
			}
			return AddResult.OK
		}
		
		def boolean allowShadowParent() {
			return false
		}
				
		def IScope getLocalOnly() {
			return new MapScope(IScope.NULLSCOPE, elements)
		}
		
		static enum AddResult {
			OK, DUPLICATE_LOCAL, DUPLICATE_PARENT
		}
	}

	@Data static class CompositeScope implements IScope {
		Iterable<? extends IScope> scopes
		
		override getAllElements() {
			Iterables.concat(scopes.map[allElements])
		}
		
		override getElements(QualifiedName name) {
			Iterables.concat(scopes.map[getElements(name)])
		}
		
		override getElements(EObject object) {
			Iterables.concat(scopes.map[getElements(object)])
		}
		
		override getSingleElement(QualifiedName name) {
			scopes.map[getSingleElement(name)].filterNull.head
		}
		
		override getSingleElement(EObject object) {
			scopes.map[getSingleElement(object)].filterNull.head
		}
	}
	
	@FinalFieldsConstructor static class LazyScope implements IScope {
		
		val Provider<IScope> provider
		IScope scope
		
		@Delegate def IScope getScope() {
			if (scope === null) {
				scope = provider.get
			}
			return scope
		}
	}
	
	@Data static class PrefixingScope implements IScope {
		IScope parent
		QualifiedName prefix
		
		override getAllElements() {
			parent.allElements.map[prependPrefix]
		}
		
		private def IEObjectDescription prependPrefix(IEObjectDescription desc) {
			if (desc.name.segmentCount > 1) {
				return desc
			}
			return new AliasedEObjectDescription(prefix.append(desc.name), desc)
		}
		
		override getElements(QualifiedName name) {
			if (name.segmentCount == 2 && name.startsWith(prefix)) {
				return parent.getElements(name.skipFirst(prefix.segmentCount))
			}
			return emptyList
		}
		
		override getElements(EObject object) {
			parent.getElements(object).map[prependPrefix]
		}
		
		override getSingleElement(QualifiedName name) {
			return this.getElements(name).head
		}
		
		override getSingleElement(EObject object) {
			return this.getElements(object).head
		}
	}
	
	/*
	// Useful for debugging
	override toString() {
		val visited = newHashSet
		return toString(visited)
	}
	private def String toString(IScopeContext scope, Set<IScopeContext> visited) {
		if(Proxy.isProxyClass(scope.class))
			return scope.toString
		visited.add(scope)
		'''
		«scope.info»
		   «FOR subCtx: scope.safeSubModules(visited)»
		   «subCtx.toString(visited)»
		   «ENDFOR»
		'''
	}
	
	private def safeSubModules(IScopeContext scope, Set<IScopeContext> visited) {
		visited.add(scope)
		return scope.moduleBelongingSubModules.map [ subCtx |
			if (visited.contains(subCtx)) {
				Proxy.newProxyInstance(this.class.classLoader, #[IScopeContext], new InvocationHandler() {
					override invoke(Object proxy, Method method, Object[] args) throws Throwable {
						if (method.name == "toString")
							return '''ref to «subCtx.info»'''.toString
					}
				}) as IScopeContext
			} else
				subCtx
		]
	}
	
	private def String info(IScopeContext scopeCtx)
	'''«scopeCtx.moduleName»«IF scopeCtx instanceof ScopeContext» for «scopeCtx.createdFrom» (def: «scopeCtx.resolveDefinitions?.size», node: «scopeCtx.computeNodeScope?.size») nodescope: «scopeCtx.schemaNodeScope»«ENDIF»'''
 	*/
 }

