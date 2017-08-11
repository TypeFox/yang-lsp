package io.typefox.yang.scoping.xpath

import org.eclipse.xtend.lib.annotations.Accessors

import static io.typefox.yang.scoping.xpath.XpathFunctionLibrary.Type.*

class XpathFunctionLibrary {
	
	public static val FUNCTIONS = #[
		'''
			The last function returns a number equal to the context size from the expression evaluation context.
		'''.fun(NUMBER, 'last')
		
		,'''
			The position function returns a number equal to the context position from the expression evaluation context.
		'''.fun(NUMBER, 'position')
		
		,'''
			The count function returns the number of nodes in the argument node-set.
		'''.fun(NUMBER, 'count', NODE_SET)
		
		,'''
			The id function selects elements by their unique ID (see [5.2.1 Unique IDs]). When the argument to id is of type node-set, then the result is the union of the result of applying id to the string-value of each of the nodes in the argument node-set. When the argument to id is of any other type, the argument is converted to a string as if by a call to the string function; the string is split into a whitespace-separated list of tokens (whitespace is any sequence of characters matching the production S); the result is a node-set containing the elements in the same document as the context node that have a unique ID equal to any of the tokens in the list.
			
			 - `id("foo")` selects the element with unique ID foo
			 - `id("foo")/child::para[position()=5]` selects the fifth para child of the element with unique ID foo
		'''.fun(NODE_SET, 'id', OBJECT)
		
		,'''
			The local-name function returns the local part of the expanded-name of the node in the argument node-set that is first in document order. If the argument node-set is empty or the first node has no expanded-name, an empty string is returned. If the argument is omitted, it defaults to a node-set with the context node as its only member.
		'''.fun(STRING, 'local-name', NODE_SET) => [
			optional = 1
		]
		
		,'''
			The namespace-uri function returns the namespace URI of the expanded-name of the node in the argument node-set that is first in document order. If the argument node-set is empty, the first node has no expanded-name, or the namespace URI of the expanded-name is null, an empty string is returned. If the argument is omitted, it defaults to a node-set with the context node as its only member.
		'''.fun(STRING, 'namespace-uri', NODE_SET) => [
			optional = 1
		]
		
		,'''
			The name function returns a string containing a QName representing the expanded-name of the node in the argument node-set that is first in document order. The QName must represent the expanded-name with respect to the namespace declarations in effect on the node whose expanded-name is being represented. Typically, this will be the QName that occurred in the XML source. This need not be the case if there are namespace declarations in effect on the node that associate multiple prefixes with the same namespace. However, an implementation may include information about the original prefix in its representation of nodes; in this case, an implementation can ensure that the returned string is always the same as the QName used in the XML source. If the argument node-set is empty or the first node has no expanded-name, an empty string is returned. If the argument it omitted, it defaults to a node-set with the context node as its only member.
		'''.fun(STRING, 'name', NODE_SET) => [
			optional = 1
		]
		
		,'''
			The string function converts an object to a string as follows:
			
			 - A node-set is converted to a string by returning the string-value of the node in the node-set that is first in document order. If the node-set is empty, an empty string is returned.
			
			 - A number is converted to a string as follows
			
			 - NaN is converted to the string `NaN`
			
			 - positive zero is converted to the string 0
			
			 - negative zero is converted to the string 0
			
			 - positive infinity is converted to the string Infinity
			
			 - negative infinity is converted to the string -Infinity
			
			 - if the number is an integer, the number is represented in decimal form as a Number with no decimal point and no leading zeros, preceded by a minus sign (-) if the number is negative
			
			 - otherwise, the number is represented in decimal form as a Number including a decimal point with at least one digit before the decimal point and at least one digit after the decimal point, preceded by a minus sign (-) if the number is negative; there must be no leading zeros before the decimal point apart possibly from the one required digit immediately before the decimal point; beyond the one required digit after the decimal point there must be as many, but only as many, more digits as are needed to uniquely distinguish the number from all other IEEE 754 numeric values.
			
			 - The boolean false value is converted to the string false. The boolean true value is converted to the string true.
			
			 - An object of a type other than the four basic types is converted to a string in a way that is dependent on that type.
			
			If the argument is omitted, it defaults to a node-set with the context node as its only member.
		'''.fun(STRING, 'string', OBJECT) => [
			optional = 1
		]
		
		,'''
			The concat function returns the concatenation of its arguments.
		'''.fun(STRING, 'concat', STRING, STRING, STRING) => [
			isVarArg = true
		]
		
		,'''
			The starts-with function returns true if the first argument string starts with the second argument string, and otherwise returns false.
		'''.fun(BOOLEAN, 'starts-with', STRING, STRING)
		
		,'''
			The contains function returns true if the first argument string contains the second argument string, and otherwise returns false.
		'''.fun(BOOLEAN, 'contains', STRING, STRING)
		
		,'''
			The substring-before function returns the substring of the first argument string that precedes the first occurrence of the second argument string in the first argument string, or the empty string if the first argument string does not contain the second argument string. For example, `substring-before("1999/04/01","/")` returns `1999`.
		'''.fun(STRING, 'substring-before', STRING, STRING)
		
		,'''
			The substring-after function returns the substring of the first argument string that follows the first occurrence of the second argument string in the first argument string, or the empty string if the first argument string does not contain the second argument string. For example, `substring-after("1999/04/01","/")` returns `04/01`, and `substring-after("1999/04/01","19")` returns `99/04/01`.
		'''.fun(STRING, 'substring-after', STRING, STRING)
		
		
		,'''
			The substring function returns the substring of the first argument starting at the position specified in the second argument with length specified in the third argument. For example, substring("12345",2,3) returns "234". If the third argument is not specified, it returns the substring starting at the position specified in the second argument and continuing to the end of the string. For example, substring("12345",2) returns "2345".
			
			More precisely, each character in the string (see [3.6 Strings]) is considered to have a numeric position: the position of the first character is 1, the position of the second character is 2 and so on.
			
			NOTE: This differs from Java and ECMAScript, in which the String.substring method treats the position of the first character as 0.
			The returned substring contains those characters for which the position of the character is greater than or equal to the rounded value of the second argument and, if the third argument is specified, less than the sum of the rounded value of the second argument and the rounded value of the third argument; the comparisons and addition used for the above follow the standard IEEE 754 rules; rounding is done as if by a call to the round function. The following examples illustrate various unusual cases:
			
			 - `substring("12345", 1.5, 2.6)` returns `"234"`
			
			 - `substring("12345", 0, 3)` returns `"12"`
			
			 - `substring("12345", 0 div 0, 3)` returns `""`
			
			 - `substring("12345", 1, 0 div 0)` returns `""`
			
			 - `substring("12345", -42, 1 div 0)` returns `"12345"`
			
			 - `substring("12345", -1 div 0, 1 div 0)` returns `""`
		'''.fun(STRING, 'substring', STRING, NUMBER, NUMBER) => [
			optional = 1
		]
		
		,'''
			The string-length returns the number of characters in the string (see [3.6 Strings]). If the argument is omitted, it defaults to the context node converted to a string, in other words the string-value of the context node.
		'''.fun(NUMBER, 'string-length', STRING) => [
			optional = 1
		]
		
		,'''
			The normalize-space function returns the argument string with whitespace normalized by stripping leading and trailing whitespace and replacing sequences of whitespace characters by a single space. Whitespace characters are the same as those allowed by the S production in XML. If the argument is omitted, it defaults to the context node converted to a string, in other words the string-value of the context node.
		'''.fun(STRING, 'normalize-space', STRING) => [
			optional = 1
		]
		
		,'''
			The translate function returns the first argument string with occurrences of characters in the second argument string replaced by the character at the corresponding position in the third argument string. For example, translate("bar","abc","ABC") returns the string BAr. If there is a character in the second argument string with no character at a corresponding position in the third argument string (because the second argument string is longer than the third argument string), then occurrences of that character in the first argument string are removed. For example, translate("--aaa--","abc-","ABC") returns "AAA". If a character occurs more than once in the second argument string, then the first occurrence determines the replacement character. If the third argument string is longer than the second argument string, then excess characters are ignored.
		'''.fun(STRING, 'translate', STRING, STRING, STRING)
		
		,'''
			The boolean function converts its argument to a boolean as follows:
			
			 - a number is true if and only if it is neither positive or negative zero nor NaN
			
			 - a node-set is true if and only if it is non-empty
			
			 - a string is true if and only if its length is non-zero
			
			 - an object of a type other than the four basic types is converted to a boolean in a way that is dependent on that type
		'''.fun(BOOLEAN, 'boolean', OBJECT)
		
		
		,'''
			The not function returns true if its argument is false, and false otherwise.
		'''.fun(BOOLEAN, 'not', BOOLEAN)
		
		,'''
			The true function returns true.
		'''.fun(BOOLEAN, 'true')
		
		,'''
			The false function returns false.
		'''.fun(BOOLEAN, 'false')
		
		,'''
			The lang function returns true or false depending on whether the language of the context node as specified by xml:lang attributes is the same as or is a sublanguage of the language specified by the argument string. The language of the context node is determined by the value of the xml:lang attribute on the context node, or, if the context node has no xml:lang attribute, by the value of the xml:lang attribute on the nearest ancestor of the context node that has an xml:lang attribute. If there is no such attribute, then lang returns false. If there is such an attribute, then lang returns true if the attribute value is equal to the argument ignoring case, or if there is some suffix starting with - such that the attribute value is equal to the argument ignoring that suffix of the attribute value and ignoring case. For example, lang("en") would return true if the context node is any of these five elements:
			```
			<para xml:lang="en"/>
			<div xml:lang="en"><para/></div>
			<para xml:lang="EN"/>
			<para xml:lang="en-us"/>
			``
		'''.fun(BOOLEAN, 'lang', STRING)
		
		
		,'''
			The number function converts its argument to a number as follows:
			
			 - a string that consists of optional whitespace followed by an optional minus sign followed by a Number followed by whitespace is converted to the IEEE 754 number that is nearest (according to the IEEE 754 round-to-nearest rule) to the mathematical value represented by the string; any other string is converted to NaN
			
			 - boolean true is converted to 1; boolean false is converted to 0
			
			 - a node-set is first converted to a string as if by a call to the string function and then converted in the same way as a string argument
			
			 - an object of a type other than the four basic types is converted to a number in a way that is dependent on that type
			
			If the argument is omitted, it defaults to a node-set with the context node as its only member.
			
			 - NOTE: The number function should not be used for conversion of numeric data occurring in an element in an XML document unless the element is of a type that represents numeric data in a language-neutral format (which would typically be transformed into a language-specific format for presentation to a user). In addition, the number function cannot be used unless the language-neutral format used by the element is consistent with the XPath syntax for a Number.
		'''.fun(NUMBER, 'number', OBJECT)
		
		,'''
			The sum function returns the sum, for each node in the argument node-set, of the result of converting the string-values of the node to a number.
		'''.fun(NUMBER, 'sum', NODE_SET)
		
		,'''
			The floor function returns the largest (closest to positive infinity) number that is not greater than the argument and that is an integer.
		'''.fun(NUMBER, 'floor', NUMBER)
		
		,'''
			The ceiling function returns the smallest (closest to negative infinity) number that is not less than the argument and that is an integer.
		'''.fun(NUMBER, 'ceiling', NUMBER)
		
		,'''
			The round function returns the number that is closest to the argument and that is an integer. If there are two such numbers, then the one that is closest to positive infinity is returned. If the argument is NaN, then NaN is returned. If the argument is positive infinity, then positive infinity is returned. If the argument is negative infinity, then negative infinity is returned. If the argument is positive zero, then positive zero is returned. If the argument is negative zero, then negative zero is returned. If the argument is less than zero, but greater than or equal to -0.5, then negative zero is returned.
			
			 - NOTE: For these last two cases, the result of calling the round function is not the same as the result of adding 0.5 and then calling the floor function.
		'''.fun(NUMBER, 'round', NUMBER)
		
		// from YANG
		,'''
			The current() function takes no input parameters and returns a node set with the initial context node as its only member.
		'''.fun(NODE_SET, 'current')
		
		,'''
			The re-match() function returns `true` if the first argument string matches the regular expression (second argument); otherwise, it returns `false`.
		'''.fun(BOOLEAN, 're-match', STRING, STRING)
		
		,'''
			The deref() function follows the reference defined by the first node in document order in the argument "nodes" and returns the nodes it refers to.
			
			If the first argument node is of type "instance-identifier", the function returns a node set that contains the single node that the instance identifier refers to, if it exists.  If no such node exists, an empty node set is returned.
			
			If the first argument node is of type "leafref", the function returns a node set that contains the nodes that the leafref refers to. Specifically, this set contains the nodes selected by the leafref's "path" statement (Section 9.9.2) that have the same value as the first argument node.
			
			If the first argument node is of any other type, an empty node set is returned.
		'''.fun(NODE_SET, 'deref', NODE_SET)
		
		,'''
			The derived-from() function returns "true" if any node in the
			   argument "nodes" is a node of type "identityref" and its value is an
			   identity that is derived from (see Section 7.18.2) the identity
			   "identity"; otherwise, it returns "false".
			
			   The parameter "identity" is a string matching the rule
			   "identifier-ref" in Section 14.  If a prefix is present on the
			   identity, it refers to an identity defined in the module that was
			   imported with that prefix, or the local module if the prefix matches
			   the local module's prefix.  If no prefix is present, the identity
			   refers to an identity defined in the current module or an included
			   submodule.
		'''.fun(BOOLEAN, 'derived-from', NODE_SET, STRING)
		
		,'''
			The derived-from-or-self() function returns "true" if any node in the
			   argument "nodes" is a node of type "identityref" and its value is an
			   identity that is equal to or derived from (see Section 7.18.2) the
			   identity "identity"; otherwise, it returns "false".
			
			   The parameter "identity" is a string matching the rule
			   "identifier-ref" in Section 14.  If a prefix is present on the
			   identity, it refers to an identity defined in the module that was
			   imported with that prefix, or the local module if the prefix matches
			   the local module's prefix.  If no prefix is present, the identity
			   refers to an identity defined in the current module or an included
			   submodule.
		'''.fun(BOOLEAN, 'derived-from-or-self', NODE_SET, STRING)
		
		,'''
			The enum-value() function checks to see if the first node in document
			   order in the argument "nodes" is a node of type "enumeration" and
			   returns the enum's integer value.  If the "nodes" node set is empty
			   or if the first node in "nodes" is not of type "enumeration", it
			   returns NaN (not a number).
		'''.fun(NUMBER, 'enum-value', NODE_SET)
		
		,'''
			The bit-is-set() function returns "true" if the first node in
			   document order in the argument "nodes" is a node of type "bits" and
			   its value has the bit "bit-name" set; otherwise, it returns "false".
			   
			
		'''.fun(BOOLEAN, 'bit-is-set', NODE_SET, STRING)
	].toMap[name]
	
	
	
	private static def Function fun(CharSequence documentation, Type returnType, String name, Type... parameters) {
		new Function() => [
			it.documentation = documentation.toString
			it.name = name
			it.returnType = returnType
			it.paramTypes = parameters
		]
	}
	
	static enum Type {
		STRING,
		BOOLEAN,
		NUMBER,
		NODE_SET,
		OBJECT
	}
	
	@Accessors static class Function {
		String name
		String documentation
		Type returnType
		Type[] paramTypes
		int optional = 0
		boolean isVarArg = false
	}
}