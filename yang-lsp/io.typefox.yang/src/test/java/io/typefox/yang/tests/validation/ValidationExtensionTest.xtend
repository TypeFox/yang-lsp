package io.typefox.yang.tests.validation

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test
import org.eclipse.xtext.preferences.PreferenceValuesByLanguage
import com.google.inject.Inject
import org.eclipse.xtext.LanguageInfo
import org.eclipse.xtext.preferences.MapBasedPreferenceValues
import io.typefox.yang.validation.ResourceValidator

class ValidationExtensionTest extends AbstractYangTest {
	
	@Inject LanguageInfo language
	
	@Test def void testExtensionNotRegistered() {
		val m  = load('''
			module foo {
				
			}
		''')
		assertNoErrors(m.root, MyValidatorExtension.BAD_NAME)
	}
	
	@Test def void testExtensionRegistered() {
		val prefByLang = new PreferenceValuesByLanguage()
		prefByLang.attachToEmfObject(resourceSet)
		prefByLang.put(language.languageName, new MapBasedPreferenceValues(#{
			ResourceValidator.VALIDATORS.id -> MyValidatorExtension.name
		}))
		
		val m  = load('''
			module foo {
				
			}
		''')
		assertError(m.root, MyValidatorExtension.BAD_NAME)
	}
}