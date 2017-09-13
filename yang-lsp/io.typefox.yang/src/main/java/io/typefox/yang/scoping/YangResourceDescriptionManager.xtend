package io.typefox.yang.scoping

import io.typefox.yang.yang.AbstractImport
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.YangPackage
import java.util.Collection
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.IDefaultResourceDescriptionStrategy
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.IResourceDescription.Delta
import org.eclipse.xtext.resource.IResourceDescriptions
import org.eclipse.xtext.resource.impl.DefaultResourceDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionManager
import org.eclipse.xtext.util.IResourceScopeCache

class YangResourceDescriptionManager extends DefaultResourceDescriptionManager {
	
	override isAffected(Collection<Delta> deltas, IResourceDescription candidate, IResourceDescriptions context) {
		val names = candidate.importedNames.toSet
		for (d: deltas) {			
			names.contains(QualifiedName.create(d.uri.trimFileExtension.lastSegment))
			return true
		}
		return false
	}
	
	override protected internalGetResourceDescription(Resource resource, IDefaultResourceDescriptionStrategy strategy) {
		return new YangResourceDescription(resource, strategy, this.cache)
	}
	
	
	static class YangResourceDescription extends DefaultResourceDescription {
		
		Iterable<QualifiedName> importedModules
		
		new(Resource resource, IDefaultResourceDescriptionStrategy strategy, IResourceScopeCache cache) {
			super(resource, strategy, cache)
			importedModules = computeImportedModules(resource)
		}
	
		private def computeImportedModules(Resource resource) {
			val module = resource.contents.head
			if(module instanceof AbstractModule) {
				val result = newArrayList
				for (imp : module.substatements.filter(AbstractImport)) {
					val string = NodeModelUtils.findNodesForFeature(imp, YangPackage.Literals.ABSTRACT_IMPORT__MODULE).join('')[NodeModelUtils.getTokenText(it)]
					result.add(QualifiedName.create(string))
				}
				return result
			} else {
				return emptyList
			}
			
		}
		
		override getImportedNames() {
			importedModules
		}
		
	}
}