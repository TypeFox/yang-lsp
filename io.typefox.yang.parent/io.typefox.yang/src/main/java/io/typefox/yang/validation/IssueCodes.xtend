package io.typefox.yang.validation

import java.util.Map
import org.eclipse.xtext.preferences.PreferenceKey
import org.eclipse.xtext.validation.ConfigurableIssueCodesProvider
import org.eclipse.xtext.validation.SeverityConverter

class IssueCodes extends ConfigurableIssueCodesProvider {
	public static val UNKNOWN_REVISION = 'unknown_revision'
	public static val MISSING_PREFIX = 'missing_prefix'
	
	private static Map<String,PreferenceKey> codes = #{
		error(UNKNOWN_REVISION),
		error(MISSING_PREFIX)
	}
	
	private static def Pair<String, PreferenceKey> error(String code) {
		code -> new PreferenceKey(code, SeverityConverter.SEVERITY_ERROR)
	}
	
	override getConfigurableIssueCodes() {
		codes
	}
	
}
