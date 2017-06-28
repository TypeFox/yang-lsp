package io.typefox.yang.resource

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.MapBasedScope
import org.eclipse.xtext.util.internal.EmfAdaptable

@EmfAdaptable
@Accessors(PUBLIC_GETTER) class ScopeContext {
	
	Map<QualifiedName, IEObjectDescription> localNodes
	IScope nodeScope
	IScope moduleScope
	
	new (IScope moduleScope, IScope nodeScope) {
		this.moduleScope = moduleScope
		this.localNodes = newHashMap()
		this.nodeScope = new MutableMapScope(nodeScope, localNodes)
	}
	
	static class MutableMapScope extends MapBasedScope {
		new(IScope parent, Map<QualifiedName, IEObjectDescription> elements) {
			super(parent, elements, false)
		}
	}
}
	