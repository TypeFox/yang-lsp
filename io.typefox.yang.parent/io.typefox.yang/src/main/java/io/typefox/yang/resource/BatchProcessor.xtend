package io.typefox.yang.resource

import com.google.inject.Inject
import io.typefox.yang.resource.ScopeContext.YangScopeKind
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.DataSchemaNode
import io.typefox.yang.yang.GroupingRef
import io.typefox.yang.yang.IdentifierRef
import io.typefox.yang.yang.KeyReference
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.SchemaNode
import io.typefox.yang.yang.TypeReference
import io.typefox.yang.yang.Unknown
import io.typefox.yang.yang.Uses
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.DerivedStateAwareResource
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IDerivedStateComputer
import org.eclipse.xtext.util.internal.Log

import static io.typefox.yang.yang.YangPackage.Literals.*
import io.typefox.yang.yang.Base

@Log
class BatchProcessor implements IDerivedStateComputer {
	
//	@Inject Validator validator
	@Inject Linker linker
	@Inject ScopeComputer scopeComputer
	
	override installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		if (!preLinkingPhase) {
			val module = resource.contents.head.eContents.filter(AbstractModule).head
			if (module !== null) {
				// compute the scopes and resolved module links
				val scopeContext = scopeComputer.getScopeContext(module)
				// link extensions, types, identities and groupings
				this.doPrimaryLinking(module, scopeContext)
				// resolve the node links and xpath expressions
				this.doResolveAll(module, scopeContext)
			}
		}
	}
	
	override discardDerivedState(DerivedStateAwareResource resource) {
		// do nothing
	}
	
	dispatch def void doPrimaryLinking(Base ref, ScopeContext ctx) {
		linker.link(ref, BASE__REFERENCE) [ name |
			ctx.getFull(YangScopeKind.IDENTITY).getSingleElement(name)
		]
	}
	
	dispatch def void doPrimaryLinking(GroupingRef ref, ScopeContext ctx) {
		linker.link(ref, GROUPING_REF__NODE) [ name |
			ctx.getFull(YangScopeKind.GROUPING).getSingleElement(name)
		]
	}
	
	dispatch def void doPrimaryLinking(TypeReference ref, ScopeContext ctx) {
		linker.link(ref, TYPE_REFERENCE__TYPE) [ name |
			ctx.getFull(YangScopeKind.TYPES).getSingleElement(name)
		]
	}
	
	dispatch def void doPrimaryLinking(Unknown unknown, ScopeContext ctx) {
		linker.link(unknown, UNKNOWN__EXTENSION) [ name |
			ctx.getFull(YangScopeKind.EXTENSION).getSingleElement(name)
		]
		for (child : unknown.eContents) {
			doPrimaryLinking(child, ctx)
		}
	}
	
	dispatch def void doPrimaryLinking(EObject obj, ScopeContext ctx) {
		var context = ctx
		if (obj instanceof DataSchemaNode) {
			context = ScopeContext.findInEmfObject(obj) ?: {
				LOG.error('''«obj.eClass.name» had no context attached''')
				ctx
			}
		}
		for (child : obj.eContents) {
			doPrimaryLinking(child, context)
		}
	}
	
	dispatch def void doResolveAll(EObject obj, ScopeContext context) {
		for (child : obj.eContents) {
			doResolveAll(child, context)
		}
	}
	
	dispatch def void doResolveAll(KeyReference key, ScopeContext ctx) {
		linker.link(key, KEY_REFERENCE__NODE) [ name |
			val leaf = findLeaf(key.eContainer.eContainer as SchemaNode, name.toString, newHashSet)
			if (leaf === null) {
				return null
			}
			return new EObjectDescription(name, leaf, emptyMap)
		]
	}
	

	private def Leaf findLeaf(SchemaNode node, String name, Set<SchemaNode> checked) {
		if (!checked.add(node)) {
			// recursion!!
			return null
		}
		for (e : node.eAllContents.toIterable) {
			switch e {
				Uses : {
					val result = findLeaf(e.grouping.node, name, checked)
					if (result !== null) {
						return result
					}
				}
				Leaf case e.name == name : {
					return e
				}
			}
		}
		return null
	}	
}
			