package io.typefox.yang.parser.antlr.lexer.jflex

import java.io.FileReader
import org.antlr.runtime.Token
import io.typefox.yang.parser.antlr.internal.InternalYangParser
import java.util.regex.Pattern

class YangFix {
	
	static val CONCAT_PATTERN = Pattern.compile('(\"\\s*\\+\\s*\"|\'\\s*\\+\\s*\')')
	
	def static void main(String[] args) {
		val reader = new FileReader(args.get(0))
		val yangFlexer = new YangFlexer(reader)
		var stop = false
		var lastHidden = ''
		do {
			val token  = yangFlexer.nextToken
			if(token.type === Token.EOF) 
				stop = true
			if (token.type == InternalYangParser.RULE_HIDDEN) {
				lastHidden += token.text
			} else {
				if(!lastHidden.empty && !CONCAT_PATTERN.matcher(lastHidden).matches) 
					print(lastHidden)
				lastHidden = ''
				if(token.text !== null)
					print(token.text)
			}				
		} while (!stop)
	}
}