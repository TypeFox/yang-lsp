package io.typefox.yang.tests.settings

import com.google.inject.Inject
import io.typefox.yang.settings.PreferenceValuesProvider
import io.typefox.yang.tests.YangInjectorProvider
import java.io.File
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.xtext.preferences.PreferenceKey
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.workspace.FileProjectConfig
import org.eclipse.xtext.workspace.ProjectConfigAdapter
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import io.typefox.yang.settings.JsonFileBasedPreferenceValues

@InjectWith(YangInjectorProvider)
@RunWith(XtextRunner)
class SettingsProviderTest {
	
	@Inject PreferenceValuesProvider settingsProvider
	
	@Test def void testSingleSettings() {
		val rs = new ResourceSetImpl();
		val root = new File("./src/test/resources").canonicalFile
		ProjectConfigAdapter.install(rs, new FileProjectConfig(root))
		
		val resource = rs.createResource(URI.createFileURI(root.toString).appendSegment("myresource.yang"))
		val preferences = settingsProvider.getPreferenceValues(resource)
		Assert.assertEquals("error", preferences.getPreference(new PreferenceKey("diagnostics.foo", "info")))
		Assert.assertEquals("info", preferences.getPreference(new PreferenceKey("diagnostics.bar", "info")))
	}
	
	@Test def void testProjectShadows() {
		val rs = new ResourceSetImpl();
		val root = new File("./src/test/resources/project").canonicalFile
		ProjectConfigAdapter.install(rs, new FileProjectConfig(root))
		
		val resource = rs.createResource(URI.createFileURI(root.toString).appendSegment("myresource.yang"))
		val preferences = settingsProvider.getPreferenceValues(resource)
		Assert.assertEquals("info", preferences.getPreference(new PreferenceKey("diagnostics.foo", "x")))
		Assert.assertEquals("error", preferences.getPreference(new PreferenceKey("diagnostics.bar", "x")))
		Assert.assertEquals("error", preferences.getPreference(new PreferenceKey("diagnostics.baz", "x")))
	}
	
	@Test def void testSettingsUpdate() {
		val rs = new ResourceSetImpl();
		val root = new File("./src/test/resources/project").canonicalFile
		ProjectConfigAdapter.install(rs, new FileProjectConfig(root))
		val resource = rs.createResource(URI.createFileURI(root.toString).appendSegment("myresource.yang"))
		val preferences = settingsProvider.getPreferenceValues(resource) as JsonFileBasedPreferenceValues
		Assert.assertEquals("info", preferences.getPreference(new PreferenceKey("diagnostics.foo", "x")))
		Assert.assertEquals("error", preferences.getPreference(new PreferenceKey("diagnostics.bar", "x")))
		Assert.assertEquals("error", preferences.getPreference(new PreferenceKey("diagnostics.baz", "x")))
		val workspaceSettings = new File(root, "yang.settings")
		val tempRenamed = new File(root, "temp.yang.settings")
		try {
			workspaceSettings.renameTo(tempRenamed)
			preferences.checkUpToDate
			Assert.assertEquals("error", preferences.getPreference(new PreferenceKey("diagnostics.foo", "x")))
			Assert.assertEquals("x", preferences.getPreference(new PreferenceKey("diagnostics.bar", "x")))
			Assert.assertEquals("error", preferences.getPreference(new PreferenceKey("diagnostics.baz", "x")))
		} finally {
			tempRenamed.renameTo(workspaceSettings)
		}
		preferences.checkUpToDate
		Assert.assertEquals("info", preferences.getPreference(new PreferenceKey("diagnostics.foo", "x")))
		Assert.assertEquals("error", preferences.getPreference(new PreferenceKey("diagnostics.bar", "x")))
		Assert.assertEquals("error", preferences.getPreference(new PreferenceKey("diagnostics.baz", "x")))
	}
}