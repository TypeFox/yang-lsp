package io.typefox.yang.resource

import io.typefox.yang.scoping.ScopeContextProvider
import java.io.IOException
import java.io.Writer
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.serializer.impl.Serializer

class YangSerializer extends Serializer {
	
	override String serialize(EObject obj, SaveOptions options) {
		ScopeContextProvider.removeFromResource(obj.eResource)
		EcoreUtil.resolveAll(obj.eResource)
		super.serialize(obj, options)	
	}

	override void serialize(EObject obj, Writer writer, SaveOptions options) throws IOException {
		ScopeContextProvider.removeFromResource(obj.eResource)
		EcoreUtil.resolveAll(obj.eResource)
		super.serialize(obj, writer, options)	
	}
	
}