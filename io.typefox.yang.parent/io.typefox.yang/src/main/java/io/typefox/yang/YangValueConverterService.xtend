package io.typefox.yang

import com.google.inject.Inject
import org.eclipse.xtext.conversion.IValueConverter
import org.eclipse.xtext.conversion.ValueConverter
import org.eclipse.xtext.conversion.ValueConverterException
import org.eclipse.xtext.conversion.impl.AbstractDeclarativeValueConverterService
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.AbstractRule

class YangValueConverterService extends AbstractDeclarativeValueConverterService{
	
	@Inject
	private StringConverter stringValueConverter;
	
	@ValueConverter(rule = "io.typefox.yang.Yang.StringValue")
	public def IValueConverter<String> StringValue() {
		return stringValueConverter;
	}
	
	static class StringConverter implements IValueConverter<String>, IValueConverter.RuleSpecific {
		
		override toString(String value) throws ValueConverterException {
			if (value.contains(" ")) {
				return '"'+value+'"' //TODO proper escaping
			}
			return  ""
		}
		
		static val char[] quotes = newCharArrayOfSize(2) => [
			set(0, '"')
			set(1,'\'')
		]
		override toValue(String string, INode node) throws ValueConverterException {
			val result = new StringBuilder
			for (n : node.leafNodes) {
				if (!n.hidden) {
					val seg = n.text 					
					if (seg.length>=2) {
						val first = seg.charAt(0)
						if (quotes.contains(first) && string.charAt(seg.length-1) === first) {
							result.append(seg.substring(1, seg.length-1))
						} else {
							result.append(seg)
						}
					} else {
						result.append(seg)
					}
				}
			}
			return result.toString
		}
		
		AbstractRule rule
		
		override setRule(AbstractRule rule) throws IllegalArgumentException {
			this.rule = rule
		}
		
	}
}