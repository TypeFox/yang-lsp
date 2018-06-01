package io.typefox.yang.settings

import com.google.common.base.StandardSystemProperty
import com.google.inject.Inject
import java.net.URI
import java.nio.file.Paths
import java.util.List
import java.util.Map
import javax.inject.Singleton
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.LanguageInfo
import org.eclipse.xtext.preferences.IPreferenceValues
import org.eclipse.xtext.preferences.IPreferenceValuesProvider
import org.eclipse.xtext.preferences.MapBasedPreferenceValues
import org.eclipse.xtext.preferences.PreferenceValuesByLanguage
import org.eclipse.xtext.util.IDisposable
import org.eclipse.xtext.util.internal.Log
import org.eclipse.xtext.workspace.IProjectConfigProvider

@Log
@Singleton
class PreferenceValuesProvider implements IPreferenceValuesProvider {
	
	@Inject(optional=true) IProjectConfigProvider configProvider
	@Inject LanguageInfo language
	List<(IPreferenceValues, Resource)=>void> onChangeListeners = newArrayList
	
	override IPreferenceValues getPreferenceValues(Resource context) {
		if (context === null) {
			return new MapBasedPreferenceValues(emptyMap) 
		}
		val valuesByLanguage = PreferenceValuesByLanguage.findInEmfObject(context.resourceSet) 
			?: (new PreferenceValuesByLanguage() => [
				attachToEmfObject(context.resourceSet)	
			])
		
		var values = valuesByLanguage.get(language.getLanguageName()) ?:
					 createPreferenceValues(configProvider?.getProjectConfig(context.resourceSet)?.path)
		valuesByLanguage.put(language.languageName, values)

		if (values instanceof JsonFileBasedPreferenceValues) {
			if (!values.checkIsUpToDate) {
				for (listener : onChangeListeners) {
					listener.apply(values, context)
				}
			}
		} 
		return values 
	}

	static def IPreferenceValues createPreferenceValues(org.eclipse.emf.common.util.URI projectURI) {
		var result = new MapBasedPreferenceValues(constantSettings)
		val userHome = Paths.get(StandardSystemProperty.USER_HOME.value)
		val userSettings = userHome.resolve(".yang").resolve("yang.settings")
		result = new JsonFileBasedPreferenceValues(userSettings, result)
		if (projectURI === null) {
			return result
		}
		val segmentsToRemove = if (projectURI.lastSegment.isEmpty) 1 else 0
		
		// add workspace settings
		val workspaceDirectory = new URI(projectURI.trimSegments(segmentsToRemove + 1).toString)
		val workspaceSettings = Paths.get(workspaceDirectory).resolve("yang.settings")
		result = new JsonFileBasedPreferenceValues(workspaceSettings, result)
		
		// add project settings
		val projectDirectory = new URI(projectURI.trimSegments(segmentsToRemove).toString)
		val projectSettings = Paths.get(projectDirectory).resolve("yang.settings")
		result = new JsonFileBasedPreferenceValues(projectSettings, result)
		return result
	}
	
	public static val Map<String,String> constantSettings = newHashMap()
	
	def IDisposable registerChangeListener((IPreferenceValues, Resource)=>void callback) {
		this.onChangeListeners.add(callback)
		return [
			this.onChangeListeners.remove(callback)
		]
	} 
}