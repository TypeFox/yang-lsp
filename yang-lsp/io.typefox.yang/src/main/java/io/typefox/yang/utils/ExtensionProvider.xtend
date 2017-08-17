package io.typefox.yang.utils

import org.eclipse.xtext.preferences.PreferenceKey
import java.util.List
import com.google.inject.Inject
import io.typefox.yang.settings.PreferenceValuesProvider
import org.eclipse.emf.ecore.resource.Resource
import java.util.Map
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.util.internal.Log

@Log class ExtensionProvider {
	
	@Inject ExtensionClassPathProvider classPathProvider
	@Inject PreferenceValuesProvider preferenceProvider
	
	Map<String, Entry> cache = newHashMap()
	
	@Data static class Entry {
		String configuredValue
		List<?> cachedExtensionObjects
	}
	
	def <T> List<T> getExtensions(PreferenceKey key, Resource res, Class<T> clazz) {
		val preferences = preferenceProvider.getPreferenceValues(res)
		val value = preferences.getPreference(key)
		val previous = cache.get(key)
		if (previous !== null && previous.configuredValue == value) {
			return previous.cachedExtensionObjects as List<T>
		}
		val result = newArrayList()
		val classLoader = classPathProvider.getExtensionLoader(res)
		for (className : value.split(':')) {
			if (!className.isNullOrEmpty) {
				try {
					val extensionClass = classLoader.loadClass(className)
					result.add(extensionClass.newInstance)				
				} catch (Exception e) {
					LOG.error("Could not load extension class '"+className+"'", e)
				}
			}
		}
		cache.put(key.id, new Entry(value, result))
		return result as List<T>
	}
}