package io.typefox.yang.ide.completion

import com.google.common.base.Splitter
import com.google.common.base.Suppliers
import com.google.common.collect.HashMultimap
import com.google.common.collect.Multimap
import com.google.inject.Singleton
import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistEntry
import org.eclipse.xtext.xbase.lib.Functions.Function1

import static com.google.common.base.CaseFormat.*
import static io.typefox.yang.utils.YangDateUtils.*

import static extension com.google.common.collect.Multimaps.unmodifiableMultimap
import static extension io.typefox.yang.ide.completion.ContentAssistEntryUtils.*
import static extension io.typefox.yang.utils.YangNameUtils.escapeModuleName
import static extension java.lang.reflect.Modifier.*

/**
 * Template provider for YANG.
 * 
 * <p>
 * The template text complies the LSP's <a href="https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#completion-request">snippet template syntax</a>.
 * The grammar for the template syntax is available <a href="https://github.com/Microsoft/vscode/blob/master/src/vs/editor/contrib/snippet/browser/snippet.md#grammar">here</a>.
 * 
 * @author akos.kitta
 */
@Singleton
class YangTemplateProvider {

	val Multimap<String, (ContentAssistEntry)=>Template> templates;

	new() {
		templates = YangTemplates.ALL_TEMPLATES.get;
	}

	/**
	 * Returns with all templates for a particular keyword. If no templates are registered for the keyword argument,
	 * returns with an empty iterable.
	 */
	def getTemplatesForKeyword(ContentAssistEntry entry) {
		return templates.get(entry.proposal ?: entry.label).map[apply(entry)];
	}

	@EqualsHashCode
	@Accessors(PACKAGE_GETTER)
	@ToString(skipNulls=true)
	package static class Template {

		String template;
		String label;
		String documentation;
		String description;

	}

	/**
	 * All the available YANG templates.
	 */
	package static interface YangTemplates {

		val ALL_TEMPLATES = Suppliers.memoize [
			val templates = HashMultimap.create;
			val nameConverter = [String name|UPPER_UNDERSCORE.converterTo(LOWER_HYPHEN).convert(name)];
			YangTemplates.declaredFields.filter[modifiers.static && modifiers.public && type === Function1].map [
				nameConverter.apply(name) -> get(null) as Function1<? super ContentAssistEntry, ? extends Template>
			].forEach [
				templates.put(key, value);
			];
			return templates.unmodifiableMultimap;
		];

		val (ContentAssistEntry)=>Template MODULE = [
			val moduleName = resourceName.escapeModuleName ?: 'module-name';
			new Template() => [
				template = '''
					module ${1:«moduleName»} {
					  yang-version 1.1;
					  namespace urn:ietf:params:xml:ns:yang:${1:«moduleName»};
					  prefix ${1:«moduleName»};
					
					  $0
					}
				''';
				documentation = '''
					The "module" statement defines the module's name and groups all statements that belong to the module together. The "module" statement's argument is the name of the module, followed by a block of substatements that holds detailed module information.
					
					RFC 7950, Section 7.1: https://tools.ietf.org/html/rfc7950#section-7.1
				''';
				label = 'module';
				description = 'Creates a new "module" statement.';
			];
		];

		val (ContentAssistEntry)=>Template YANG_VERSION = [
			new Template() => [
				template = '''
					yang-version ${1:1.1};$0
				''';
				documentation = '''
					The "yang-version" statement specifies which version of the YANG language was used in developing the module.
					
					RFC 7950, Section 7.1.2: https://tools.ietf.org/html/rfc7950#section-7.1.2
				''';
				label = 'yang-version';
				description = 'Creates a new "yang-version" statement.';
			];
		];

		val (ContentAssistEntry)=>Template NAMESPACE = [
			val moduleName = resourceName.escapeModuleName ?: 'urn:namespace';
			val uri = '''urn:ietf:params:xml:ns:yang:«moduleName»''';
			new Template() => [
				template = '''
					namespace ${1:«uri»};$0
				''';
				documentation = '''
					The "namespace" statement defines the XML namespace that all identifiers defined by the module are qualified by in the XML encoding, with the exception of identifiers for data nodes, action nodes, and notification nodes defined inside a grouping.
					
					RFC 7950, Section 7.1.3: https://tools.ietf.org/html/rfc7950#section-7.1.3
				''';
				label = 'namespace';
				description = 'Creates a new "namespace" statement.';
			];
		];

		val (ContentAssistEntry)=>Template PREFIX = [
			val moduleName = resourceName.escapeModuleName ?: 'prefix';
			new Template() => [
				template = '''
					prefix ${1:«moduleName»};$0
				''';
				documentation = '''
					The "prefix" statement is used to define the prefix associated with the module and its namespace. The "prefix" statement's argument is the prefix string that is used as a prefix to access a module.
					
					RFC 7950, Section 7.1.4: https://tools.ietf.org/html/rfc7950#section-7.1.4
				''';
				label = 'prefix';
				description = 'Creates a new "prefix" statement.';
			];
		];

		val (ContentAssistEntry)=>Template IMPORT = [
			val segments = Splitter.on('-').trimResults.splitToList(revisionDateFormat.format(new Date)).iterator;
			new Template() => [
				template = '''
					import ${1:} {
					  prefix ${1:};
					  revision-date ${2:«segments.next»}-${3:«segments.next»}-${4:«segments.next»};
					}$0
				''';
				documentation = '''
					The "import" statement makes definitions from one module available inside another module or submodule.
					
					RFC 7950, Section 7.1.5: https://tools.ietf.org/html/rfc7950#section-7.1.5
				''';
				label = 'import';
				description = 'Creates a new "import" statement.';
			];
		];

		val (ContentAssistEntry)=>Template INCLUDE = [
			val segments = Splitter.on('-').trimResults.splitToList(revisionDateFormat.format(new Date)).iterator;
			new Template() => [
				template = '''
					include ${1:} {
					  revision-date ${2:«segments.next»}-${3:«segments.next»}-${4:«segments.next»};
					}$0
				''';
				documentation = '''
					The "include" statement is used to make content from a submodule available to that submodule's parent module.
					
					RFC 7950, Section 7.1.6: https://tools.ietf.org/html/rfc7950#section-7.1.6
				''';
				label = 'include';
				description = 'Creates a new "include" statement.';
			];
		];

		val (ContentAssistEntry)=>Template ORGANIZATION = [
			new Template() => [
				template = '''
					organization "${1:}";$0
				''';
				documentation = '''
					The "organization" statement defines the party responsible for this module.
					
					RFC 7950, Section 7.1.7: https://tools.ietf.org/html/rfc7950#section-7.1.7
				''';
				label = 'organization';
				description = 'Creates a new "organization" statement.';
			];
		];

		val (ContentAssistEntry)=>Template CONTACT = [
			new Template() => [
				template = '''
					contact "${1:}";$0
				''';
				documentation = '''
					The "contact" statement provides contact information for the module.
					
					RFC 7950, Section 7.1.8: https://tools.ietf.org/html/rfc7950#section-7.1.8
				''';
				label = 'contact';
				description = 'Creates a new "contact" statement.';
			];
		];

		val (ContentAssistEntry)=>Template REVISION = [
			val segments = Splitter.on('-').trimResults.splitToList(revisionDateFormat.format(new Date)).iterator;
			new Template() => [
				template = '''
					revision ${1:«segments.next»}-${2:«segments.next»}-${3:«segments.next»} {
					  description "${4}";$0
					}
				''';
				documentation = '''
					The "revision" statement specifies the editorial revision history of the module, including the initial revision. A series of "revision" statements detail the changes in the module's definition.
					
					RFC 7950, Section 7.1.9: https://tools.ietf.org/html/rfc7950#section-7.1.9
				''';
				label = 'revision';
				description = 'Creates a new "revision" statement.';
			];
		];

		val (ContentAssistEntry)=>Template SUBMODULE = [
			val moduleName = resourceName.escapeModuleName ?: 'module-name';
			val uri = '''urn:ietf:params:xml:ns:yang:«moduleName»''';
			new Template() => [
				template = '''
					submodule ${1:«moduleName»} {
					  yang-version 1.1;
					  belongs-to ${2:} {
					    prefix ${1:«uri»};
					  }
					
					  $0
					}
				''';
				documentation = '''
					The "submodule" statement defines the submodule's name, and it groups all statements that belong to the submodule together.
					
					RFC 7950, Section 7.2: https://tools.ietf.org/html/rfc7950#section-7.2
				''';
				label = 'submodule';
				description = 'Creates a new "submodule" statement.';
			];
		];

		val (ContentAssistEntry)=>Template BELONGS_TO = [
			new Template() => [
				template = '''
					belongs-to ${1:} {
					  prefix ${1:};
					}$0
				''';
				documentation = '''
					The "belongs-to" statement specifies the module to which the submodule belongs.
					
					RFC 7950, Section 7.2.2: https://tools.ietf.org/html/rfc7950#section-7.2.2
				''';
				label = 'submodule';
				description = 'Creates a new "submodule" statement.';
			];
		];

		val (ContentAssistEntry)=>Template TYPEDEF = [
			new Template() => [
				template = '''
					typedef ${1:type-name} {
					  type ${2:};$0
					}
				''';
				documentation = '''
					The "typedef" statement defines a new type that may be used locally in the module or submodule, and by other modules that import from it.
					
					RFC 7950, Section 7.3: https://tools.ietf.org/html/rfc7950#section-7.3
				''';
				label = 'typedef';
				description = 'Creates a new "typedef" statement.';
			];
		];

		val (ContentAssistEntry)=>Template UNITS = [
			new Template() => [
				template = '''
					units ${1:unit};$0
				'''
				documentation = '''
					The "units" statement contains a textual definition of the units associated with the type.
					
					RFC 7950, Section 7.3.3: https://tools.ietf.org/html/rfc7950#section-7.3.3
				''';
				label = 'units';
				description = 'Creates a new "units" statement.';
			];
		];

		val (ContentAssistEntry)=>Template DEFAULT = [
			new Template() => [
				template = '''
					default ${1:};$0
				'''
				documentation = '''
					The "default" statement contains a default value for the new type.
					
					RFC 7950, Section 7.3.4: https://tools.ietf.org/html/rfc7950#section-7.3.4
				''';
				label = 'default';
				description = 'Creates a new "default" statement.';
			];
		];

		val (ContentAssistEntry)=>Template TYPE = [
			new Template() => [
				template = '''
					type ${1:type-name};$0
				''';
				documentation = '''
					The "type" statement takes as an argument a string that is the name of a YANG built-in type or a derived type, followed by an optional block of substatements that is used to put further restrictions on the type.
					
					RFC 7950, Section 7.4: https://tools.ietf.org/html/rfc7950#section-7.4
				''';
				label = 'type';
				description = 'Creates a new "type" statement.';
			];
		];

		val (ContentAssistEntry)=>Template CONTAINER = [
			new Template() => [
				template = '''
					container ${1:container-name} {
					  $0
					}
				''';
				documentation = '''
					The "container" statement is used to define an interior data node in the schema tree. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed container information.
					
					RFC 7950, Section 7.5: https://tools.ietf.org/html/rfc7950#section-7.5
				''';
				label = 'container';
				description = 'Creates a new "container" statement.';
			];
		];

		val (ContentAssistEntry)=>Template MUST = [
			new Template() => [
				template = '''
					must "${1:expression}";$0
				''';
				documentation = '''
					The "must" statement, which is optional, takes as an argument a string that contains an XPath expression. It is used to formally declare a constraint on valid data.
					
					RFC 7950, Section 7.5.3: https://tools.ietf.org/html/rfc7950#section-7.5.3
				''';
				label = 'must';
				description = 'Creates a new "must" statement.';
			];
		];

		val (ContentAssistEntry)=>Template ERROR_MESSAGE = [
			new Template() => [
				template = '''
					error-message "${1:error-message}";$0
				''';
				documentation = '''
					The "error-message" statement, which is optional, takes a string as an argument. If the constraint evaluates to "false", the string is passed as <error-message> in the <rpc-error> in NETCONF.
					
					RFC 7950, Section 7.5.4.1: https://tools.ietf.org/html/rfc7950#section-7.5.4.1
				''';
				label = 'error-message';
				description = 'Creates a new "error-message" statement.';
			];
		];

		val (ContentAssistEntry)=>Template ERROR_APP_TAG = [
			new Template() => [
				template = '''
					error-app-tag ${1:error-app-tag};$0
				''';
				documentation = '''
					The "error-app-tag" statement, which is optional, takes a string as an argument. If the constraint evaluates to "false", the string is passed as <error-app-tag> in the <rpc-error> in NETCONF.
					
					RFC 7950, Section 7.5.4.2: https://tools.ietf.org/html/rfc7950#section-7.5.4.2
				''';
				label = 'error-app-tag';
				description = 'Creates a new "error-app-tag" statement.';
			];
		];

		val (ContentAssistEntry)=>Template PRESENCE = [
			new Template() => [
				template = '''
					presence ${1:meaning};$0
				''';
				documentation = '''
					The "presence" statement assigns a meaning to the presence of a container in the data tree. It takes as an argument a string that contains a textual description of what the node's presence means.
					
					RFC 7950, Section 7.5.5: https://tools.ietf.org/html/rfc7950#section-7.5.5
				''';
				label = 'presence';
				description = 'Creates a new "presence" statement.';
			];
		];

		val (ContentAssistEntry)=>Template LEAF = [
			new Template() => [
				template = '''
					leaf ${1:leaf-name} {
					  type ${2:type-name} {
					    $0
					  }
					}
				''';
				documentation = '''
					The "leaf" statement is used to define a leaf node in the schema tree. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed leaf information.
					
					RFC 7950, Section 7.6: https://tools.ietf.org/html/rfc7950#section-7.6
				''';
				label = 'leaf';
				description = 'Creates a new "leaf" statement.';
			];
		];

		val (ContentAssistEntry)=>Template MANDATORY = [
			new Template() => [
				template = '''
					mandatory ${1:true};$0
				''';
				documentation = '''
					The "mandatory" statement, which is optional, takes as an argument the string "true" or "false" and puts a constraint on valid data. If not specified, the default is "false".
					
					RFC 7950, Section 7.6.5: https://tools.ietf.org/html/rfc7950#section-7.6.5
				''';
				label = 'mandatory';
				description = 'Creates a new "mandatory" statement.';
			];
		];

		val (ContentAssistEntry)=>Template LEAF_LIST = [
			new Template() => [
				template = '''
					leaf-list ${1:leaf-list-name} {
					  type ${2:type-name} {
					    $0
					  }
					}
				''';
				documentation = '''
					Where the "leaf" statement is used to define a simple scalar variable of a particular type, the "leaf-list" statement is used to define an array of a particular type.
					
					RFC 7950, Section 7.7: https://tools.ietf.org/html/rfc7950#section-7.7
				''';
				label = 'leaf-list';
				description = 'Creates a new "leaf-list" statement.';
			];
		];

		val (ContentAssistEntry)=>Template MIN_ELEMENTS = [
			new Template() => [
				template = '''
					min-elements ${1:0};$0
				''';
				documentation = '''
					The "min-elements" statement, which is optional, takes as an argument a non-negative integer that puts a constraint on valid list entries.
					
					RFC 7950, Section 7.7.5: https://tools.ietf.org/html/rfc7950#section-7.7.5
				''';
				label = 'min-elements';
				description = 'Creates a new "min-elements" statement.';
			];
		];

		val (ContentAssistEntry)=>Template MAX_ELEMENTS = [
			new Template() => [
				template = '''
					max-elements ${1:unbounded};$0
				''';
				documentation = '''
					The "max-elements" statement, which is optional, takes as an argument a positive integer or the string "unbounded", which puts a constraint on valid list entries.
					
					RFC 7950, Section 7.7.6: https://tools.ietf.org/html/rfc7950#section-7.7.6
				''';
				label = 'max-elements';
				description = 'Creates a new "max-elements" statement.';
			];
		];

		val (ContentAssistEntry)=>Template ORDERED_BY = [
			new Template() => [
				template = '''
					ordered-by ${1:system};$0
				''';
				documentation = '''
					The "ordered-by" statement defines whether the order of entries within a list are determined by the user or the system. The argument is one of the strings "system" or "user". If not present, ordering defaults to "system".
					
					RFC 7950, Section 7.7.7: https://tools.ietf.org/html/rfc7950#section-7.7.7
				''';
				label = 'ordered-by';
				description = 'Creates a new "ordered-by" statement.';
			];
		];

		val (ContentAssistEntry)=>Template LIST = [
			new Template() => [
				template = '''
					list ${1:list-name} {
					  $0
					}
				''';
				documentation = '''
					The "list" statement is used to define an interior data node in the schema tree. A list node may exist in multiple instances in the data tree.
					
					RFC 7950, Section 7.8: https://tools.ietf.org/html/rfc7950#section-7.8
				''';
				label = 'list';
				description = 'Creates a new "list" statement.';
			];
		];

		val (ContentAssistEntry)=>Template KEY = [
			new Template() => [
				template = '''
					key ${1:};$0
				''';
				documentation = '''
					The "key" statement, which must be present if the list represents configuration and may be present otherwise, takes as an argument a string that specifies a space-separated list of one or more leaf identifiers of this list.
					
					RFC 7950, Section 7.8.2: https://tools.ietf.org/html/rfc7950#section-7.8.2
				''';
				label = 'key';
				description = 'Creates a new "key" statement.';
			];
		];

		val (ContentAssistEntry)=>Template UNIQUE = [
			new Template() => [
				template = '''
					unique ${1:}$2;$0
				''';
				documentation = '''
					The "unique" statement is used to put constraints on valid list entries. It takes as an argument a string that contains a space- separated list of schema node identifiers, which must be given in the descendant form.
					
					RFC 7950, Section 7.8.3: https://tools.ietf.org/html/rfc7950#section-7.8.3
				''';
				label = 'unique';
				description = 'Creates a new "unique" statement.';
			];
		];

		val (ContentAssistEntry)=>Template CHOICE = [
			new Template() => [
				template = '''
					choice ${1:choice-name} {
					  $0
					}
				''';
				documentation = '''
					The "choice" statement defines a set of alternatives, only one of which may be present in any one data tree. The argument is an identifier, followed by a block of substatements that holds detailed choice information.
					
					RFC 7950, Section 7.8.3: https://tools.ietf.org/html/rfc7950#section-7.8.3
				''';
				label = 'choice';
				description = 'Creates a new "choice" statement.';
			];
		];

		val (ContentAssistEntry)=>Template CASE = [
			new Template() => [
				template = '''
					case ${1:case-name} {
					  $0
					}
				''';
				documentation = '''
					The "case" statement is used to define branches of the choice. It takes as an argument an identifier, followed by a block of substatements that holds detailed case information.
					
					RFC 7950, Section 7.9.1: https://tools.ietf.org/html/rfc7950#section-7.9.2
				''';
				label = 'case';
				description = 'Creates a new "case" statement.';
			];
		];

		val (ContentAssistEntry)=>Template ANYDATA = [
			new Template() => [
				template = '''
					anydata ${1:data};$0
				''';
				documentation = '''
					The "anydata" statement defines an interior node in the schema tree. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed anydata information.
					
					RFC 7950, Section 7.10: https://tools.ietf.org/html/rfc7950#section-7.10
				''';
				label = 'anydata';
				description = 'Creates a new "anydata" statement.';
			];
		];

		val (ContentAssistEntry)=>Template ANYXML = [
			new Template() => [
				template = '''
					anyxml ${1:xml};$0
				''';
				documentation = '''
					The "anyxml" statement defines an interior node in the schema tree. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed anyxml information.
					
					RFC 7950, Section 7.11: https://tools.ietf.org/html/rfc7950#section-7.11
				''';
				label = 'anyxml';
				description = 'Creates a new "anyxml" statement.';
			];
		];

		val (ContentAssistEntry)=>Template GROUPING = [
			new Template() => [
				template = '''
					grouping ${1:grouping-name} {
					  $0
					}
				''';
				documentation = '''
					The "grouping" statement is used to define a reusable block of nodes, which may be used locally in the module or submodule, and by other modules that import from it.
					
					RFC 7950, Section 7.12: https://tools.ietf.org/html/rfc7950#section-7.12
				''';
				label = 'grouping';
				description = 'Creates a new "grouping" statement.';
			];
		];

		val (ContentAssistEntry)=>Template USES = [
			new Template() => [
				template = '''
					uses ${1:group-name} {
					  $0
					}
				''';
				documentation = '''
					The "uses" statement is used to reference a "grouping" definition. It takes one argument, which is the name of the grouping.
					
					RFC 7950, Section 7.13: https://tools.ietf.org/html/rfc7950#section-7.13
				''';
				label = 'uses';
				description = 'Creates a new "uses" statement.';
			];
		];

		val (ContentAssistEntry)=>Template REFINE = [
			new Template() => [
				template = '''
					uses ${1:node-} {
					  $0
					}
				''';
				documentation = '''
					Some of the properties of each node in the grouping can be refined with the "refine" statement. The argument is a string that identifies a node in the grouping. This node is called the refine's target node.
					
					RFC 7950, Section 7.13.2: https://tools.ietf.org/html/rfc7950#section-7.13.2
				''';
				label = 'refine';
				description = 'Creates a new "refine" statement.';
			];
		];

		val (ContentAssistEntry)=>Template RPC = [
			new Template() => [
				template = '''
					rpc ${1:rpc-name} {
					  $0
					}
				''';
				documentation = '''
					The "rpc" statement is used to define an RPC operation. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed rpc information. This argument is the name of the RPC.
					
					RFC 7950, Section 7.14: https://tools.ietf.org/html/rfc7950#section-7.14
				''';
				label = 'rpc';
				description = 'Creates a new "rpc" statement.';
			];
		];

		val (ContentAssistEntry)=>Template INPUT = [
			new Template() => [
				template = '''
					input {
					  $0
					}
				''';
				documentation = '''
					The "input" statement, which is optional, is used to define input parameters to the operation. It does not take an argument. The substatements to "input" define nodes under the operation's input node.
					
					RFC 7950, Section 7.14.2: https://tools.ietf.org/html/rfc7950#section-7.14.2
				''';
				label = 'input';
				description = 'Creates a new "input" statement.';
			];
		];

		val (ContentAssistEntry)=>Template OUTPUT = [
			new Template() => [
				template = '''
					output {
					  $0
					}
				''';
				documentation = '''
					The "output" statement, which is optional, is used to define output parameters to the RPC operation. It does not take an argument. The substatements to "output" define nodes under the operation's output node.
					
					RFC 7950, Section 7.14.3: https://tools.ietf.org/html/rfc7950#section-7.14.3
				''';
				label = 'output';
				description = 'Creates a new "output" statement.';
			];
		];

		val (ContentAssistEntry)=>Template ACTION = [
			new Template() => [
				template = '''
					action ${1:action-name} {
					  $0
					}
				''';
				documentation = '''
					The "action" statement is used to define an operation connected to a specific container or list data node. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed action information. The argument is the name of the action.
					
					RFC 7950, Section 7.15: https://tools.ietf.org/html/rfc7950#section-7.15
				''';
				label = 'action';
				description = 'Creates a new "action" statement.';
			];
		];

		val (ContentAssistEntry)=>Template NOTIFICATION = [
			new Template() => [
				template = '''
					notification ${1:action-name} {
					  $0
					}
				''';
				documentation = '''
					The "notification" statement is used to define a notification. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed notification information. The "notification" statement defines a notification node in the schema tree.
					
					RFC 7950, Section 7.16: https://tools.ietf.org/html/rfc7950#section-7.16
				''';
				label = 'notification';
				description = 'Creates a new "notification" statement.';
			];
		];

		val (ContentAssistEntry)=>Template AUGMENT = [
			new Template() => [
				template = '''
					augment ${1:} {
					  $0
					}
				''';
				documentation = '''
					The "augment" statement allows a module or submodule to add to a schema tree defined in an external module, or in the current module and its submodules, and to add to the nodes from a grouping in a "uses" statement. The argument is a string that identifies a node in the schema tree.
					
					RFC 7950, Section 7.17: https://tools.ietf.org/html/rfc7950#section-7.17
				''';
				label = 'augment';
				description = 'Creates a new "augment" statement.';
			];
		];

		val (ContentAssistEntry)=>Template IDENTITY = [
			new Template() => [
				template = '''
					identity ${1:identity-name} {
					  $0
					}
				''';
				documentation = '''
					The "identity" statement is used to define a new globally unique, abstract, and untyped identity. The identity's only purpose is to denote its name, semantics, and existence. An identity can be either defined from scratch or derived from one or more base identities.
					
					RFC 7950, Section 7.18: https://tools.ietf.org/html/rfc7950#section-7.18
				''';
				label = 'identity';
				description = 'Creates a new "identity" statement.';
			];
		];

		val (ContentAssistEntry)=>Template BASE = [
			new Template() => [
				template = '''
					base ${1:};$0
				''';
				documentation = '''
					The "base" statement, which is optional, takes as an argument a string that is the name of an existing identity, from which the new identity is derived.
					
					RFC 7950, Section 7.18.2: https://tools.ietf.org/html/rfc7950#section-7.18.2
				''';
				label = 'base';
				description = 'Creates a new "base" statement.';
			];
		];

		val (ContentAssistEntry)=>Template EXTENSION = [
			new Template() => [
				template = '''
					extension ${1:extension-name} {
					  $0
					}
				''';
				documentation = '''
					The "extension" statement allows the definition of new statements within the YANG language. This new statement definition can be imported and used by other modules.
					
					RFC 7950, Section 7.19: https://tools.ietf.org/html/rfc7950#section-7.19
				''';
				label = 'extension';
				description = 'Creates a new "extension" statement.';
			];
		];

		val (ContentAssistEntry)=>Template ARGUMENT = [
			new Template() => [
				template = '''
					argument ${1:argument-name} {
					  $0
					}
				''';
				documentation = '''
					The "argument" statement, which is optional, takes as an argument a string that is the name of the argument to the keyword. The argument's name is used in the YIN mapping, where it is used as an XML attribute or element name, depending on the argument's "yin-element" statement.
					
					RFC 7950, Section 7.19.2: https://tools.ietf.org/html/rfc7950#section-7.19.2
				''';
				label = 'argument';
				description = 'Creates a new "argument" statement.';
			];
		];

		val (ContentAssistEntry)=>Template YIN_ELEMENT = [
			new Template() => [
				template = '''
					yin-element ${1:yin-element-name} {
					  $0
					}
				''';
				documentation = '''
					The "yin-element" statement, which is optional, takes as an argument the string "true" or "false".  This statement indicates whether the argument is mapped to an XML element in YIN or to an XML attribute.
					
					RFC 7950, Section 7.19.2.2: https://tools.ietf.org/html/rfc7950#section-7.19.2.2
				''';
				label = 'yin-element';
				description = 'Creates a new "yin-element" statement.';
			];
		];

		val (ContentAssistEntry)=>Template FEATURE = [
			new Template() => [
				template = '''
					feature ${1:feature-name} {
					  $0
					}
				''';
				documentation = '''
					The "feature" statement is used to define a mechanism by which portions of the schema are marked as conditional.  A feature name is defined that can later be referenced using the "if-feature" statement.
					
					RFC 7950, Section 7.20.1: https://tools.ietf.org/html/rfc7950#section-7.20.1
				''';
				label = 'feature';
				description = 'Creates a new "feature" statement.';
			];
		];

		val (ContentAssistEntry)=>Template IF_FEATURE = [
			new Template() => [
				template = '''
					if-feature ${1:}$2;$0
				''';
				documentation = '''
					The "if-feature" statement makes its parent statement conditional. The argument is a boolean expression over feature names.  In this expression, a feature name evaluates to "true" if and only if the feature is supported by the server.
					
					RFC 7950, Section 7.20.2: https://tools.ietf.org/html/rfc7950#section-7.20.2
				''';
				label = 'if-feature';
				description = 'Creates a new "if-feature" statement.';
			];
		];

		val (ContentAssistEntry)=>Template DEVIATION = [
			new Template() => [
				template = '''
					deviation ${1:node-identifier} {
					  deviate ${2:deviate-action} {
					    $3
					  }
					  $0
					}
				''';
				documentation = '''
					The "deviation" statement defines a hierarchy of a module that the server does not implement faithfully.  The argument is a string that identifies the node in the schema tree where a deviation from the module occurs.  This node is called the deviation's target node.
					
					RFC 7950, Section 7.20.3: https://tools.ietf.org/html/rfc7950#section-7.20.3
				''';
				label = 'deviation';
				description = 'Creates a new "deviation" statement.';
			];
		];

		val (ContentAssistEntry)=>Template DEVIATE = [
			new Template() => [
				template = '''
					deviate ${1:deviate-action} {
					  $2
					}$0
				''';
				documentation = '''
					The "deviate" statement defines how the server's implementation of the target node deviates from its original definition.  The argument is one of the strings "not-supported", "add", "replace", or "delete".
					
					RFC 7950, Section 7.20.3.2: https://tools.ietf.org/html/rfc7950#section-7.20.3.2
				''';
				label = 'deviate';
				description = 'Creates a new "deviate" statement.';
			];
		];

		val (ContentAssistEntry)=>Template CONFIG = [
			new Template() => [
				template = '''
					config ${1:false};$0
				''';
				documentation = '''
					The "config" statement takes as an argument the string "true" or "false".  If "config" is "true", the definition represents configuration.  Data nodes representing configuration are part of configuration datastores.
					
					RFC 7950, Section 7.21.1: https://tools.ietf.org/html/rfc7950#section-7.21.1
				''';
				label = 'config';
				description = 'Creates a new "config" statement.';
			];
		];

		val (ContentAssistEntry)=>Template STATUS = [
			new Template() => [
				template = '''
					status ${1:current};$0
				''';
				documentation = '''
					The "status" statement takes as an argument one of the strings "current", "deprecated", or "obsolete". If no status is specified, the default is "current".
					
					RFC 7950, Section 7.21.2: https://tools.ietf.org/html/rfc7950#section-7.21.2
				''';
				label = 'status';
				description = 'Creates a new "status" statement.';
			];
		];

		val (ContentAssistEntry)=>Template DESCRIPTION = [
			new Template() => [
				template = '''
					description "${1:}";$0
				''';
				documentation = '''
					The "description" statement takes as an argument a string that contains a human-readable textual description of this definition. The text is provided in a language (or languages) chosen by the module developer.
					
					RFC 7950, Section 7.21.3: https://tools.ietf.org/html/rfc7950#section-7.21.3
				''';
				label = 'description';
				description = 'Creates a new "description" statement.';
			];
		];

		val (ContentAssistEntry)=>Template REFERENCE = [
			new Template() => [
				template = '''
					reference "${1:}";$0
				''';
				documentation = '''
					The "reference" statement takes as an argument a string that is a human-readable cross-reference to an external document -- either another module that defines related management information or a document that provides additional information relevant to this definition.
					
					RFC 7950, Section 7.21.4: https://tools.ietf.org/html/rfc7950#section-7.21.4
				''';
				label = 'reference';
				description = 'Creates a new "reference" statement.';
			];
		];

		val (ContentAssistEntry)=>Template WHEN = [
			new Template() => [
				template = '''
					when "${1:expression}";$0
				''';
				documentation = '''
					 The "when" statement makes its parent data definition statement conditional.  The node defined by the parent data definition statement is only valid when the condition specified by the "when" statement is satisfied.  The statement's argument is an XPath expression, which is used to formally specify this condition.
					
					RFC 7950, Section 7.21.5: https://tools.ietf.org/html/rfc7950#section-7.21.5
				''';
				label = 'when';
				description = 'Creates a new "when" statement.';
			];
		];

	}

}
