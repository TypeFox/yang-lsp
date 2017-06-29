package io.typefox.yang.validation

import java.util.Map
import org.eclipse.xtext.preferences.PreferenceKey
import org.eclipse.xtext.validation.ConfigurableIssueCodesProvider
import org.eclipse.xtext.validation.SeverityConverter

class IssueCodes extends ConfigurableIssueCodesProvider {
	public static val UNKNOWN_REVISION = 'UNKNOWN_REVISION'
	public static val DUPLICATE_NAME = 'DUPLICATE_NAME'
	public static val MISSING_PREFIX = 'MISSING_PREFIX'
	public static val MISSING_REVISION = 'MISSING_REVISION'
	public static val IMPORT_NOT_A_MODULE = 'IMPORT_NOT_A_MODULE'
	public static val INCLUDE_NOT_A_SUB_MODULE = 'INCLUDE_NOT_A_SUB_MODULE'
	public static val INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE = 'INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE'
	
	private static Map<String,PreferenceKey> codes = #{
		error(UNKNOWN_REVISION),
		error(DUPLICATE_NAME),
		error(MISSING_PREFIX),
		warn(MISSING_REVISION),
		error(IMPORT_NOT_A_MODULE),
		error(INCLUDE_NOT_A_SUB_MODULE),
		error(INCLUDED_SUB_MODULE_BELONGS_TO_DIFFERENT_MODULE)
	}
	
	private static def Pair<String, PreferenceKey> error(String code) {
		code -> new PreferenceKey(code, SeverityConverter.SEVERITY_ERROR)
	}
	
	private static def Pair<String, PreferenceKey> warn(String code) {
		code -> new PreferenceKey(code, SeverityConverter.SEVERITY_WARNING)
	}
	
	override getConfigurableIssueCodes() {
		codes
	}
	
}
