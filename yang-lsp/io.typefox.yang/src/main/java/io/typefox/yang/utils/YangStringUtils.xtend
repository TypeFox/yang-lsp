package io.typefox.yang.utils

import java.util.regex.Pattern
import org.eclipse.xtext.conversion.ValueConverterException

class YangStringUtils {
	
	static Pattern ID_MATCH = Pattern.compile("[\\s'\";\\{\\}]");
	static Pattern SINGLE_QUTOTE_MATCH = Pattern.compile("'");
	static Pattern DOUBLE_QUTOTE_MATCH = Pattern.compile('"');
		
	static def addQuotesIfNecessary(String value) throws ValueConverterException {
		if (value.empty)
			return '""'
		if (ID_MATCH.matcher(value).find) {
			val hasSingleQuotes = SINGLE_QUTOTE_MATCH.matcher(value).find
			val hasDoubleQuotes = DOUBLE_QUTOTE_MATCH.matcher(value).find
			if (hasSingleQuotes) {
				if(hasDoubleQuotes)
					return addQuotesAndBackslashes(value)
				else 
					return '"' + value + '"'
			} else {
				return "'" + value + "'"
			} 
		}
		return value
	}
	
	static private def addQuotesAndBackslashes(String value) {
		val b = new StringBuilder()
		b.append('"')
		var char lastChar = 0 as char; 
		for(var i=0; i<value.length; i++) {
			val ch = value.charAt(i)
			if (ch === 34 && lastChar !== 92) 
				b.append('\\')
			b.append(ch)
			lastChar = ch  
		}
		b.append('"')
		return b.toString
	}
}