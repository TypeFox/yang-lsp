package io.typefox.yang.resource

import com.google.inject.Inject
import io.typefox.yang.scoping.ScopeContextProvider
import java.io.IOException
import java.io.Writer
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.serializer.impl.Serializer
import org.eclipse.xtext.util.ReplaceRegion
import org.eclipse.emf.ecore.util.EcoreUtil

class YangSerializer extends Serializer {
	
	@Inject ScopeContextProvider scopeContextProvider
	
	override String serialize(EObject obj) {
		scopeContextProvider.removeScopeContexts(obj.eResource)
		EcoreUtil.resolveAll(obj.eResource)
		super.serialize(obj)
	}

	override String serialize(EObject obj, SaveOptions options) {
		scopeContextProvider.removeScopeContexts(obj.eResource)
		EcoreUtil.resolveAll(obj.eResource)
		super.serialize(obj, options)	
	}

	override void serialize(EObject obj, Writer writer, SaveOptions options) throws IOException {
		scopeContextProvider.removeScopeContexts(obj.eResource)
		EcoreUtil.resolveAll(obj.eResource)
		super.serialize(obj, writer, options)	
	}
	
	override ReplaceRegion serializeReplacement(EObject obj, SaveOptions options) {
		scopeContextProvider.removeScopeContexts(obj.eResource)
		EcoreUtil.resolveAll(obj.eResource)
		super.serializeReplacement(obj, options)	
	}
	
}