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
import io.typefox.yang.yang.Unknown
import io.typefox.yang.resource.ScopeContext.YangScopeKind

/**
 * Links the imported modules and included submodules, as well as computing the ScopeContext for them. 
 */
class ScopeComputer {

	@Inject Validator validator
	@Inject Linker linker
	@Inject ResourceDescriptionsProvider indexProvider
	
	def ScopeContext getScopeContext(AbstractModule module) {
		var result = ScopeContext.findInEmfObject(module)
		if (result !== null) {
			return result
		}
		val moduleScope = module.eResource.moduleScope
		result = new ScopeContext(moduleScope)
		result.attachToEmfObject(module)
		val prefix = module.subStatements.filter(Prefix).head
		if (prefix !== null) {
			result.localPrefix = prefix.prefix
		}
		computeChildren(module, result)
		return result
	}
	
	private def IScope getModuleScope(Resource resource) {
		val index = indexProvider.getResourceDescriptions(resource)
		return SelectableBasedScope.createScope(IScope.NULLSCOPE, index, YangPackage.Literals.ABSTRACT_MODULE, false)
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
		if (node.name === null) {
			// broken model be graceful
			return;
		}
		val n = if (prefix === null) QualifiedName.create(node.name) else QualifiedName.create(prefix, node.name) 
		val scopeAndName = switch node {
			DataSchemaNode : ctx.getLocal(YangScopeKind.NODE) -> 'A node'
			Grouping : ctx.getLocal(YangScopeKind.GROUPING) -> 'A grouping'
			Typedef : ctx.getLocal(YangScopeKind.TYPES) -> 'A type'
			Identity : ctx.getLocal(YangScopeKind.IDENTITY) -> 'An identity'
			Extension : ctx.getLocal(YangScopeKind.EXTENSION) -> 'An extension'
			Feature : ctx.getLocal(YangScopeKind.FEATURE) -> 'A feature'
		}
		if (scopeAndName !== null) {
			if (!scopeAndName.key.tryAddLocal(n, node)) {
				validator.addIssue(node, SCHEMA_NODE__NAME, '''«scopeAndName.value» with the name '«n»' already exists.''', IssueCodes.DUPLICATE_NAME)
			}
		}
	}
	
	protected dispatch def void computeScope(EObject module, ScopeContext ctx) {
	}
	
	protected dispatch def void computeScope(SchemaNode node, ScopeContext ctx) {
		ctx.addLocalName(node)
		computeChildren(node, ctx)
	}
	
	protected dispatch def void computeScope(Unknown node, ScopeContext ctx) {
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
				ctx.otherFileScopes.add(getScopeContext(importedModule))
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