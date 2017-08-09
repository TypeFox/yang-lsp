package io.typefox.yang.utils

import com.google.common.base.Splitter
import com.google.inject.Inject
import java.net.URL
import java.net.URLClassLoader
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.preferences.IPreferenceValuesProvider
import org.eclipse.xtext.preferences.PreferenceKey
import org.eclipse.xtext.util.internal.EmfAdaptable
import org.eclipse.xtext.workspace.IProjectConfigProvider

class ExtensionClassPathProvider {
	
	public static val CLASS_PATH = new PreferenceKey("extension.classpath", "")
	
	@Inject IPreferenceValuesProvider preferenceProvider
	@Inject IProjectConfigProvider projectConfigProvider
	
	def ClassLoader getExtensionLoader(Resource resource) {
		val prefs = preferenceProvider.getPreferenceValues(resource)
		val classpath = prefs.getPreference(CLASS_PATH)
		if (classpath.isNullOrEmpty) {
			return this.class.classLoader
		}
		val adapter = ClassLoaderAdapter.findInEmfObject(resource.resourceSet)
			?: (new ClassLoaderAdapter() => [
				attachToEmfObject(resource.resourceSet)
			])
		if (adapter.classpath != classpath) {
			val conf = projectConfigProvider.getProjectConfig(resource.resourceSet)
			val urls = Splitter.on(":").split(classpath).map[
					new URL(conf.path.appendSegment(it).toString)
			].toList.toArray(newArrayOfSize(0))
			
			adapter.classLoader = new URLClassLoader(urls)
			adapter.classpath = classpath
		}
		return adapter.classLoader
	}
	
	@EmfAdaptable @Accessors static class ClassLoaderAdapter {
		String classpath
		ClassLoader classLoader
	}
	
}