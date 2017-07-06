package io.typefox.yang.scoping

import com.google.inject.Inject
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.validation.IssueCodes
import io.typefox.yang.yang.AbsoluteSchemaNodeIdentifier
import io.typefox.yang.yang.AbstractImport
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.Base
import io.typefox.yang.yang.BelongsTo
import io.typefox.yang.yang.Case
import io.typefox.yang.yang.Choice
import io.typefox.yang.yang.DataSchemaNode
import io.typefox.yang.yang.Deviation
import io.typefox.yang.yang.Extension
import io.typefox.yang.yang.Feature
import io.typefox.yang.yang.Grouping
import io.typefox.yang.yang.GroupingRef
import io.typefox.yang.yang.IdentifierRef
import io.typefox.yang.yang.Identity
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Include
import io.typefox.yang.yang.KeyReference
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Refine
import io.typefox.yang.yang.RevisionDate
import io.typefox.yang.yang.SchemaNode
import io.typefox.yang.yang.SchemaNodeIdentifier
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Submodule
import io.typefox.yang.yang.TypeReference
import io.typefox.yang.yang.Typedef
import io.typefox.yang.yang.Unique
import io.typefox.yang.yang.Unknown
import io.typefox.yang.yang.Uses
import io.typefox.yang.yang.YangPackage
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.SelectableBasedScope
import org.eclipse.xtext.util.internal.EmfAdaptable

import static io.typefox.yang.yang.YangPackage.Literals.*
import io.typefox.yang.yang.Input
import io.typefox.yang.yang.Output
import io.typefox.yang.yang.Rpc
import io.typefox.yang.yang.Action

/**
 * Links the imported modules and included submodules, as well as computing the IScopeContext for them. 
 */
class ScopeContextProvider {

	@Inject Validator validator
	@Inject Linker linker
	@Inject ResourceDescriptionsProvider indexProvider
	@Inject extension YangExtensions
	
	@EmfAdaptable
	@Data
	private static class Adapter {
		IScopeContext scopeContext
	}
	
	def IScopeContext getScopeContext(AbstractModule module) {
		val existing = Adapter.findInEmfObject(module)
		if (existing !== null) {
			return existing.scopeContext
		}
		val moduleScope = module.eResource.moduleScope
		val result = new ScopeContext(
			moduleScope, 
			module.prefix, 
			module.getBelongingModule(moduleScope)?.name ?: module.name
		)
		new Adapter(result).attachToEmfObject(module)
		
		handleGeneric(module, QualifiedName.EMPTY, result)
		return result
	}
	
	private def IScope getModuleScope(Resource resource) {
		val index = indexProvider.getResourceDescriptions(resource)
		return SelectableBasedScope.createScope(IScope.NULLSCOPE, index, YangPackage.Literals.ABSTRACT_MODULE, false)
	}
	
	private def dispatch Module getBelongingModule(Module module, IScope moduleScope) {
		return module
	}
	private def dispatch Module getBelongingModule(Submodule submodule, IScope moduleScope) {
		val belongsTo = submodule.substatements.filter(BelongsTo).head
		if (belongsTo === null) {
			return null
		}
		return linker.link(belongsTo, BELONGS_TO__MODULE) [ name |
			val candidates = moduleScope.getElements(name)
			return candidates.head
		]
	}
	
	protected def addToDefinitionScope(SchemaNode node, IScopeContext ctx) {
		if (node.name === null) {
			// broken model be graceful
			return;
		}
		val n = QualifiedName.create(node.name) 
		val scopeAndName = switch node {
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
	
	protected dispatch def void computeScope(EObject module, QualifiedName nodePath, IScopeContext ctx) {
	}
	
	protected dispatch def void computeScope(SchemaNode node, QualifiedName nodePath, IScopeContext ctx) {
		handleGeneric(node, nodePath, ctx)
	}
	
	protected dispatch def void computeScope(Refine node, QualifiedName nodePath, IScopeContext ctx) {
		node.node.doLinkNodeLater(nodePath, ctx)
		handleGeneric(node, nodePath, ctx)
	}
	
	protected dispatch def void computeScope(Augment node, QualifiedName nodePath, IScopeContext ctx) {
		node.path.doLinkNodeLater(nodePath, ctx)
		handleGeneric(node, nodePath, ctx)
	}
	
	private def doLinkNodeLater(SchemaNodeIdentifier identifier, QualifiedName prefix, IScopeContext context) {
		context.runAfterAll [
			var pref = if (identifier instanceof AbsoluteSchemaNodeIdentifier) {
				QualifiedName.EMPTY
			} else {
				prefix
			}
			for (e : identifier.elements) {
				pref = e.getQualifiedName(pref, context)
				val p = pref
				linker.link(e, YangPackage.Literals.IDENTIFIER_REF__NODE) [
					val result = context.nodeScope.getSingleElement(p)
					return result
				]
			}
		]
	}
	
	protected dispatch def void computeScope(Statement node, QualifiedName nodePath, IScopeContext ctx) {
		handleGeneric(node, nodePath, ctx)
	}
	
	protected dispatch def void computeScope(TypeReference node, QualifiedName nodePath, IScopeContext ctx) {
		ctx.runAfterDefinitionPhase [
			linker.link(node, TYPE_REFERENCE__TYPE) [ name |
				if (name.segmentCount == 2 && name.firstSegment == ctx.localPrefix) {
					return ctx.typeScope.getSingleElement(name.skipFirst(1))
				}
				return ctx.typeScope.getSingleElement(name)
			]
		]
		handleGeneric(node, nodePath, ctx)
	}
	
	protected dispatch def void computeScope(Uses node, QualifiedName nodePath, IScopeContext ctx) {
		handleGeneric(node, nodePath, ctx)
		ctx.runAfterDefinitionPhase [
			val inliningCtx = new GroupingInliningScopeContext(ctx)
			for (child : node.grouping.node.substatements) {
				handleGeneric(child, nodePath, inliningCtx)
			}
		]
	}
	
	protected dispatch def void computeScope(GroupingRef node, QualifiedName nodePath, IScopeContext ctx) {
		ctx.runAfterDefinitionPhase [
			linker.link(node, GROUPING_REF__NODE) [ name |
				if (name.segmentCount == 2 && name.firstSegment == ctx.localPrefix) {
					return ctx.groupingScope.getSingleElement(name.skipFirst(1))
				}
				return ctx.groupingScope.getSingleElement(name)
			]
		]
		handleGeneric(node, nodePath, ctx)
	}
	
	protected dispatch def void computeScope(Base node, QualifiedName nodePath, IScopeContext ctx) {
		ctx.runAfterDefinitionPhase [
			linker.link(node, BASE__REFERENCE) [ name |
				ctx.identityScope.getSingleElement(name)
			]
		]
		handleGeneric(node, nodePath, ctx)
	}
	
	protected dispatch def void computeScope(Unknown node, QualifiedName nodePath, IScopeContext ctx) {
		ctx.runAfterDefinitionPhase [
			linker.link(node, UNKNOWN__EXTENSION) [ name |
				ctx.extensionScope.getSingleElement(name)
			]
		]
		handleGeneric(node, nodePath, ctx)
	}
	
	protected dispatch def void computeScope(KeyReference node, QualifiedName nodePath, IScopeContext ctx) {
		ctx.runAfterAll [
			linker.link(node, KEY_REFERENCE__NODE) [ syntaxName |
				val result = ctx.nodeScope.allElements.filter[ candidate |
					if (candidate.EClass !== LEAF) {
						return false
					} 
					if (candidate.name.lastSegment != syntaxName.lastSegment) {
						return false
					} 
					if (!candidate.name.startsWith(nodePath)) {
						return false
					}
					return true
				].head
				return result
			]
		]
		handleGeneric(node, nodePath, ctx)
	}
	
	protected dispatch def void computeScope(Unique node, QualifiedName nodePath, IScopeContext ctx) {
		for (identifier : node.references) {
			this.doLinkNodeLater(identifier, nodePath, ctx)
		}
		handleGeneric(node, nodePath, ctx)
	}
	
	protected dispatch def void computeScope(Deviation node, QualifiedName nodePath, IScopeContext ctx) {
		this.doLinkNodeLater(node.reference, nodePath, ctx)
		handleGeneric(node, nodePath, ctx)
	}
	
	protected dispatch def void computeScope(DataSchemaNode module, QualifiedName nodePath, IScopeContext ctx) {
		handleGeneric(module, nodePath, ctx)
	}
	
	protected def void handleGeneric(EObject node, QualifiedName nodePath, IScopeContext ctx) {
		if (node instanceof SchemaNode) {		
			node.addToDefinitionScope(ctx)
		}
		val newPath = getQualifiedName(node, nodePath, ctx)
		if (newPath != nodePath 
			&& !(node instanceof Grouping)
			&& !(node instanceof Augment)) {
			node.addToNodeScope(newPath, ctx)
		}
		val context = switch node {
			Grouping : 
				new LocalNodeScopeContext(ctx)
			SchemaNode : 
				new LocalScopeContext(ctx)
			default : 
				ctx
		}
		for (child : node.eContents) {
			computeScope(child, newPath, context)
		}
	}
	
	private def void addToNodeScope(EObject node, QualifiedName name, IScopeContext ctx) {
		ctx.runAfterDefinitionPhase 
		[
			if (!ctx.nodeScope.tryAddLocal(name, node)) {
				validator.addIssue(node, SCHEMA_NODE__NAME, '''A schema node with the name '«name»' already exists.''', IssueCodes.DUPLICATE_NAME)
			}
		]
	}
	
	protected dispatch def void computeScope(AbstractImport element, QualifiedName currentPrefix, IScopeContext ctx) {
		val importedModule = linker.<AbstractModule>link(element, ABSTRACT_IMPORT__MODULE) [ name |
			val rev = element.substatements.filter(RevisionDate).head
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
		val prefix = element.substatements.filter(Prefix).head?.prefix
		
		if (importedModule instanceof Submodule) {
			if (element instanceof Import) {
				validator.addIssue(element, null, '''The submodule '«importedModule.name»' needs to be 'included' not 'imported'.''', IssueCodes.IMPORT_NOT_A_MODULE)
			}
			val module = findContainingModule(element)
			val belongingModule = importedModule.getBelongingModule(ctx.moduleScope)
			if (belongingModule !== null && belongingModule !== module) {
				validator.addIssue(element, ABSTRACT_IMPORT__MODULE, '''The imported submodule '«importedModule.name»' belongs to the differet module '«belongingModule.name»'.''', IssueCodes.INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE)			
			} else {	
				ctx.moduleBelongingSubModules.add(getScopeContext(importedModule))
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
	
	private def findContainingModule(EObject obj) {
		val candidate = EcoreUtil2.getContainerOfType(obj, AbstractModule)
		if (candidate instanceof Submodule) {
			return candidate.substatements.filter(BelongsTo).head.module
		}
		return candidate
	}	
	
	private def dispatch QualifiedName getQualifiedName(EObject node, QualifiedName p, IScopeContext ctx) {
		return p
	}
	
	private def dispatch QualifiedName getQualifiedName(Grouping node, QualifiedName p, IScopeContext ctx) {
		return QualifiedName.EMPTY
	}
	
	private def dispatch QualifiedName getQualifiedName(Extension node, QualifiedName p, IScopeContext ctx) {
		return p
	}
	
	private def dispatch QualifiedName getQualifiedName(Identity node, QualifiedName p, IScopeContext ctx) {
		return p
	}
	
	private def dispatch QualifiedName getQualifiedName(Feature node, QualifiedName p, IScopeContext ctx) {
		return p
	}
	
	private def dispatch QualifiedName getQualifiedName(Typedef node, QualifiedName p, IScopeContext ctx) {
		return p
	}
	
	private def dispatch QualifiedName getQualifiedName(Input node, QualifiedName p, IScopeContext ctx) {
		return p.append(ctx.moduleName).append('input')
	}
	
	private def dispatch QualifiedName getQualifiedName(Output node, QualifiedName p, IScopeContext ctx) {
		return p.append(ctx.moduleName).append('output')
	}
	
	private def dispatch QualifiedName getQualifiedName(SchemaNode node, QualifiedName p, IScopeContext ctx) {
		var prefix = p
		// data nodes directly contained in choices get an implicit case (see RFC7950 7.9.2)
		if (node.eContainer instanceof Choice && !(node instanceof Case)) {
			prefix = p.append(ctx.moduleName).append(node.name)
			node.addToNodeScope(prefix, ctx)
		}
		val result = prefix.append(ctx.moduleName).append(node.name)
		// add implicit input / output if they do not exist (see RFC 7950 7.14)
		if (node instanceof Rpc || node instanceof Action) {
			val input = node.substatements.filter(Input).head
			if (input === null) {
				val inputName = result.append(ctx.moduleName).append('input')
				node.addToNodeScope(inputName, ctx)
			}
			val output = node.substatements.filter(Output).head
			if (output === null) {
				val outputName = result.append(ctx.moduleName).append('output')
				node.addToNodeScope(outputName, ctx)
			}
		}
		return result
	}
	
	private def dispatch QualifiedName getQualifiedName(Augment node, QualifiedName p, IScopeContext ctx) {
		return getQualifiedName(node.path, p, ctx)
	}
	
	private def dispatch QualifiedName getQualifiedName(SchemaNodeIdentifier identifier, QualifiedName p, IScopeContext ctx) {
		var prefix = if (identifier instanceof AbsoluteSchemaNodeIdentifier) {
			QualifiedName.EMPTY
		} else {
			p
		}
		for (element : identifier.elements) {
			prefix = element._getQualifiedName(prefix, ctx)
		}
		return prefix
	}
	
	private def dispatch QualifiedName getQualifiedName(IdentifierRef ref, QualifiedName prefix, IScopeContext ctx) {
		val qn = linker.getLinkingName(ref, YangPackage.Literals.IDENTIFIER_REF__NODE)
		if (qn !== null) {
			var firstSeg = ctx.moduleName
			if (qn.segmentCount === 2) {
				firstSeg = ctx.importedModules.get(qn.firstSegment)?.moduleName ?: ctx.moduleName
			}
			var secondSeg = qn.lastSegment
			return prefix.append(firstSeg).append(secondSeg)
		}
		return prefix
	}
}
															