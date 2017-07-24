package io.typefox.yang.ide.completion

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistEntry
import org.eclipse.xtext.resource.IEObjectDescription

/**
 * Extension and utility methods for {@link ContentAssistEntry content assist entries}.
 * 
 * @author akos.kitta
 */
class ContentAssistEntryUtils {


	/**
	 * Sets the source on the content assist entry argument and returns with it.
	 * <p>
	 * The source is retrieved from the current module of the CA context. If the current model
	 * is {@code null}, then sets the containing resource as the source.
	 * 
	 * <p>
	 * If the source is already set on the entry, this method has no side-effect.
	 */
	def static attachSourceIfAbsent(ContentAssistEntry it, ContentAssistContext context) {
		if (it !== null && source === null) {
			source = context?.currentModel ?: context?.resource;
		}
		return it;
	}

	/**
	 * Returns with the name of the container resource (without the file extension suffix) 
	 * from the  EObject (if any) which the entry argument has been created.
	 */
	def static getResourceName(ContentAssistEntry it) {
		return it?.source.doGetResourceName;
	}

	private static dispatch def String doGetResourceName(Void it) {
		return null;
	}

	private static dispatch def String doGetResourceName(Object it) {
		return null;
	}

	private static dispatch def String doGetResourceName(URI it) {
		return lastSegment.substring(0, lastSegment.length - (fileExtension.length + 1));
	}

	private static dispatch def String doGetResourceName(Resource it) {
		return URI.doGetResourceName;
	}

	private static dispatch def String doGetResourceName(EObject it) {
		return eResource.URI.doGetResourceName;
	}

	private static dispatch def String doGetResourceName(IEObjectDescription it) {
		return EObjectOrProxy.doGetResourceName;
	}

}
