//package io.typefox.yang.scoping
//
//import com.google.inject.Inject
//import io.typefox.yang.scoping.ScopeContext.YangScopeKind
//import io.typefox.yang.yang.AbstractModule
//import io.typefox.yang.yang.Augment
//import io.typefox.yang.yang.Base
//import io.typefox.yang.yang.GroupingRef
//import io.typefox.yang.yang.KeyReference
//import io.typefox.yang.yang.Leaf
//import io.typefox.yang.yang.Refine
//import io.typefox.yang.yang.SchemaNode
//import io.typefox.yang.yang.SchemaNodeIdentifier
//import io.typefox.yang.yang.TypeReference
//import io.typefox.yang.yang.Unknown
//import io.typefox.yang.yang.Uses
//import java.util.Set
//import org.eclipse.emf.ecore.EObject
//import org.eclipse.xtext.resource.DerivedStateAwareResource
//import org.eclipse.xtext.resource.EObjectDescription
//import org.eclipse.xtext.resource.IDerivedStateComputer
//import org.eclipse.xtext.scoping.IScope
//import org.eclipse.xtext.scoping.Scopes
//import org.eclipse.xtext.util.internal.Log
//
//import static io.typefox.yang.yang.YangPackage.Literals.*
//
//@Log
//class BatchProcessor implements IDerivedStateComputer {
//	
////	@Inject Validator validator
//	@Inject Linker linker
//	@Inject ScopeContextProvider scopeComputer
//	@Inject DataSchemaScopeComputer schemaScopeComputer
//	
//	override installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
//		if (!preLinkingPhase) {
//			val module = resource.contents.head.eContents.filter(AbstractModule).head
//			if (module !== null) {
//				// compute the scopes and resolved module links
//				val scopeContext = scopeComputer.getScopeContext(module)
//				
//				scopeContext.afterDefinitionScope.add [
//					// link extensions, types, identities and groupings
//					this.doPrimaryLinking(module, scopeContext)
//					// now compute the data schema tree
//					schemaScopeComputer.buildDataSchemaScope(module, scopeContext)
//				]
//				
//				scopeContext.afterNodeScope.add [
//					// now resolve the pathes
//					schemaScopeComputer.resolvePathes(module, scopeContext)
//					// resolve the node links and xpath expressions
////					this.doResolveAll(module, scopeContext)
//				]
//			}
//		}
//	}
//	
//	override discardDerivedState(DerivedStateAwareResource resource) {
//		// do nothing
//	}
//	
////	dispatch def void doPrimaryLinking(Base ref, ScopeContext ctx) {
////		linker.link(ref, BASE__REFERENCE) [ name |
////			ctx.getFull(YangScopeKind.IDENTITY).getSingleElement(name)
////		]
////	}
//	
////	dispatch def void doPrimaryLinking(GroupingRef ref, ScopeContext ctx) {
////		linker.link(ref, GROUPING_REF__NODE) [ name |
////			ctx.getFull(YangScopeKind.GROUPING).getSingleElement(name)
////		]
////	}
//	
////	dispatch def void doPrimaryLinking(TypeReference ref, ScopeContext ctx) {
////		linker.link(ref, TYPE_REFERENCE__TYPE) [ name |
////			ctx.getFull(YangScopeKind.TYPES).getSingleElement(name)
////		]
////	}
//	
////	dispatch def void doPrimaryLinking(Unknown unknown, ScopeContext ctx) {
////		linker.link(unknown, UNKNOWN__EXTENSION) [ name |
////			ctx.getFull(YangScopeKind.EXTENSION).getSingleElement(name)
////		]
////		for (child : unknown.eContents) {
////			doPrimaryLinking(child, ctx)
////		}
////	}
//	
//	dispatch def void doPrimaryLinking(EObject obj, ScopeContext ctx) {
//		for (child : obj.eContents) {
//			doPrimaryLinking(child, ctx)
//		}
//	}
//	
//	dispatch def void doResolveAll(EObject obj, ScopeContext context) {
//		for (child : obj.eContents) {
//			doResolveAll(child, context)
//		}
//	}
//	
//	dispatch def void doResolveAll(Refine refine, ScopeContext ctx) {
//		val scope = if (refine.eContainer instanceof Uses) {
//			val uses = refine.eContainer as Uses
//			Scopes.scopeFor(uses.grouping.node.substatements.filter(SchemaNode))
//		} else {
//			LOG.error("Refine not a child of 'uses'.")
//			return;
//		}
//		refine.node.resolve(scope)
//	}
//	
//	dispatch def void doResolveAll(Augment augment, ScopeContext ctx) {
//		val scope = if (augment.eContainer instanceof Uses) {
//			val uses = augment.eContainer as Uses
//			Scopes.scopeFor(uses.grouping.node.substatements.filter(SchemaNode))
//		} else {
//			ctx.getNodeScope()
//		}
//		augment.path.resolve(scope)
//	}
//	
//	def void resolve(SchemaNodeIdentifier identifier, IScope initialScope) {
//		var scope = initialScope
//		for (ref : identifier.elements) {
//			val currentScope = scope
//			val linked = this.linker.<SchemaNode>link(ref, IDENTIFIER_REF__NODE) [ name |
//				currentScope.getSingleElement(name)
//			]
//			if (linked === null) {
//				return
//			}
//			scope = Scopes.scopeFor(linked.substatements.filter(SchemaNode))
//		}
//	}
//	
////	dispatch def void doResolveAll(KeyReference key, ScopeContext ctx) {
////		linker.link(key, KEY_REFERENCE__NODE) [ name |
////			val leaf = findLeaf(key.eContainer.eContainer as SchemaNode, name.lastSegment.toString, newHashSet)
////			if (leaf === null) {
////				return null
////			}
////			return new EObjectDescription(name, leaf, emptyMap)
////		]
////	}
////	
////
////	private def Leaf findLeaf(SchemaNode node, String name, Set<SchemaNode> checked) {
////		if (!checked.add(node)) {
////			// recursion!!
////			return null
////		}
////		for (e : node.eAllContents.toIterable) {
////			switch e {
////				Uses : {
////					val result = findLeaf(e.grouping.node, name, checked)
////					if (result !== null) {
////						return result
////					}
////				}
////				Leaf case e.name == name : {
////					return e
////				}
////			}
////		}
////		return null
////	}	
//}
//			