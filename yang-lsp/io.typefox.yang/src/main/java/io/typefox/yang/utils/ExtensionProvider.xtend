package io.typefox.yang.utils

import com.google.inject.Inject
import com.google.inject.Injector
import io.typefox.yang.settings.PreferenceValuesProvider
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.preferences.PreferenceKey
import org.eclipse.xtext.util.internal.Log

@Log class ExtensionProvider {
	
	@Inject ExtensionClassPathProvider classPathProvider
	@Inject PreferenceValuesProvider preferenceProvider
	@Inject Injector injector
	
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
					val extensionInstance = extensionClass.newInstance
					injector.injectMembers(extensionInstance)
					result.add(extensionInstance)				
				} catch (Exception e) {
					LOG.error("Could not load extension class '"+className+"'", e)
				}
			}
		}
		cache.put(key.id, new Entry(value, result))
		return result as List<T>
	}
}