package io.typefox.yang.utils

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.preferences.IPreferenceValuesProvider
import org.eclipse.xtext.preferences.PreferenceKey
import java.net.URLClassLoader
import com.google.common.base.Splitter
import java.net.URL

class ExtensionClassPathProvider {
	
	static val CLASS_PATH = new PreferenceKey("extension.classpath", "")
	
	@Inject IPreferenceValuesProvider preferenceProvider
	
	def ClassLoader getExtensionLoader(Resource resource) {
		val prefs = preferenceProvider.getPreferenceValues(resource)
		val prop = prefs.getPreference(CLASS_PATH)
		if (prop.isNullOrEmpty) {
			return this.class.classLoader
		}
		val urls = Splitter.on(":").split(prop).map[new URL(it)].toList.toArray(newArrayOfSize(0))
		return new URLClassLoader(urls)
	}
}