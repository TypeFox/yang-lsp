package io.typefox.yang.ide.server

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.ide.server.ProjectManager
import org.eclipse.xtext.resource.IResourceDescription.Delta
import org.eclipse.xtext.util.CancelIndicator

class YangProjectManager extends ProjectManager {
	
	@Inject extension YangExclusionProvider 
	
	override protected newBuildRequest(List<URI> changedFiles, List<URI> deletedFiles, List<Delta> externalDeltas, CancelIndicator cancelIndicator) {
		val request = super.newBuildRequest(changedFiles, deletedFiles, externalDeltas, cancelIndicator)
		request.dirtyFiles = changedFiles.filter [
			!isExcluded(baseDir)
		].toList
		request
	}
	
}