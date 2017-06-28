package io.typefox.yang.resource

import com.google.inject.Inject
import io.typefox.yang.scoping.ResourceDescriptionStrategy
import io.typefox.yang.validation.IssueCodes
import io.typefox.yang.yang.AbstractImport
import io.typefox.yang.yang.RevisionDate
import io.typefox.yang.yang.YangFile
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.DerivedStateAwareResource
import org.eclipse.xtext.resource.IDerivedStateComputer
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.scoping.IScope

import static io.typefox.yang.yang.YangPackage.Literals.*
import io.typefox.yang.yang.BelongsTo
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.SchemaNode
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.naming.QualifiedName
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.IdentifierRef
import io.typefox.yang.yang.GroupingRef

class BatchProcessor implements IDerivedStateComputer {
	
	@Inject Validator validator
	@Inject Linker linker
	@Inject IGlobalScopeProvider globalScopeProvider
	
	override installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		if (!preLinkingPhase) {
			val moduleScope = globalScopeProvider.getScope(resource, ABSTRACT_IMPORT__MODULE, null)
			val resourceScopeCtx = new ScopeContext(moduleScope, IScope.NULLSCOPE)
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
			return candidates.head
		]
		val prefix = element.subStatements.filter(Prefix).head?.prefix
		if (prefix === null) {
			validator.addIssue(element, ABSTRACT_IMPORT__MODULE, "The 'prefix' statement is mandatory.", IssueCodes.MISSING_PREFIX)
		} else if (importedModule !== null) {			
			for (node : importedModule.subStatements.filter(SchemaNode)) {
				val qn = QualifiedName.create(prefix, node.name)
				ctx.localNodes.put(qn, new EObjectDescription(qn, node, emptyMap))
			}
		}
		computeChildren(element, ctx)
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
			