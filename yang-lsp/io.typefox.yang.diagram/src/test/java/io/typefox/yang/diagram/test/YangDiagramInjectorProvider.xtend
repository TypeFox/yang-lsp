package io.typefox.yang.diagram.test

import com.google.inject.Guice
import io.typefox.yang.YangRuntimeModule
import io.typefox.yang.YangStandaloneSetup
import io.typefox.yang.diagram.YangDiagramModule
import io.typefox.yang.ide.YangIdeModule
import io.typefox.yang.tests.YangInjectorProvider
import org.eclipse.xtext.util.Modules2

class YangDiagramInjectorProvider extends YangInjectorProvider {
	
	override protected internalCreateInjector() {
		return new YangStandaloneSetup {
			override createInjector() {
				Guice.createInjector(Modules2.mixin(new YangRuntimeModule, new YangIdeModule, new YangDiagramModule)) 
			}}.createInjectorAndDoEMFRegistration
	}
}