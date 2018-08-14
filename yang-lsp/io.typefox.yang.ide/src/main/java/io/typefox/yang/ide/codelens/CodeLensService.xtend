package io.typefox.yang.ide.codelens

import com.google.inject.Inject
import io.typefox.yang.findReferences.YangReferenceFinder
import io.typefox.yang.settings.PreferenceValuesProvider
import io.typefox.yang.yang.Statement
import org.eclipse.lsp4j.CodeLens
import org.eclipse.lsp4j.CodeLensParams
import org.eclipse.lsp4j.Command
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.ide.server.Document
import org.eclipse.xtext.ide.server.DocumentExtensions
import org.eclipse.xtext.ide.server.codelens.ICodeLensService
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.preferences.PreferenceKey
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator

class CodeLensService implements ICodeLensService {
	
	public static val CODE_LENS_ENABLED = new PreferenceKey("code-lenses", "on")
	
	@Inject YangReferenceFinder referenceFinder
	@Inject DocumentExtensions documentExtensions
	@Inject PreferenceValuesProvider preferenceProvider
	
	override computeCodeLenses(Document document, XtextResource resource, CodeLensParams params, CancelIndicator indicator) {
		val enabled = preferenceProvider.getPreferenceValues(resource).getPreference(CODE_LENS_ENABLED)
		if (!enabled.equals("on")) {
			return emptyList
		}

		val references = referenceFinder.collectReferences(resource, indicator);
		val result = newArrayList
		for (uri : references.keySet) {
			if (uri.trimFragment == resource.URI) {
				val eObject = resource.getEObject(uri.fragment)
				if (eObject instanceof Statement) {
					val kwNode = NodeModelUtils.findActualNodeFor(eObject).leafNodes.filter[grammarElement instanceof Keyword].head
					if (kwNode !== null) {
						val range = documentExtensions.newRange(resource, kwNode.textRegion)
						val locations = references.get(uri).map[ refInfo |
							val eobj = resource.resourceSet.getEObject(refInfo.key, false)
							return documentExtensions.newLocation(eobj, refInfo.value, -1)
						].toList
						result += new CodeLens => [
							it.range = range
							command = new Command => [
								command = 'yang.show.references'
								title = switch count : references.get(uri).size {
									case 1 : '1 reference'
									default : '''«count» references'''
								}
								arguments = newArrayList(
									uri.trimFragment.toString,
									range.start,
									locations
								)
							]
						]
					}
				}
			}
		}
		return result
	}

}