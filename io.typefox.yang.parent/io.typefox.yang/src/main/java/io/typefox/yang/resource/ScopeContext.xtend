package io.typefox.yang.resource

import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.MapBasedScope
import org.eclipse.xtext.util.internal.EmfAdaptable

@EmfAdaptable
@Accessors(PUBLIC_GETTER) class ScopeContext {

	IScope moduleScope
	
	Map<QualifiedName, IEObjectDescription> localNodes = newHashMap
	IScope nodeScope
	 
	Map<QualifiedName, IEObjectDescription> localGroupings = newHashMap
	IScope groupingScope
	
	Map<QualifiedName, IEObjectDescription> localTypes = newHashMap
	IScope typeScope
	
	Map<QualifiedName, IEObjectDescription> identities = newHashMap
	Map<QualifiedName, IEObjectDescription> features = newHashMap
	Map<QualifiedName, IEObjectDescription> extensions = newHashMap
	
	IScope identityScope
	IScope featureScope
	IScope extensionScope
	
	new (IScope moduleScope) {
		this(moduleScope, IScope.NULLSCOPE, IScope.NULLSCOPE, IScope.NULLSCOPE)
	}
	
	protected new(IScope moduleScope, IScope parentNodeScope, IScope parentGroupingScope, IScope parentTypeScope) {
		this.moduleScope = moduleScope
		
		this.localNodes = newHashMap()
		this.nodeScope = new MutableMapScope(parentNodeScope, localNodes)
		this.localGroupings = newHashMap()
		this.groupingScope = new MutableMapScope(parentGroupingScope, localGroupings)
		this.localTypes = newHashMap()
		this.typeScope = new MutableMapScope(parentTypeScope, localTypes)
		
		this.identityScope = new MutableMapScope(IScope.NULLSCOPE, identities)
		this.featureScope = new MutableMapScope(IScope.NULLSCOPE, features)
		this.extensionScope = new MutableMapScope(IScope.NULLSCOPE, extensions)
	}
	
	def ScopeContext newNodeNamespace(EObject node) {
		val result = new ScopeContext(moduleScope, nodeScope, groupingScope, typeScope)
		result.attachToEmfObject(node)
		return result;
	}
	
	static class MutableMapScope extends MapBasedScope {
		new(IScope parent, Map<QualifiedName, IEObjectDescription> elements) {
			super(parent, elements, false)
		}
	}
}
	