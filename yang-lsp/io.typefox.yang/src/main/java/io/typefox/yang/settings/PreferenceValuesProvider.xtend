package io.typefox.yang.settings

import com.google.inject.Inject
import java.nio.file.FileSystems
import java.util.Map
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.LanguageInfo
import org.eclipse.xtext.preferences.IPreferenceValues
import org.eclipse.xtext.preferences.IPreferenceValuesProvider
import org.eclipse.xtext.preferences.MapBasedPreferenceValues
import org.eclipse.xtext.preferences.PreferenceValuesByLanguage
import org.eclipse.xtext.workspace.IProjectConfigProvider

class PreferenceValuesProvider implements IPreferenceValuesProvider {
	
	@Inject(optional=true) IProjectConfigProvider configProvider
	@Inject LanguageInfo language
	
	override IPreferenceValues getPreferenceValues(Resource context) {
		if (context === null) {
			return new MapBasedPreferenceValues(emptyMap) 
		}
		var valuesByLanguage = PreferenceValuesByLanguage.findInEmfObject(context.getResourceSet()) ?: new PreferenceValuesByLanguage()
		valuesByLanguage.attachToEmfObject(context.resourceSet)
		 
		var values = valuesByLanguage.get(language.getLanguageName()) ?:
					 createPreferenceValues(context) 
		if (values instanceof JsonFileBasedPreferenceValues) {
			values.checkUpToDate
		} 
		return values 
	}
	
	protected def IPreferenceValues createPreferenceValues(Resource resource) {
		var result = new MapBasedPreferenceValues(constantSettings)
		val fs = FileSystems.^default
		val userSettings = fs.getPath("~/.yang/yang.settings")
		result = new JsonFileBasedPreferenceValues(userSettings, result)
		if (configProvider === null) {
			return result
		}
		val config = configProvider.getProjectConfig(resource.resourceSet)
		// add workspace settings
		val segmentsToRemove = if (config.path.lastSegment.isEmpty) 2 else 1 
		val workspaceSettings = fs.getPath(config.path.trimSegments(segmentsToRemove).toFileString, "yang.settings")
		result = new JsonFileBasedPreferenceValues(workspaceSettings, result)
		// add project settings
		val projectSettings = fs.getPath(config.path.toFileString, "yang.settings")
		result = new JsonFileBasedPreferenceValues(projectSettings, result)
		return result
	}
	
	static val Map<String,String> constantSettings = newHashMap()
	
}