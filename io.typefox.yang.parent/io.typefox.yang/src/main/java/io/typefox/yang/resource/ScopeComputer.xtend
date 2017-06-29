package io.typefox.yang.resource

import com.google.inject.Inject
import io.typefox.yang.scoping.ResourceDescriptionStrategy
import io.typefox.yang.validation.IssueCodes
import io.typefox.yang.yang.AbstractImport
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.BelongsTo
import io.typefox.yang.yang.DataSchemaNode
import io.typefox.yang.yang.Extension
import io.typefox.yang.yang.Feature
import io.typefox.yang.yang.Grouping
import io.typefox.yang.yang.Identity
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Include
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.RevisionDate
import io.typefox.yang.yang.SchemaNode
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Submodule
import io.typefox.yang.yang.Typedef
import io.typefox.yang.yang.YangPackage
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.SelectableBasedScope

import static io.typefox.yang.yang.YangPackage.Literals.*
import org.eclipse.emf.ecore.resource.Resource

class ScopeComputer {

	@Inject Validator validator
	@Inject Linker linker
	@Inject ResourceDescriptionsProvider indexProvider
	
	def dispatch ScopeContext getScopeContext(Module module) {
		var result = ScopeContext.findInEmfObject(module)
		if (result !== null) {
			return result
		}
		val moduleScope = module.eResource.moduleScope
		result = new ScopeContext(moduleScope)
		result.attachToEmfObject(module)
		computeChildren(module, result)
		return result
	}
	
	private def IScope getModuleScope(Resource resource) {
		val index = indexProvider.getResourceDescriptions(resource)
		return SelectableBasedScope.createScope(IScope.NULLSCOPE, index, YangPackage.Literals.ABSTRACT_MODULE, false)
	}
	
	def dispatch ScopeContext getScopeContext(Submodule submodule) {
		var result = ScopeContext.findInEmfObject(submodule)
		if (result !== null) {
			return result
		}
		// if not yet computed, trigger scope computation for main module
		val moduleScope = submodule.eResource.moduleScope
		var Module module = submodule.getBelongingModule(moduleScope)
		if (module !== null) {
			getScopeContext(module)
		}
		// now check again
		result = ScopeContext.findInEmfObject(submodule)
		if (result !== null) return result
		
		// still no ctx, means that this submodule either has no module it belongs to or it is not imported by it.
		// let's go with an empty parent scope
		computeScope(submodule, new ScopeContext(moduleScope))
		return result
	}
	
	private def Module getBelongingModule(Submodule submodule, IScope moduleScope) {
		val belongsTo = submodule.subStatements.filter(BelongsTo).head
		if (belongsTo === null) {
			return null
		}
		if (!belongsTo.module.eIsProxy) {
			return belongsTo.module
		} else {
			return linker.link(belongsTo, BELONGS_TO__MODULE) [ name |
				val candidates = moduleScope.getElements(name)
				return candidates.head
			]
		}
	}
	
	protected def addLocalName(ScopeContext ctx, SchemaNode node) {
		addLocalName(ctx, node, null)
	}
	
	protected def addLocalName(ScopeContext ctx, SchemaNode node, String prefix) {
		val n = if (prefix === null) QualifiedName.create(node.name) else QualifiedName.create(prefix, node.name) 
		val scopeAndName = switch node {
			DataSchemaNode : ctx.nodeScope -> 'A node'
			Grouping : ctx.groupingScope -> 'A grouping'
			Typedef : ctx.typeScope -> 'A type'
			Identity : ctx.identityScope -> 'An identity'
			Extension : ctx.extensionScope -> 'An extension'
			Feature : ctx.featureScope -> 'A feature'
		}
		if (scopeAndName !== null) {
			if (!scopeAndName.key.tryAddLocal(n, node)) {
				validator.addIssue(node, SCHEMA_NODE__NAME, '''«scopeAndName.value» with the name '«n»' already exists.''', IssueCodes.DUPLICATE_NAME)
			}
		}
	}
	
	protected dispatch def void computeScope(EObject module, ScopeContext ctx) {
	}
	
	protected dispatch def void computeScope(Submodule module, ScopeContext ctx) {
		computeChildren(module, ctx.newSubmoduleNamespace(module))
	}
	
	protected dispatch def void computeScope(Module module, ScopeContext ctx) {
		computeChildren(module, ctx)
	}
	
	protected dispatch def void computeScope(SchemaNode node, ScopeContext ctx) {
		ctx.addLocalName(node)
		computeChildren(node, ctx)
	}
	
	protected dispatch def void computeScope(DataSchemaNode module, ScopeContext ctx) {
		ctx.addLocalName(module)
		computeChildren(module, ctx.newNodeNamespace(module))
	}
	
	protected def void computeChildren(Statement statement, ScopeContext ctx) {
		for (child : statement.subStatements) {
			computeScope(child, ctx)
		}
	}
	
	protected dispatch def void computeScope(AbstractImport element, ScopeContext ctx) {
		val importedModule = linker.<AbstractModule>link(element, ABSTRACT_IMPORT__MODULE) [ name |
			val rev = element.subStatements.filter(RevisionDate).head
			val candidates = ctx.moduleScope.getElements(name)
			if (rev !== null) {
				val match = candidates.filter[
					val userData = getUserData(ResourceDescriptionStrategy.REVISION)
					return userData !== null && userData == rev.date
				].head
				if (match !== null) {
					return match
				}
				val other = candidates.head
				if (other !== null) {				
					validator.addIssue(rev, REVISION_DATE__DATE, "The "+other.getEClass.name.toLowerCase+" '" + name + "' doesn't exist in revision '"+rev.date+"'.", IssueCodes.UNKNOWN_REVISION)
				}
			}
			val iter = candidates.iterator
			val result = if (iter.hasNext) iter.next
			if (iter.hasNext) {
				validator.addIssue(element, ABSTRACT_IMPORT__MODULE, '''Multiple revisions are available [«candidates.join(', ')[name.toString]»]''', IssueCodes.MISSING_REVISION)
			}
			return result
		]
		val prefix = element.subStatements.filter(Prefix).head?.prefix
		
		if (importedModule instanceof Submodule) {
			if (element instanceof Import) {
				validator.addIssue(element, null, '''The submodule '«importedModule.name»' needs to be 'included' not 'imported'.''', IssueCodes.IMPORT_NOT_A_MODULE)
			}
			val module = findContainingModule(element)
			val belongingModule = importedModule.getBelongingModule(ctx.moduleScope)
			if (belongingModule !== null && belongingModule !== module) {
				validator.addIssue(element, ABSTRACT_IMPORT__MODULE, '''The imported submodule '«importedModule.name»' belongs to the differet module '«belongingModule.name»'.''', IssueCodes.INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE)			
			} else {	
				computeScope(importedModule, ctx)
			}
		}
		if (importedModule instanceof Module) {
			if (element instanceof Include) {
				validator.addIssue(element, null, '''The module '«importedModule.name»' needs to be 'imported' not 'included'.''', IssueCodes.INCLUDE_NOT_A_SUB_MODULE)
			}
			if (prefix === null) {
				validator.addIssue(element, ABSTRACT_IMPORT__MODULE, "The 'prefix' statement is mandatory.", IssueCodes.MISSING_PREFIX)
			} else {	
				ctx.importedModules.put(prefix, getScopeContext(importedModule))
			}
		}
	}
	
	protected def findContainingModule(EObject obj) {
		val candidate = EcoreUtil2.getContainerOfType(obj, AbstractModule)
		if (candidate instanceof Submodule ) {
			return candidate.subStatements.filter(BelongsTo).head.module
		}
		return candidate
	}	
}