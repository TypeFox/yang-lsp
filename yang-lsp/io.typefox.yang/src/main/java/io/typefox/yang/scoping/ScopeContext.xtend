package io.typefox.yang.scoping

import com.google.common.collect.Iterables
import com.google.inject.Provider
import io.typefox.yang.scoping.ScopeContext.LazyScope
import io.typefox.yang.scoping.ScopeContext.MapScope
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
	def String getLocalPrefix()
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

@FinalFieldsConstructor 
@Accessors(PUBLIC_GETTER) class LocalScopeContext implements IScopeContext {
	@Delegate val IScopeContext parent
	
	MapScope groupingScope = new MapScope(new LazyScope[getParent.getGroupingScope])
	MapScope typeScope = new MapScope(new LazyScope[getParent.getTypeScope])
	
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

	@Accessors(PUBLIC_GETTER) IScope moduleScope
	
	@Accessors(PUBLIC_GETTER) MapScope groupingScope = new MapScope(new LazyScope[computeParentDefinitionScope[getGroupingScope]])
	@Accessors(PUBLIC_GETTER) MapScope typeScope = new MapScope(new LazyScope[computeParentDefinitionScope[getTypeScope]])
	@Accessors(PUBLIC_GETTER) MapScope identityScope = new MapScope(new LazyScope[computeParentDefinitionScope[getIdentityScope]])
	@Accessors(PUBLIC_GETTER) MapScope featureScope = new MapScope(new LazyScope[computeParentDefinitionScope[getFeatureScope]])
	@Accessors(PUBLIC_GETTER) MapScope extensionScope = new MapScope(new LazyScope[computeParentDefinitionScope[getExtensionScope]])
	MapScope schemaNodeScope
	
	List<Runnable> resolveDefinitions = newArrayList
	List<Runnable> computeNodeScope = newArrayList
	List<Runnable> afterAll = newArrayList
							  
	@Accessors(PUBLIC_GETTER) Map<String, IScopeContext> importedModules = newHashMap
	
	@Accessors String localPrefix = null
	@Accessors String moduleName = null
	/**
	 * the scopes from other files belonging to the same module
	 */
	@Accessors(PUBLIC_GETTER) Set<IScopeContext> moduleBelongingSubModules = new LinkedHashSet

	new(IScope moduleScope, String prefix, String moduleName) {
		this.moduleScope = moduleScope
		this.localPrefix = prefix
		this.moduleName = moduleName
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
				result.add(subModuleScope.getLocalOnly())
			}
		}
		for (imported : this.importedModules.entrySet) {
			val scope = imported.value.schemaNodeScope
			if (scope !== null) {			
				result.add(scope)
			}
		}
		return new CompositeScope(result)
	}
	
	private def IScope computeParentDefinitionScope((IScopeContext)=>MapScope fun) {
		var result = newArrayList()
		if (this.localPrefix !== null) {				
			val prefix = QualifiedName.create(this.localPrefix)
			result.add(new PrefixingScope(fun.apply(this).localOnly, prefix))
		}
		for (subModule : moduleBelongingSubModules) {
			val scope = fun.apply(subModule).localOnly
			result.add(scope)
			if (this.localPrefix !== null) {				
				val prefix = QualifiedName.create(this.localPrefix)
				result.add(new PrefixingScope(scope, prefix))
			}
		}
		for (imported : this.importedModules.entrySet) {
			val scope = fun.apply(imported.value).localOnly
			val prefix = QualifiedName.create(imported.key)
			result.add(new PrefixingScope(scope, prefix))
			for (submodule : imported.value.moduleBelongingSubModules) {
				val subScope = fun.apply(submodule).localOnly
				result.add(new PrefixingScope(subScope, prefix))
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
		def boolean tryAddLocal(QualifiedName name, EObject element) {
			tryAddLocal(name, element, emptyMap)
		}
		
		def boolean tryAddLocal(QualifiedName name, EObject element, Map<String,String> userData) {
			val description = new EObjectDescription(name, element, userData)
			val existingLocal = this.elements.put(name, description)
			if (existingLocal !== null) {
				// put it back if it was existing locally
				this.elements.put(name, existingLocal)
				return false
			}
			// now check parents
			val existing = parent.getSingleElement(name)
			if (existing !== null && !allowShadowParent) {
				return false
			} else {
				return true
			}
		}
		
		def boolean allowShadowParent() {
			return false
		}
				
		def IScope getLocalOnly() {
			return new MapScope(IScope.NULLSCOPE, elements)
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
}

