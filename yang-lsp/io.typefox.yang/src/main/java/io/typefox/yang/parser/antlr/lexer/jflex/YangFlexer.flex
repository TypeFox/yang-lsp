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

SYMBOLIC_OPERATOR= "*" | "|" | "+" | "-" | "=" | "!=" | "<" | "<=" | ">" | ">="

LEXICAL_OPERATOR= "and" | "or" | "mod" | "div"

STRING_CONCAT= ({WS} | {ML_COMMENT} | {SL_COMMENT})* "+" ({WS} | {ML_COMMENT} | {SL_COMMENT})*

%s EXPRESSION, IN_EXPRESSION_STRING, IN_SQ_EXPRESSION_STRING
%s XPATH_EXPRESSION, IN_XPATH_EXPRESSION_STRING, IN_SQ_XPATH_EXPRESSION_STRING
%s REFINEMENT_EXPRESSION, IN_REFINEMENT_EXPRESSION_STRING, IN_SQ_REFINEMENT_EXPRESSION_STRING
%s IF_FEATURE_EXPRESSION, IN_IF_FEATURE_EXPRESSION_STRING, IN_SQ_IF_FEATURE_EXPRESSION_STRING
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

<EXPRESSION> {
	{ML_COMMENT} { return RULE_ML_COMMENT; }
	{SL_COMMENT} { return RULE_SL_COMMENT; }
	\"          {yybegin(IN_EXPRESSION_STRING); return RULE_HIDDEN;}
	"'"         {yybegin(IN_SQ_EXPRESSION_STRING); return RULE_HIDDEN;}
	{SYMBOLIC_OPERATOR}  { return RULE_SYMBOLIC_OPERATOR; }
	{LEXICAL_OPERATOR}  { return RULE_LEXICAL_OPERATOR; }
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
}

<IN_EXPRESSION_STRING> {
	{SINGLE_QUOTED_STRING} { return RULE_STRING; }
	{ESCAPED_DQ_STRING}    { return RULE_STRING; }
	{SYMBOLIC_OPERATOR}  { return RULE_SYMBOLIC_OPERATOR; }
	{LEXICAL_OPERATOR}  { return RULE_LEXICAL_OPERATOR; }
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

	\" {STRING_CONCAT} { yybegin(EXPRESSION); return RULE_HIDDEN; }
	\"                 { yybegin(YYINITIAL); return RULE_HIDDEN; }
}

<IN_SQ_EXPRESSION_STRING> {
	{DOUBLE_QUOTED_STRING}    { return RULE_STRING; }
	{SYMBOLIC_OPERATOR}  { return RULE_SYMBOLIC_OPERATOR; }
	{LEXICAL_OPERATOR}  { return RULE_LEXICAL_OPERATOR; }
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

	"'" {STRING_CONCAT} { yybegin(EXPRESSION); return RULE_HIDDEN; }
	"'"                 { yybegin(YYINITIAL); return RULE_HIDDEN; }
}
<XPATH_EXPRESSION> {
	{ML_COMMENT} { return RULE_ML_COMMENT; }
	{SL_COMMENT} { return RULE_SL_COMMENT; }
	\"          {yybegin(IN_XPATH_EXPRESSION_STRING); return RULE_HIDDEN;}
	"'"         {yybegin(IN_SQ_XPATH_EXPRESSION_STRING); return RULE_HIDDEN;}
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
}

<IN_XPATH_EXPRESSION_STRING> {
	{SINGLE_QUOTED_STRING} { return RULE_STRING; }
	{ESCAPED_DQ_STRING}    { return RULE_STRING; }
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

	\" {STRING_CONCAT} { yybegin(XPATH_EXPRESSION); return RULE_HIDDEN; }
	\"                 { yybegin(YYINITIAL); return RULE_HIDDEN; }
}

<IN_SQ_XPATH_EXPRESSION_STRING> {
	{DOUBLE_QUOTED_STRING}    { return RULE_STRING; }
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

	"'" {STRING_CONCAT} { yybegin(XPATH_EXPRESSION); return RULE_HIDDEN; }
	"'"                 { yybegin(YYINITIAL); return RULE_HIDDEN; }
}
<REFINEMENT_EXPRESSION> {
	{ML_COMMENT} { return RULE_ML_COMMENT; }
	{SL_COMMENT} { return RULE_SL_COMMENT; }
	\"          {yybegin(IN_REFINEMENT_EXPRESSION_STRING); return RULE_HIDDEN;}
	"'"         {yybegin(IN_SQ_REFINEMENT_EXPRESSION_STRING); return RULE_HIDDEN;}
	{NUMBER}    { return RULE_NUMBER; }
	"|"  	    { return VerticalLine; }
	"min"       { return Min;}
	"max"       { return Max;}
	".."        { return FullStopFullStop; }
}

<IN_REFINEMENT_EXPRESSION_STRING> {
	{NUMBER}    { return RULE_NUMBER; }
	"|"  	    { return VerticalLine; }
	"min"       { return Min;}
	"max"       { return Max;}
	".."        { return FullStopFullStop; }

	\" {STRING_CONCAT} { yybegin(REFINEMENT_EXPRESSION); return RULE_HIDDEN; }
	\"                 { yybegin(YYINITIAL); return RULE_HIDDEN; }
}

<IN_SQ_REFINEMENT_EXPRESSION_STRING> {
	{NUMBER}    { return RULE_NUMBER; }
	"|"  	    { return VerticalLine; }
	"min"       { return Min;}
	"max"       { return Max;}
	".."        { return FullStopFullStop; }

	"'" {STRING_CONCAT} { yybegin(REFINEMENT_EXPRESSION); return RULE_HIDDEN; }
	"'"                 { yybegin(YYINITIAL); return RULE_HIDDEN; }
}
<IF_FEATURE_EXPRESSION> {
	{ML_COMMENT} { return RULE_ML_COMMENT; }
	{SL_COMMENT} { return RULE_SL_COMMENT; }
	\"          {yybegin(IN_IF_FEATURE_EXPRESSION_STRING); return RULE_HIDDEN;}
	"'"         {yybegin(IN_SQ_IF_FEATURE_EXPRESSION_STRING); return RULE_HIDDEN;}
	":"        { return Colon; }
	"or"  	   { return Or; }
	"and"      { return And; }
	"not"      { return Not; }
	{ID}    	   { return RULE_ID; }
	"("        { return LeftParenthesis; }
	")"        { return RightParenthesis; }
}

<IN_IF_FEATURE_EXPRESSION_STRING> {
	":"        { return Colon; }
	"or"  	   { return Or; }
	"and"      { return And; }
	"not"      { return Not; }
	{ID}    	   { return RULE_ID; }
	"("        { return LeftParenthesis; }
	")"        { return RightParenthesis; }

	\" {STRING_CONCAT} { yybegin(IF_FEATURE_EXPRESSION); return RULE_HIDDEN; }
	\"                 { yybegin(YYINITIAL); return RULE_HIDDEN; }
}

<IN_SQ_IF_FEATURE_EXPRESSION_STRING> {
	":"        { return Colon; }
	"or"  	   { return Or; }
	"and"      { return And; }
	"not"      { return Not; }
	{ID}    	   { return RULE_ID; }
	"("        { return LeftParenthesis; }
	")"        { return RightParenthesis; }

	"'" {STRING_CONCAT} { yybegin(IF_FEATURE_EXPRESSION); return RULE_HIDDEN; }
	"'"                 { yybegin(YYINITIAL); return RULE_HIDDEN; }
}

<YYINITIAL> {
"action"                  {yybegin(BLACK_BOX_STRING); return Action; }
"anydata"                 {yybegin(BLACK_BOX_STRING); return Anydata; }
"anyxml"                  {yybegin(BLACK_BOX_STRING); return Anyxml; }
"argument"                {yybegin(BLACK_BOX_STRING); return Argument; }
"augment"                 {yybegin(EXPRESSION); return Augment; }
"base"                    {yybegin(EXPRESSION); return Base; }
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
 "deviation"              {yybegin(EXPRESSION); return Deviation; }
 "deviate"                {yybegin(BLACK_BOX_STRING); return Deviate; }
 "feature"                {yybegin(BLACK_BOX_STRING); return Feature; }
 "fraction-digits"        {yybegin(BLACK_BOX_STRING); return FractionDigits; }
 "grouping"               {yybegin(BLACK_BOX_STRING); return Grouping; }
 "identity"               {yybegin(BLACK_BOX_STRING); return Identity; }
 "if-feature"             {yybegin(IF_FEATURE_EXPRESSION); return IfFeature; }
 "import"                 {yybegin(BLACK_BOX_STRING); return Import; }
 "include"                {yybegin(BLACK_BOX_STRING); return Include; }
 "input"                  {yybegin(BLACK_BOX_STRING); return Input; }
 "key"                    {yybegin(EXPRESSION); return Key; }
 "leaf"                   {yybegin(BLACK_BOX_STRING); return Leaf; }
 "leaf-list"              {yybegin(BLACK_BOX_STRING); return LeafList; }
 "length"                 {yybegin(REFINEMENT_EXPRESSION); return Length; }
 "list"                   {yybegin(BLACK_BOX_STRING); return List; }
 "mandatory"              {yybegin(BLACK_BOX_STRING); return Mandatory; }
 "max-elements"           {yybegin(BLACK_BOX_STRING); return MaxElements; }
 "min-elements"           {yybegin(BLACK_BOX_STRING); return MinElements; }
 "modifier"               {yybegin(BLACK_BOX_STRING); return Modifier; }
 "module"                 {yybegin(BLACK_BOX_STRING); return Module; }
 "must"                   {yybegin(XPATH_EXPRESSION); return Must; }
 "namespace"              {yybegin(BLACK_BOX_STRING); return Namespace; }
 "notification"           {yybegin(BLACK_BOX_STRING); return Notification; }
 "ordered-by"             {yybegin(BLACK_BOX_STRING); return OrderedBy; }
 "organization"           {yybegin(BLACK_BOX_STRING); return Organization; }
 "output"                 {yybegin(BLACK_BOX_STRING); return Output; }
 "path"                   {yybegin(XPATH_EXPRESSION); return Path; }
 "pattern"                {yybegin(BLACK_BOX_STRING); return Pattern; }
 "position"               {yybegin(BLACK_BOX_STRING); return Position; }
 "prefix"                 {yybegin(BLACK_BOX_STRING); return Prefix; }
 "presence"               {yybegin(BLACK_BOX_STRING); return Presence; }
 "range"                  {yybegin(REFINEMENT_EXPRESSION); return Range; }
 "reference"              {yybegin(BLACK_BOX_STRING); return Reference; }
 "refine"                 {yybegin(EXPRESSION); return Refine; }
 "require-instance"       {yybegin(BLACK_BOX_STRING); return RequireInstance; }
 "revision"               {yybegin(BLACK_BOX_STRING); return Revision; }
 "revision-date"          {yybegin(BLACK_BOX_STRING); return RevisionDate; }
 "rpc"                    {yybegin(BLACK_BOX_STRING); return Rpc; }
 "status"                 {yybegin(BLACK_BOX_STRING); return Status; }
 "submodule"              {yybegin(BLACK_BOX_STRING); return Submodule; }
 "type"                   {yybegin(EXPRESSION); return Type; }
 "typedef"                {yybegin(BLACK_BOX_STRING); return Typedef; }
 "unique"                 {yybegin(EXPRESSION); return Unique; }
 "units"                  {yybegin(BLACK_BOX_STRING); return Units; }
 "uses"                   {yybegin(EXPRESSION); return Uses; }
 "value"                  {yybegin(BLACK_BOX_STRING); return Value; }
 "when"                   {yybegin(XPATH_EXPRESSION); return When; }
 "yang-version"           {yybegin(BLACK_BOX_STRING); return YangVersion; }
 "yin-element"            {yybegin(BLACK_BOX_STRING); return YinElement; }
 
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

