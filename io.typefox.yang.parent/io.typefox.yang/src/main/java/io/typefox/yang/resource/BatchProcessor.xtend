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

class BatchProcessor implements IDerivedStateComputer {
	
	@Inject Validator validator
	@Inject Linker linker
	@Inject IGlobalScopeProvider globalScopeProvider
	
	override installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		if (!preLinkingPhase) {
			val resourceScopeCtx = new ScopeContext(IScope.NULLSCOPE, globalScopeProvider.getScope(resource, ABSTRACT_IMPORT__MODULE, [true]))
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
	
	dispatch def void internalCompute(AbstractImport element, ScopeContext ctx) {
		linker.link(element, ABSTRACT_IMPORT__MODULE) [ name |
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
					validator.addIssue(rev, REVISION_DATE__DATE, "The "+other.getEClass.name.toLowerCase+" '" + name + "' doesn't exist in revision '"+rev.date+"'.", IssueCodes.UNKOWN_REVISION)
				}
			}
			return candidates.head
		]
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
			