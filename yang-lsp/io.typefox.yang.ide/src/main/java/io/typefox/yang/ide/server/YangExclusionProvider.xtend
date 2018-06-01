package io.typefox.yang.ide.server

import io.typefox.yang.settings.PreferenceValuesProvider
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.preferences.IPreferenceValues
import org.eclipse.xtext.preferences.PreferenceKey
import io.typefox.yang.settings.JsonFileBasedPreferenceValues

class YangExclusionProvider {
	
	static val EXCLUSION_PATHS = new PreferenceKey("excludePath", "")

	Map<URI, IPreferenceValues> preferences = newHashMap
	
	def isExcluded(URI uri, URI projectURI) {
		val uriAsString = uri.toString
		val excludedSegments = getPreferences(projectURI).getPreference(EXCLUSION_PATHS) 
		if (excludedSegments !== null && !excludedSegments.empty) {
			val truncatedProjectURI = if (projectURI.lastSegment.empty) projectURI.trimSegments(1) else projectURI 
			val excludedPaths = excludedSegments.split(':').map[ path |
				truncatedProjectURI
					.appendSegments(path.split('/').filter[!empty])
					.appendSegment('')
					.toString
			]
			return excludedPaths.exists[
				uriAsString.startsWith(it)
			]
		}
		return false
	}

	private def getPreferences(URI projectURI) {
		val prefs = preferences.get(projectURI) ?: {
			val newPrefs = PreferenceValuesProvider.createPreferenceValues(projectURI)
			preferences.put(projectURI, newPrefs)
			newPrefs
		}
		if (prefs instanceof JsonFileBasedPreferenceValues)
			prefs.checkIsUpToDate
		prefs
	}
}
