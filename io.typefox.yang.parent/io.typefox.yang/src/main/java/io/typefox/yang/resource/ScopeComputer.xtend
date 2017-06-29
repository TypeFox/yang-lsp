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
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.scoping.IGlobalScopeProvider

import static io.typefox.yang.yang.YangPackage.Literals.*

class ScopeComputer {

	@Inject Validator validator
	@Inject Linker linker
	@Inject IGlobalScopeProvider globalScopeProvider
	
	def dispatch ScopeContext getModuleScope(Module module) {
		var result = ScopeContext.findInEmfObject(module)
		if (result !== null) return result
		
		val moduleScope = globalScopeProvider.getScope(module.eResource, ABSTRACT_IMPORT__MODULE, null)
		result = new ScopeContext(moduleScope)
		result.attachToEmfObject(module)
		computeScope(module, result)
		return result
	}
	
	def dispatch ScopeContext getModuleScope(Submodule submodule) {
		var result = ScopeContext.findInEmfObject(submodule)
		if (result !== null) return result
		
		val belongsTo = submodule.subStatements.filter(BelongsTo).head
		var Module module = null
		val moduleScope = globalScopeProvider.getScope(submodule.eResource, ABSTRACT_IMPORT__MODULE, null)
		if (belongsTo !== null) {
			module = linker.link(belongsTo, BELONGS_TO__MODULE) [ name |
				val candidates = moduleScope.getElements(name)
				return candidates.head
			]
			if (module !== null) {
				getModuleScope(module)
			}
		}
		// now check again
		result = ScopeContext.findInEmfObject(submodule)
		if (result !== null) return result
		
		// still no ctx, means that this submodule either has no module it belongs to or it is not imported by it.
		// let's go with an empty parent scope
		result = new ScopeContext(moduleScope).newSubmoduleNamespace(submodule)
		computeScope(submodule, result)
		return result
	}
	
	protected def addLocalNames(ScopeContext ctx, Statement stmnt) {
		addLocalNames(ctx, stmnt, null)
	}
	
	protected def addLocalNames(ScopeContext ctx, Statement stmnt, String prefix) {
		for (node : stmnt.subStatements.filter(SchemaNode)) {
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
	}
	
	protected dispatch def void computeScope(EObject module, ScopeContext ctx) {
	}
	
	protected dispatch def void computeScope(AbstractModule module, ScopeContext ctx) {
		ctx.addLocalNames(module)
		for (child : module.subStatements) {
			computeScope(child, ctx.newNodeNamespace(child))
		}
	}
	
	protected dispatch def void computeScope(DataSchemaNode module, ScopeContext ctx) {
		ctx.addLocalNames(module)
		for (child : module.subStatements) {
			computeScope(child, ctx.newNodeNamespace(child))
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
			val importedBelongsTo = importedModule.subStatements.filter(BelongsTo).head?.module
			if (importedBelongsTo !== null && importedBelongsTo !== module) {
				validator.addIssue(element, ABSTRACT_IMPORT__MODULE, '''The imported submodule '«importedModule.name»' belongs to the differet module '«importedBelongsTo.name»'.''', IssueCodes.INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE)			
			} else {	
				computeScope(importedModule, ctx.newSubmoduleNamespace(importedModule))
			}
		}
		if (importedModule instanceof Module) {
			if (element instanceof Include) {
				validator.addIssue(element, null, '''The module '«importedModule.name»' needs to be 'imported' not 'included'.''', IssueCodes.INCLUDE_NOT_A_SUB_MODULE)
			}
			if (prefix === null) {
				validator.addIssue(element, ABSTRACT_IMPORT__MODULE, "The 'prefix' statement is mandatory.", IssueCodes.MISSING_PREFIX)
			} else {	
				ctx.importedModules.put(prefix, getModuleScope(importedModule))
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