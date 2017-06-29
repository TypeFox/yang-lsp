package io.typefox.yang.resource

import com.google.inject.Inject
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.DataSchemaNode
import io.typefox.yang.yang.GroupingRef
import io.typefox.yang.yang.IdentifierRef
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.DerivedStateAwareResource
import org.eclipse.xtext.resource.IDerivedStateComputer

import static io.typefox.yang.yang.YangPackage.Literals.*

class BatchProcessor implements IDerivedStateComputer {
	
	@Inject Validator validator
	@Inject Linker linker
	@Inject ScopeComputer scopeComputer
	
	override installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		if (!preLinkingPhase) {
			val module = resource.contents.head.eContents.filter(AbstractModule).head
			if (module !== null) {
				val scopeContext = scopeComputer.getScopeContext(module)
				this.doLinking(module, scopeContext)
			}
		}
	}
	
	override discardDerivedState(DerivedStateAwareResource resource) {
		// do nothing
	}
	
	dispatch def void doLinking(IdentifierRef ref, ScopeContext ctx) {
		linker.link(ref, IDENTIFIER_REF__NODE) [ name |
			ctx.forName(name).nodeScope.getSingleElement(QualifiedName.create(name.lastSegment))
		]
	}
	
	dispatch def void doLinking(GroupingRef ref, ScopeContext ctx) {
		linker.link(ref, GROUPING_REF__NODE) [ name |
			ctx.forName(name).groupingScope.getSingleElement(QualifiedName.create(name.lastSegment))
		]
	}
	
	dispatch def void doLinking(EObject obj, ScopeContext ctx) {
		var context = ctx
		if (obj instanceof DataSchemaNode) {
			context = ScopeContext.findInEmfObject(obj)
		}
		for (child : obj.eContents) {
			doLinking(child, context)
		}
	}
	
}
			