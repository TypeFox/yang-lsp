package io.typefox.yang

import com.google.inject.Inject
import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.conversion.IValueConverter
import org.eclipse.xtext.conversion.ValueConverter
import org.eclipse.xtext.conversion.ValueConverterException
import org.eclipse.xtext.conversion.impl.AbstractDeclarativeValueConverterService
import org.eclipse.xtext.nodemodel.INode

import static extension io.typefox.yang.utils.YangStringUtils.*
import org.eclipse.xtend.lib.annotations.Accessors

class YangValueConverterService extends AbstractDeclarativeValueConverterService {

	
	@Inject StringConverter stringValueConverter;
	
	@ValueConverter(rule="io.typefox.yang.Yang.StringValue")
	def IValueConverter<String> StringValue() {
		return stringValueConverter;
	}
	
	@ValueConverter(rule="StringValue")
	def IValueConverter<String> StringValue2() {
		return stringValueConverter;
	}
	
	static class StringConverter implements IValueConverter<String>, IValueConverter.RuleSpecific {
		public static val char[] QUOTES = #['"',"'"]
		
		override toString(String value) throws ValueConverterException {
			return value.addQuotesIfNecessary
		}
		
		
		override toValue(String string, INode node) throws ValueConverterException {
			val result = new StringBuilder
			for (n : node.leafNodes) {
				if (!n.hidden) {
					val seg = n.text
					if (isQuoted(seg)) {
						val inner = seg.substring(1, seg.length-1)
						if (seg.startsWith("\"")) {
							result.append(unescapeYangDoubleQuoted(inner))
						} else {
							result.append(inner)
						}
					} else {
						result.append(seg)
					}
				}
			}
			return result.toString
		}
		
		/**
		 * Process YANG double-quoted string escape sequences per RFC 7950 Section 6.1.3.
		 */
		def static String unescapeYangDoubleQuoted(String s) {
			val bsIndex = s.indexOf('\\')
			if (bsIndex < 0) return s
			val sb = new StringBuilder(s.length)
			sb.append(s, 0, bsIndex)
			var i = bsIndex
			while (i < s.length) {
				val c = s.charAt(i)
				if (c === 0x5C && i + 1 < s.length) {
					val next = s.charAt(i + 1)
					if (next === 0x6E) { sb.append('\n'); i += 2 }
					else if (next === 0x74) { sb.append('\t'); i += 2 }
					else if (next === 0x22) { sb.append('"'); i += 2 }
					else if (next === 0x5C) { sb.append('\\'); i += 2 }
					else { sb.append(c); i++ }
				} else {
					sb.append(c)
					i++
				}
			}
			return sb.toString
		}
		
		def static boolean isQuoted(String text) {
			if(text.length < 2) {
				return false
			}
			val first = text.charAt(0)
			return QUOTES.contains(first) && text.charAt(text.length-1) === first
		}
		
		@Accessors AbstractRule rule
	}	
	
	@Inject NumberConverter numberValueConverter;
	
	@ValueConverter(rule="io.typefox.yang.Yang.NUMBER")
	def IValueConverter<String> NUMBERValue() {
		return numberValueConverter;
	}
	
	@ValueConverter(rule="NUMBER")
	def IValueConverter<String> NUMBERValue2() {
		return numberValueConverter;
	}
	
	static class NumberConverter implements IValueConverter<String>, IValueConverter.RuleSpecific {
		
		override toString(String value) throws ValueConverterException {
			return value
		}
		
		override toValue(String string, INode node) throws ValueConverterException {
			try {
				Double.parseDouble(string);
			} catch (NumberFormatException e) {
				throw new ValueConverterException("Couldn't convert '" + string + "' to an double value.", node, e);
			}
			return string
		}
		
		@Accessors AbstractRule rule
	}
	
	@Inject SimpleStringConverter simpleStringConverter;
	
	@ValueConverter(rule="io.typefox.yang.Yang.STRING")
	def IValueConverter<String> STRINGValue() {
		return simpleStringConverter;
	}
	
	@ValueConverter(rule="STRING")
	def IValueConverter<String> STRINGValue2() {
		return simpleStringConverter;
	}
	
	static class SimpleStringConverter implements IValueConverter<String>, IValueConverter.RuleSpecific {
		
		override toString(String value) throws ValueConverterException {
			return value
		}
		
		override toValue(String string, INode node) throws ValueConverterException {
			return string
		}
		
		@Accessors AbstractRule rule
	}
}