package io.typefox.yang.parser.antlr.lexer.jflex

import java.io.File
import java.nio.file.Files
import org.eclipse.xtend.lib.annotations.Data

class FlexGenerator {
	
	def static void main(String[] args) {
		Files.write(
			new File('''./src/main/java/«FlexGenerator.package.name.replace('.','/')»/YangFlexer.flex''').toPath, 
			new FlexGenerator().generate().toString.bytes
		)
	}
	
	@Data static class ExpressionMode {
		String name
		String commonElements
		boolean canContainString
	} 
	
	
	val predefinedRules = '''
		WS=[\ \n\r\t]+
		
		ML_COMMENT="/*" ~"*/"
		SL_COMMENT="/""/"[^\r\n]*(\r?\n)?
		
		ID= [a-zA-Z_] [a-zA-Z0-9_\.\-]*
		
		EXTENSION_NAME={ID} ":" {ID}
		
		STRING=[^\ \n\r\t\{\}\;\'\"]+
		SINGLE_QUOTED_STRING= "'" [^']* "'"?
		DOUBLE_QUOTED_STRING= \" ([^\\\"]|\\.)* \"?
		ESCAPED_DQ_STRING= \\\" [^\\\"]* \\\"?
		
		NUMBER= ("+"|"-")? {U_NUMBER}
		U_NUMBER= [0-9]+ ("." [0-9]+)? | "." [0-9]+
		
		OPERATOR= "and" | "or" | "mod" | "div" | "*" | "|" | "+" | "-" | "=" | "!=" | "<" | "<=" | ">" | ">="
		
		STRING_CONCAT= ({WS} | {ML_COMMENT} | {SL_COMMENT})* "+" ({WS} | {ML_COMMENT} | {SL_COMMENT})*
	'''
	
	val GenericExpressionMode = new ExpressionMode('EXPRESSION','''
		{OPERATOR}  { return RULE_OPERATOR; }
		"binary"                {return Binary;}
		"bits"                  {return Bits;}
		"boolean"               {return Boolean;}
		"decimal64"             {return Decimal64;}
		"empty"                 {return Empty;}
		"enumeration"           {return Enumeration;}
		"identityref"           {return Identityref;}
		"instance-identifier"   {return InstanceIdentifier;}
		"int8"                  {return Int8;}
		"int16"                 {return Int16;}
		"int32"                 {return Int32;}
		"int64"                 {return Int64;}
		"leafref"               {return Leafref;}
		"string"                {return String;}
		"uint8"                 {return Uint8;}
		"uint16"                {return Uint16;}
		"uint32"                {return Uint32;}
		"uint64"                {return Uint64;}
		"union"                 {return Union;}
		"min"                   {return Min;}
		"max"                   {return Max;}
		{ID}        { return RULE_ID; }
		{NUMBER}    { return RULE_NUMBER; }
		":"         { return Colon; }
		"("         { return LeftParenthesis; }
		")"         { return RightParenthesis; }
		"["         { return LeftSquareBracket; }
		"]"         { return RightSquareBracket; }
		"."         { return FullStop; }
		".."        { return FullStopFullStop; }
		"/"         { return Solidus; }
		","         { return Comma; }
	''', true)
	
	val XpathExpressionMode = new ExpressionMode('XPATH_EXPRESSION','''
		"comment"							{return Comment;}
		"text"								{return Text;}
		"processing-instruction"				{return ProcessingInstruction;}
		"node"								{return Node;}
		
		"ancestor"							{return Ancestor;}
		"ancestor-or-self"					{return AncestorOrSelf;}
		"attribute"							{return Attribute;}
		"child"								{return Child;}
		"descendant"							{return Descendant;}
		"descendant-or-self"					{return DescendantOrSelf;}
		"following"							{return Following;}
		"following-sibling"					{return FollowingSibling;}
		"namespace"							{return Namespace;}
		"parent"								{return Parent;}
		"preceding"							{return Preceding;}
		"preceding-sibling"					{return PrecedingSibling;}
		"self"								{return Self;}
		
		"or" 								{return Or;}
		"and"								{return And;}
		"div"								{return Div;}
		"mod"								{return Mod;}

		{ID}									{ return RULE_ID; }
		{U_NUMBER}								{ return RULE_NUMBER; }
		
		"="         { return EqualsSign; }
		"!="	        { return ExclamationMarkEqualsSign; }
		"<"         { return LessThanSign; }
		">"         { return GreaterThanSign; }
		"<="	        { return LessThanSignEqualsSign; }
		">="        { return GreaterThanSignEqualsSign; }
		"+"         { return PlusSign; }
		"-"         { return HyphenMinus; }
		"*"         { return Asterisk; }
		"$"         { return DollarSign; }
		"|"         { return VerticalLine; }
		"@"         { return CommercialAt; }
		
		":"         { return Colon; }
		"("         { return LeftParenthesis; }
		")"         { return RightParenthesis; }
		"["         { return LeftSquareBracket; }
		"]"         { return RightSquareBracket; }
		"."         { return FullStop; }
		".."        { return FullStopFullStop; }
		"/"         { return Solidus; }
		","         { return Comma; }
	''', true)
	
	val RefinementMode = new ExpressionMode('REFINEMENT_EXPRESSION','''
		{NUMBER}    { return RULE_NUMBER; }
		"|"  	    { return VerticalLine; }
		"min"       { return Min;}
		"max"       { return Max;}
		".."        { return FullStopFullStop; }
	''', false)
	
	val IfFeatureMode = new ExpressionMode('IF_FEATURE_EXPRESSION','''
		":"        { return Colon; }
		"or"  	   { return Or; }
		"and"      { return And; }
		"not"      { return Not; }
		{ID}    	   { return RULE_ID; }
		"("        { return LeftParenthesis; }
		")"        { return RightParenthesis; }
	''', false)
	
	val allModes = #[GenericExpressionMode, XpathExpressionMode, RefinementMode, IfFeatureMode]
	
	val statements = '''
		"action"                  {yybegin(BLACK_BOX_STRING); return Action; }
		"anydata"                 {yybegin(BLACK_BOX_STRING); return Anydata; }
		"anyxml"                  {yybegin(BLACK_BOX_STRING); return Anyxml; }
		"argument"                {yybegin(BLACK_BOX_STRING); return Argument; }
		"augment"                 {yybegin(«GenericExpressionMode.name»); return Augment; }
		"base"                    {yybegin(«GenericExpressionMode.name»); return Base; }
		"belongs-to"              {yybegin(BLACK_BOX_STRING); return BelongsTo; }
		"bit"                     {yybegin(BLACK_BOX_STRING); return Bit; }
		"case"                    {yybegin(BLACK_BOX_STRING); return Case; }
		"choice"                  {yybegin(BLACK_BOX_STRING); return Choice; }
		"config"                  {yybegin(BLACK_BOX_STRING); return Config; }
		"contact"                 {yybegin(BLACK_BOX_STRING); return Contact; }
		"container"               {yybegin(BLACK_BOX_STRING); return Container; }
		 "default"                {yybegin(BLACK_BOX_STRING); return Default; }
		 "description"            {yybegin(BLACK_BOX_STRING); return Description; }
		 "enum"                   {yybegin(BLACK_BOX_STRING); return Enum; }
		 "error-app-tag"          {yybegin(BLACK_BOX_STRING); return ErrorAppTag; }
		 "error-message"          {yybegin(BLACK_BOX_STRING); return ErrorMessage; }
		 "extension"              {yybegin(BLACK_BOX_STRING); return Extension; }
		 "deviation"              {yybegin(«GenericExpressionMode.name»); return Deviation; }
		 "deviate"                {yybegin(BLACK_BOX_STRING); return Deviate; }
		 "feature"                {yybegin(BLACK_BOX_STRING); return Feature; }
		 "fraction-digits"        {yybegin(BLACK_BOX_STRING); return FractionDigits; }
		 "grouping"               {yybegin(BLACK_BOX_STRING); return Grouping; }
		 "identity"               {yybegin(BLACK_BOX_STRING); return Identity; }
		 "if-feature"             {yybegin(«IfFeatureMode.name»); return IfFeature; }
		 "import"                 {yybegin(BLACK_BOX_STRING); return Import; }
		 "include"                {yybegin(BLACK_BOX_STRING); return Include; }
		 "input"                  {yybegin(BLACK_BOX_STRING); return Input; }
		 "key"                    {yybegin(«GenericExpressionMode.name»); return Key; }
		 "leaf"                   {yybegin(BLACK_BOX_STRING); return Leaf; }
		 "leaf-list"              {yybegin(BLACK_BOX_STRING); return LeafList; }
		 "length"                 {yybegin(«RefinementMode.name»); return Length; }
		 "list"                   {yybegin(BLACK_BOX_STRING); return List; }
		 "mandatory"              {yybegin(BLACK_BOX_STRING); return Mandatory; }
		 "max-elements"           {yybegin(BLACK_BOX_STRING); return MaxElements; }
		 "min-elements"           {yybegin(BLACK_BOX_STRING); return MinElements; }
		 "modifier"               {yybegin(BLACK_BOX_STRING); return Modifier; }
		 "module"                 {yybegin(BLACK_BOX_STRING); return Module; }
		 "must"                   {yybegin(«XpathExpressionMode.name»); return Must; }
		 "namespace"              {yybegin(BLACK_BOX_STRING); return Namespace; }
		 "notification"           {yybegin(BLACK_BOX_STRING); return Notification; }
		 "ordered-by"             {yybegin(BLACK_BOX_STRING); return OrderedBy; }
		 "organization"           {yybegin(BLACK_BOX_STRING); return Organization; }
		 "output"                 {yybegin(BLACK_BOX_STRING); return Output; }
		 "path"                   {yybegin(«XpathExpressionMode.name»); return Path; }
		 "pattern"                {yybegin(BLACK_BOX_STRING); return Pattern; }
		 "position"               {yybegin(BLACK_BOX_STRING); return Position; }
		 "prefix"                 {yybegin(BLACK_BOX_STRING); return Prefix; }
		 "presence"               {yybegin(BLACK_BOX_STRING); return Presence; }
		 "range"                  {yybegin(«RefinementMode.name»); return Range; }
		 "reference"              {yybegin(BLACK_BOX_STRING); return Reference; }
		 "refine"                 {yybegin(«GenericExpressionMode.name»); return Refine; }
		 "require-instance"       {yybegin(BLACK_BOX_STRING); return RequireInstance; }
		 "revision"               {yybegin(BLACK_BOX_STRING); return Revision; }
		 "revision-date"          {yybegin(BLACK_BOX_STRING); return RevisionDate; }
		 "rpc"                    {yybegin(BLACK_BOX_STRING); return Rpc; }
		 "status"                 {yybegin(BLACK_BOX_STRING); return Status; }
		 "submodule"              {yybegin(BLACK_BOX_STRING); return Submodule; }
		 "type"                   {yybegin(«GenericExpressionMode.name»); return Type; }
		 "typedef"                {yybegin(BLACK_BOX_STRING); return Typedef; }
		 "unique"                 {yybegin(«GenericExpressionMode.name»); return Unique; }
		 "units"                  {yybegin(BLACK_BOX_STRING); return Units; }
		 "uses"                   {yybegin(«GenericExpressionMode.name»); return Uses; }
		 "value"                  {yybegin(BLACK_BOX_STRING); return Value; }
		 "when"                   {yybegin(«XpathExpressionMode.name»); return When; }
		 "yang-version"           {yybegin(BLACK_BOX_STRING); return YangVersion; }
		 "yin-element"            {yybegin(BLACK_BOX_STRING); return YinElement; }
	'''
	
	def generateExpressionMode(ExpressionMode mode) '''
		<«mode.name»> {
			{ML_COMMENT} { return RULE_ML_COMMENT; }
			{SL_COMMENT} { return RULE_SL_COMMENT; }
			\"          {yybegin(IN_«mode.name»_STRING); return RULE_HIDDEN;}
			"'"         {yybegin(IN_SQ_«mode.name»_STRING); return RULE_HIDDEN;}
			«mode.commonElements»
		}
		
		<IN_«mode.name»_STRING> {
			«IF mode.canContainString»
				{SINGLE_QUOTED_STRING} { return RULE_STRING; }
				{ESCAPED_DQ_STRING}    { return RULE_STRING; }
			«ENDIF»
			«mode.commonElements»
		
			\" {STRING_CONCAT} { yybegin(«mode.name»); return RULE_HIDDEN; }
			\"                 { yybegin(YYINITIAL); return RULE_HIDDEN; }
		}
		
		<IN_SQ_«mode.name»_STRING> {
			«IF mode.canContainString»
				{DOUBLE_QUOTED_STRING}    { return RULE_STRING; }
			«ENDIF»
			«mode.commonElements»
		
			"'" {STRING_CONCAT} { yybegin(«mode.name»); return RULE_HIDDEN; }
			"'"                 { yybegin(YYINITIAL); return RULE_HIDDEN; }
		}
	''' 
	
	def generate() '''
		/*
		 * generated by Xtext 2.13.0-SNAPSHOT
		 */
		package io.typefox.yang.parser.antlr.lexer.jflex;
		
		import java.io.Reader;
		import java.io.IOException;
		
		import org.antlr.runtime.Token;
		import org.antlr.runtime.CommonToken;
		import org.antlr.runtime.TokenSource;
		
		import static io.typefox.yang.parser.antlr.internal.InternalYangParser.*;
		
		@SuppressWarnings({"all"})
		%%
		
		%{
			public final static TokenSource createTokenSource(Reader reader) {
				return new YangFlexer(reader);
			}
		
			private int offset = 0;
			
			public void reset(Reader reader) {
				yyreset(reader);
				offset = 0;
			}
		
			@Override
			public Token nextToken() {
				try {
					int type = advance();
					if (type == Token.EOF) {
						return Token.EOF_TOKEN;
					}
					int length = yylength();
					final String tokenText = yytext();
					CommonToken result = new CommonTokenWithText(tokenText, type, Token.DEFAULT_CHANNEL, offset);
					offset += length;
					return result;
				} catch (IOException e) {
					throw new RuntimeException(e);
				}
			}
		
			@Override
			public String getSourceName() {
				return "FlexTokenSource";
			}
		
			public static class CommonTokenWithText extends CommonToken {
		
				private static final long serialVersionUID = 1L;
		
				public CommonTokenWithText(String tokenText, int type, int defaultChannel, int offset) {
					super(null, type, defaultChannel, offset, offset + tokenText.length() - 1);
					this.text = tokenText;
				}
			}
		
		%}
		
		%unicode
		%implements org.antlr.runtime.TokenSource
		%class YangFlexer
		%function advance
		%public
		%int
		%eofval{
		return Token.EOF;
		%eofval}
		
		«predefinedRules»
		
		«FOR m : allModes»
			%s «m.name», IN_«m.name»_STRING, IN_SQ_«m.name»_STRING
		«ENDFOR»
		%s BLACK_BOX_STRING, BLACK_BOX_STRING_CONCAT
		
		%%
		
		<BLACK_BOX_STRING> {
			{STRING} { return RULE_STRING; }	
			{SINGLE_QUOTED_STRING} { yybegin(BLACK_BOX_STRING_CONCAT); return RULE_STRING; }
			{DOUBLE_QUOTED_STRING} { yybegin(BLACK_BOX_STRING_CONCAT); return RULE_STRING; }
			
			{ML_COMMENT} { return RULE_ML_COMMENT; }
			{SL_COMMENT} { return RULE_SL_COMMENT; }
		}
		
		<BLACK_BOX_STRING_CONCAT> {
			"+" { return RULE_HIDDEN;}
			{SINGLE_QUOTED_STRING} { return RULE_STRING; }
			{DOUBLE_QUOTED_STRING} { return RULE_STRING; }
			
			{ML_COMMENT} { return RULE_ML_COMMENT; }
			{SL_COMMENT} { return RULE_SL_COMMENT; }
		}
		
		«FOR mode : allModes»
			«generateExpressionMode(mode)»
		«ENDFOR»
		
		<YYINITIAL> {
		«statements»
		 
			{EXTENSION_NAME}          { yybegin(BLACK_BOX_STRING);  return RULE_EXTENSION_NAME; }
			{ID}                      {                             return RULE_ID; }
			
			{ML_COMMENT} { return RULE_ML_COMMENT; }
			{SL_COMMENT} { return RULE_SL_COMMENT; }
		}
		\; { yybegin(YYINITIAL); return Semicolon; }
		\{ { yybegin(YYINITIAL); return LeftCurlyBracket; }
		\} { yybegin(YYINITIAL); return RightCurlyBracket; }
		{WS} { return RULE_WS; }
		. { return RULE_ANY_OTHER; }
		
	'''
}