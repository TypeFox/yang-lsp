package io.typefox.yang.resource


import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.util.internal.EmfAdaptable
import org.eclipse.xtext.scoping.IScope

@EmfAdaptable
@Data class ScopeContext {
	IScope definitionScope
	IScope moduleScope
	
	def cloneWithDefinitionScope(IScope newDefinitionScope) {
		return new ScopeContext(newDefinitionScope, moduleScope)
	}
	
}
	