package io.typefox.yang.resource

import org.eclipse.xtext.resource.IDerivedStateComputer
import org.eclipse.xtext.resource.DerivedStateAwareResource
import com.google.inject.Inject

class YangDerivedStateComputer implements IDerivedStateComputer {
	
	@Inject BatchProcessor batchProcessor
	
	override installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		if (!preLinkingPhase) {
			
		}
	}
	override discardDerivedState(DerivedStateAwareResource resource) {
		// do nothing
	}
	
	
}