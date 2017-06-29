package io.typefox.yang.resource

import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.MapBasedScope
import org.eclipse.xtext.util.internal.EmfAdaptable
import org.eclipse.xtext.resource.EObjectDescription
import io.typefox.yang.yang.Submodule
import io.typefox.yang.yang.BelongsTo

@EmfAdaptable
@Accessors(PUBLIC_GETTER) class ScopeContext {

	IScope moduleScope
	
	MutableMapScope nodeScope
	MutableMapScope groupingScope
	MutableMapScope typeScope
	MutableMapScope identityScope
	MutableMapScope featureScope
	MutableMapScope extensionScope
	
	Map<String, ScopeContext> importedModules = newHashMap()
	
	def ScopeContext forName(QualifiedName qn) {
		if (qn.segmentCount == 2) {
			return importedModules.get(qn.segments.head) ?: new ScopeContext(IScope.NULLSCOPE)
		}
		return this
	}
	
	new (IScope moduleScope) {
		this(moduleScope, new MutableMapScope(IScope.NULLSCOPE), new MutableMapScope(IScope.NULLSCOPE),
			new MutableMapScope(IScope.NULLSCOPE), new MutableMapScope(IScope.NULLSCOPE),
			new MutableMapScope(IScope.NULLSCOPE), new MutableMapScope(IScope.NULLSCOPE), newHashMap())
	}
	
	protected new(IScope moduleScope, 
				MutableMapScope nodeScope,
				MutableMapScope groupingScope,
				MutableMapScope typeScope,
				MutableMapScope identityScope,
				MutableMapScope featureScope,
				MutableMapScope extensionScope,
				Map<String, ScopeContext> importedModules) {
		this.moduleScope = moduleScope
		this.nodeScope = nodeScope
		this.groupingScope = groupingScope
		this.typeScope = typeScope
		this.identityScope = identityScope
		this.featureScope = featureScope
		this.extensionScope = extensionScope
		this.importedModules = importedModules
	}
	
	def ScopeContext newNodeNamespace(EObject node) {
		val result = new ScopeContext(moduleScope, new MutableMapScope(nodeScope), new MutableMapScope(groupingScope), new MutableMapScope(typeScope), identityScope, featureScope, extensionScope, importedModules)
		result.attachToEmfObject(node)
		return result;
	}
	
	def ScopeContext newSubmoduleNamespace(Submodule submodule) {
		val result = new ScopeContext(moduleScope, nodeScope, groupingScope, typeScope, identityScope, featureScope, extensionScope, newHashMap())
		try {
			result.attachToEmfObject(submodule)
		} catch (IllegalStateException e) {
			// This can only happen when the submodule doesn't have a single belongsTo statement.
			if (submodule.subStatements.filter(BelongsTo).size === 1) {
				throw e
			}
		}
		return result;
	}
	
	static class MutableMapScope extends MapBasedScope {
		
		Map<QualifiedName, IEObjectDescription> map
		
		new(IScope parent) {
			this(parent, newHashMap)
		}
		
		new(IScope parent, Map<QualifiedName, IEObjectDescription> elements) {
			super(parent, elements, false)
			this.map = elements
		}
		
		/**
		 * @return true, if the element could be added
		 */
		def boolean tryAddLocal(QualifiedName name, EObject element) {
			val existing = this.getSingleElement(name)
			if (existing !== null) {
				return false
			} else {
				this.map.put(name, new EObjectDescription(name, element, emptyMap))
				return true
			}
		}
	}
	
}
	