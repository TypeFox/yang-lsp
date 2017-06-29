package io.typefox.yang.resource

import com.google.inject.Inject
import io.typefox.yang.scoping.ResourceDescriptionStrategy
import io.typefox.yang.validation.IssueCodes
import io.typefox.yang.yang.AbstractImport
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.BelongsTo
import io.typefox.yang.yang.GroupingRef
import io.typefox.yang.yang.IdentifierRef
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Include
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.RevisionDate
import io.typefox.yang.yang.SchemaNode
import io.typefox.yang.yang.Submodule
import io.typefox.yang.yang.YangFile
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.DerivedStateAwareResource
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IDerivedStateComputer
import org.eclipse.xtext.scoping.IGlobalScopeProvider

import static io.typefox.yang.yang.YangPackage.Literals.*
import io.typefox.yang.yang.DataSchemaNode
import io.typefox.yang.yang.Container

class BatchProcessor implements IDerivedStateComputer {
	
	@Inject Validator validator
	@Inject Linker linker
	@Inject IGlobalScopeProvider globalScopeProvider
	
	override installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		if (!preLinkingPhase) {
			val moduleScope = globalScopeProvider.getScope(resource, ABSTRACT_IMPORT__MODULE, null)
			val resourceScopeCtx = new ScopeContext(moduleScope)
			resourceScopeCtx.attachToEmfObject(resource)
			this.compute(resource.contents.filter(YangFile).head, resourceScopeCtx)
		}
	}
	override discardDerivedState(DerivedStateAwareResource resource) {
		// do nothing
	}
	
	def void compute(YangFile file, ScopeContext scopes) {
		internalCompute(file, scopes)
	}
	
	def dispatch void internalCompute(YangFile file, ScopeContext ctx) {
		computeChildren(file, ctx)
	}
	
	dispatch def void internalCompute(EObject obj, ScopeContext ctx) {		
		computeChildren(obj, ctx)
	}
	
	dispatch def void internalCompute(Container obj, ScopeContext ctx) {
		ctx.addNode(obj)
		computeChildren(obj, ctx.newNodeNamespace(obj))
	}
	
	private def void addNode(ScopeContext ctx, DataSchemaNode node) {
		val n = QualifiedName.create(node.name)
		if (ctx.localNodes.containsKey(n)) {
			validator.addIssue(node, SCHEMA_NODE__NAME, '''A data node with the name '«n»' already exists in this scope.''', IssueCodes.DUPLICATE_NAME)
		} else {
			ctx.localNodes.put(n, new EObjectDescription(n, node, emptyMap))
		}
	}
	
	dispatch def void internalCompute(AbstractModule module, ScopeContext ctx) {
		// add top level schema nodes
		for (node : module.subStatements.filter(SchemaNode)) {
			val n = QualifiedName.create(node.name)
			ctx.localNodes.put(n, new EObjectDescription(n, node, emptyMap))
		}
		computeChildren(module, ctx)
	}
	
	dispatch def void internalCompute(IdentifierRef ref, ScopeContext ctx) {
		linker.link(ref, IDENTIFIER_REF__NODE) [ name |
			ctx.nodeScope.getSingleElement(name)
		]
	}
	
	dispatch def void internalCompute(GroupingRef ref, ScopeContext ctx) {
		linker.link(ref, GROUPING_REF__NODE) [ name |
			ctx.nodeScope.getSingleElement(name)
		]
	}
	
	dispatch def void internalCompute(AbstractImport element, ScopeContext ctx) {
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
		if (prefix === null) {
			validator.addIssue(element, ABSTRACT_IMPORT__MODULE, "The 'prefix' statement is mandatory.", IssueCodes.MISSING_PREFIX)
		} 
		if (importedModule !== null) {	
			for (node : importedModule.subStatements.filter(SchemaNode)) {
				val qn = QualifiedName.create(prefix, node.name)
				ctx.localNodes.put(qn, new EObjectDescription(qn, node, emptyMap))
			}
		}
		if (importedModule instanceof Submodule) {
			if (element instanceof Import) {
				validator.addIssue(element, null, '''The submodule '«importedModule.name»' needs to be 'included' not 'imported'.''', IssueCodes.IMPORT_NOT_A_MODULE)
			}
			val module = findModule(element)
			val importedBelongsTo = importedModule.subStatements.filter(BelongsTo).head?.module
			if (importedBelongsTo !== null && importedBelongsTo !== module) {
				validator.addIssue(element, ABSTRACT_IMPORT__MODULE, '''The imported submodule '«importedModule.name»' belongs to the differet module '«importedBelongsTo.name»'.''', IssueCodes.INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE)			
			}
		}
		if (importedModule instanceof Module) {
			if (element instanceof Include) {
				validator.addIssue(element, null, '''The module '«importedModule.name»' needs to be 'imported' not 'included'.''', IssueCodes.INCLUDE_NOT_A_SUB_MODULE)
			}
		}
		computeChildren(element, ctx)
	}
	
	protected def findModule(EObject obj) {
		val candidate = EcoreUtil2.getContainerOfType(obj, AbstractModule)
		if (candidate instanceof Submodule ) {
			return candidate.subStatements.filter(BelongsTo).head.module
		}
		return candidate
	}
	
	dispatch def void internalCompute(BelongsTo element, ScopeContext ctx) {
		linker.link(element, BELONGS_TO__MODULE) [ name |
			val candidates = ctx.moduleScope.getElements(name)
			return candidates.head
		]
		computeChildren(element, ctx)
	}
	
	protected def void computeChildren(EObject obj, ScopeContext ctx) {
		for (child : obj.eContents) {
			internalCompute(child, ctx)
		}
	}
	
}
			