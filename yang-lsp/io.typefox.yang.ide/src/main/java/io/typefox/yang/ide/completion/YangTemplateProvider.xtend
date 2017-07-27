package io.typefox.yang.ide.completion

import com.google.common.base.Preconditions
import com.google.common.base.Splitter
import com.google.common.collect.HashMultimap
import com.google.common.collect.Multimap
import com.google.inject.Singleton
import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistEntry

import static io.typefox.yang.utils.YangDateUtils.*

import static extension com.google.common.collect.Multimaps.unmodifiableMultimap
import static extension io.typefox.yang.ide.completion.ContentAssistEntryUtils.*
import static extension io.typefox.yang.utils.YangNameUtils.escapeModuleName

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
		templates = YangTemplates.ALL_TEMPLATES;
	}

	/**
	 * Returns with all templates for a particular keyword. If no templates are registered for the keyword argument,
	 * returns with an empty iterable.
	 */
	def getTemplatesForKeyword(ContentAssistEntry entry) {
		return templates.get(entry.proposal ?: entry.label).map[apply(entry)];
	}

	/**
	 * Bare minimum representation of a template.
	 * <p>
	 * The templates uses two spaces {@code /\s\s/} as indentations at the definition-site.
	 */
	@EqualsHashCode
	@Accessors(PACKAGE_GETTER)
	@ToString(skipNulls=true)
	package static class Template {

		String template;
		String label;
		String documentation;
		String description;

		package new() {
		}

		package new(String label) {
			this.label = Preconditions.checkNotNull(label, 'label');
			description = '''Creates a new "«label»" statement.''';
		}

	}

	/**
	 * All the available YANG templates.
	 */
	package static class YangTemplates {

		private static def register(Multimap<String, (ContentAssistEntry)=>Template> map, String key,
			(ContentAssistEntry)=>Template it) {

			map.put(key, it);
			return map;
		}

		static val ALL_TEMPLATES = HashMultimap.<String, (ContentAssistEntry)=>Template>create.register('module', [
			val moduleName = resourceName.escapeModuleName ?: 'module-name';
			new Template('module') => [
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
			];
		]).register('yang-version', [
			new Template('yang-version') => [
				template = '''
					yang-version ${1:1.1};$0
				''';
				documentation = '''
					The "yang-version" statement specifies which version of the YANG language was used in developing the module.
					
					RFC 7950, Section 7.1.2: https://tools.ietf.org/html/rfc7950#section-7.1.2
				''';
			];
		]).register('namespace', [
			val moduleName = resourceName.escapeModuleName ?: 'urn:namespace';
			val uri = '''urn:ietf:params:xml:ns:yang:«moduleName»''';
			new Template('namespace') => [
				template = '''
					namespace ${1:«uri»};$0
				''';
				documentation = '''
					The "namespace" statement defines the XML namespace that all identifiers defined by the module are qualified by in the XML encoding, with the exception of identifiers for data nodes, action nodes, and notification nodes defined inside a grouping.
					
					RFC 7950, Section 7.1.3: https://tools.ietf.org/html/rfc7950#section-7.1.3
				''';
			];
		]).register('prefix', [
			val moduleName = resourceName.escapeModuleName ?: 'prefix';
			new Template('prefix') => [
				template = '''
					prefix ${1:«moduleName»};$0
				''';
				documentation = '''
					The "prefix" statement is used to define the prefix associated with the module and its namespace. The "prefix" statement's argument is the prefix string that is used as a prefix to access a module.
					
					RFC 7950, Section 7.1.4: https://tools.ietf.org/html/rfc7950#section-7.1.4
				''';
			];
		]).register('import', [
			val segments = Splitter.on('-').trimResults.splitToList(revisionDateFormat.format(new Date)).iterator;
			new Template('import') => [
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
			];
		]).register('include', [
			val segments = Splitter.on('-').trimResults.splitToList(revisionDateFormat.format(new Date)).iterator;
			new Template('include') => [
				template = '''
					include ${1:} {
					  revision-date ${2:«segments.next»}-${3:«segments.next»}-${4:«segments.next»};
					}$0
				''';
				documentation = '''
					The "include" statement is used to make content from a submodule available to that submodule's parent module.
					
					RFC 7950, Section 7.1.6: https://tools.ietf.org/html/rfc7950#section-7.1.6
				''';
			];
		]).register('organization', [
			new Template('organization') => [
				template = '''
					organization "${1:}";$0
				''';
				documentation = '''
					The "organization" statement defines the party responsible for this module.
					
					RFC 7950, Section 7.1.7: https://tools.ietf.org/html/rfc7950#section-7.1.7
				''';
			];
		]).register('contact', [
			new Template('contact') => [
				template = '''
					contact "${1:}";$0
				''';
				documentation = '''
					The "contact" statement provides contact information for the module.
					
					RFC 7950, Section 7.1.8: https://tools.ietf.org/html/rfc7950#section-7.1.8
				''';
			];
		]).register('revision', [
			val segments = Splitter.on('-').trimResults.splitToList(revisionDateFormat.format(new Date)).iterator;
			new Template('revision') => [
				template = '''
					revision ${1:«segments.next»}-${2:«segments.next»}-${3:«segments.next»} {
					  description "${4}";$0
					}
				''';
				documentation = '''
					The "revision" statement specifies the editorial revision history of the module, including the initial revision. A series of "revision" statements detail the changes in the module's definition.
					
					RFC 7950, Section 7.1.9: https://tools.ietf.org/html/rfc7950#section-7.1.9
				''';
			];
		]).register('submodule', [
			val moduleName = resourceName.escapeModuleName ?: 'module-name';
			val uri = '''urn:ietf:params:xml:ns:yang:«moduleName»''';
			new Template('submodule') => [
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
			];
		]).register('belongs-to', [
			new Template('belongs-to') => [
				template = '''
					belongs-to ${1:} {
					  prefix ${1:};
					}$0
				''';
				documentation = '''
					The "belongs-to" statement specifies the module to which the submodule belongs.
					
					RFC 7950, Section 7.2.2: https://tools.ietf.org/html/rfc7950#section-7.2.2
				''';
			];
		]).register('typedef', [
			new Template('typedef') => [
				template = '''
					typedef ${1:type-name} {
					  type ${2:};$0
					}
				''';
				documentation = '''
					The "typedef" statement defines a new type that may be used locally in the module or submodule, and by other modules that import from it.
					
					RFC 7950, Section 7.3: https://tools.ietf.org/html/rfc7950#section-7.3
				''';
			];
		]).register('units', [
			new Template('units') => [
				template = '''
					units ${1:unit};$0
				'''
				documentation = '''
					The "units" statement contains a textual definition of the units associated with the type.
					
					RFC 7950, Section 7.3.3: https://tools.ietf.org/html/rfc7950#section-7.3.3
				''';
			];
		]).register('default', [
			new Template('default') => [
				template = '''
					default ${1:};$0
				'''
				documentation = '''
					The "default" statement contains a default value for the new type.
					
					RFC 7950, Section 7.3.4: https://tools.ietf.org/html/rfc7950#section-7.3.4
				''';
			];
		]).register('type', [
			new Template('type') => [
				template = '''
					type ${1:type-name};$0
				''';
				documentation = '''
					The "type" statement takes as an argument a string that is the name of a YANG built-in type or a derived type, followed by an optional block of substatements that is used to put further restrictions on the type.
					
					RFC 7950, Section 7.4: https://tools.ietf.org/html/rfc7950#section-7.4
				''';
			];
		]).register('container', [
			new Template('container') => [
				template = '''
					container ${1:container-name} {
					  $0
					}
				''';
				documentation = '''
					The "container" statement is used to define an interior data node in the schema tree. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed container information.
					
					RFC 7950, Section 7.5: https://tools.ietf.org/html/rfc7950#section-7.5
				''';
			];
		]).register('must', [
			new Template('must') => [
				template = '''
					must "${1:expression}";$0
				''';
				documentation = '''
					The "must" statement, which is optional, takes as an argument a string that contains an XPath expression. It is used to formally declare a constraint on valid data.
					
					RFC 7950, Section 7.5.3: https://tools.ietf.org/html/rfc7950#section-7.5.3
				''';
			];
		]).register('error-message', [
			new Template('error-message') => [
				template = '''
					error-message "${1:error-message}";$0
				''';
				documentation = '''
					The "error-message" statement, which is optional, takes a string as an argument. If the constraint evaluates to "false", the string is passed as <error-message> in the <rpc-error> in NETCONF.
					
					RFC 7950, Section 7.5.4.1: https://tools.ietf.org/html/rfc7950#section-7.5.4.1
				''';
			];
		]).register('error-app-tag', [
			new Template('error-app-tag') => [
				template = '''
					error-app-tag ${1:error-app-tag};$0
				''';
				documentation = '''
					The "error-app-tag" statement, which is optional, takes a string as an argument. If the constraint evaluates to "false", the string is passed as <error-app-tag> in the <rpc-error> in NETCONF.
					
					RFC 7950, Section 7.5.4.2: https://tools.ietf.org/html/rfc7950#section-7.5.4.2
				''';
			];
		]).register('presence', [
			new Template('presence') => [
				template = '''
					presence ${1:meaning};$0
				''';
				documentation = '''
					The "presence" statement assigns a meaning to the presence of a container in the data tree. It takes as an argument a string that contains a textual description of what the node's presence means.
					
					RFC 7950, Section 7.5.5: https://tools.ietf.org/html/rfc7950#section-7.5.5
				''';
			];
		]).register('leaf', [
			new Template('leaf') => [
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
			];
		]).register('mandatory', [
			new Template('mandatory') => [
				template = '''
					mandatory ${1:true};$0
				''';
				documentation = '''
					The "mandatory" statement, which is optional, takes as an argument the string "true" or "false" and puts a constraint on valid data. If not specified, the default is "false".
					
					RFC 7950, Section 7.6.5: https://tools.ietf.org/html/rfc7950#section-7.6.5
				''';
			];
		]).register('leaf-list', [
			new Template('leaf-list') => [
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
			];
		]).register('min-elements', [
			new Template('min-elements') => [
				template = '''
					min-elements ${1:0};$0
				''';
				documentation = '''
					The "min-elements" statement, which is optional, takes as an argument a non-negative integer that puts a constraint on valid list entries.
					
					RFC 7950, Section 7.7.5: https://tools.ietf.org/html/rfc7950#section-7.7.5
				''';
			];
		]).register('max-elements', [
			new Template('max-elements') => [
				template = '''
					max-elements ${1:unbounded};$0
				''';
				documentation = '''
					The "max-elements" statement, which is optional, takes as an argument a positive integer or the string "unbounded", which puts a constraint on valid list entries.
					
					RFC 7950, Section 7.7.6: https://tools.ietf.org/html/rfc7950#section-7.7.6
				''';
			];
		]).register('ordered-by', [
			new Template('ordered-by') => [
				template = '''
					ordered-by ${1:system};$0
				''';
				documentation = '''
					The "ordered-by" statement defines whether the order of entries within a list are determined by the user or the system. The argument is one of the strings "system" or "user". If not present, ordering defaults to "system".
					
					RFC 7950, Section 7.7.7: https://tools.ietf.org/html/rfc7950#section-7.7.7
				''';
			];
		]).register('list', [
			new Template('list') => [
				template = '''
					list ${1:list-name} {
					  $0
					}
				''';
				documentation = '''
					The "list" statement is used to define an interior data node in the schema tree. A list node may exist in multiple instances in the data tree.
					
					RFC 7950, Section 7.8: https://tools.ietf.org/html/rfc7950#section-7.8
				''';
			];
		]).register('key', [
			new Template('key') => [
				template = '''
					key ${1:};$0
				''';
				documentation = '''
					The "key" statement, which must be present if the list represents configuration and may be present otherwise, takes as an argument a string that specifies a space-separated list of one or more leaf identifiers of this list.
					
					RFC 7950, Section 7.8.2: https://tools.ietf.org/html/rfc7950#section-7.8.2
				''';
			];
		]).register('unique', [
			new Template('unique') => [
				template = '''
					unique ${1:}$2;$0
				''';
				documentation = '''
					The "unique" statement is used to put constraints on valid list entries. It takes as an argument a string that contains a space- separated list of schema node identifiers, which must be given in the descendant form.
					
					RFC 7950, Section 7.8.3: https://tools.ietf.org/html/rfc7950#section-7.8.3
				''';
			];
		]).register('choice', [
			new Template('choice') => [
				template = '''
					choice ${1:choice-name} {
					  $0
					}
				''';
				documentation = '''
					The "choice" statement defines a set of alternatives, only one of which may be present in any one data tree. The argument is an identifier, followed by a block of substatements that holds detailed choice information.
					
					RFC 7950, Section 7.8.3: https://tools.ietf.org/html/rfc7950#section-7.8.3
				''';
			];
		]).register('case', [
			new Template('case') => [
				template = '''
					case ${1:case-name} {
					  $0
					}
				''';
				documentation = '''
					The "case" statement is used to define branches of the choice. It takes as an argument an identifier, followed by a block of substatements that holds detailed case information.
					
					RFC 7950, Section 7.9.1: https://tools.ietf.org/html/rfc7950#section-7.9.2
				''';
			];
		]).register('anydata', [
			new Template('anydata') => [
				template = '''
					anydata ${1:data};$0
				''';
				documentation = '''
					The "anydata" statement defines an interior node in the schema tree. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed anydata information.
					
					RFC 7950, Section 7.10: https://tools.ietf.org/html/rfc7950#section-7.10
				''';
			];
		]).register('anyxml', [
			new Template('anyxml') => [
				template = '''
					anyxml ${1:xml};$0
				''';
				documentation = '''
					The "anyxml" statement defines an interior node in the schema tree. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed anyxml information.
					
					RFC 7950, Section 7.11: https://tools.ietf.org/html/rfc7950#section-7.11
				''';
			];
		]).register('grouping', [
			new Template('grouping') => [
				template = '''
					grouping ${1:grouping-name} {
					  $0
					}
				''';
				documentation = '''
					The "grouping" statement is used to define a reusable block of nodes, which may be used locally in the module or submodule, and by other modules that import from it.
					
					RFC 7950, Section 7.12: https://tools.ietf.org/html/rfc7950#section-7.12
				''';
			];
		]).register('uses', [
			new Template('uses') => [
				template = '''
					uses ${1:group-name} {
					  $0
					}
				''';
				documentation = '''
					The "uses" statement is used to reference a "grouping" definition. It takes one argument, which is the name of the grouping.
					
					RFC 7950, Section 7.13: https://tools.ietf.org/html/rfc7950#section-7.13
				''';
			];
		]).register('refine', [
			new Template('refine') => [
				template = '''
					refine ${1:} {
					  $0
					}
				''';
				documentation = '''
					Some of the properties of each node in the grouping can be refined with the "refine" statement. The argument is a string that identifies a node in the grouping. This node is called the refine's target node.
					
					RFC 7950, Section 7.13.2: https://tools.ietf.org/html/rfc7950#section-7.13.2
				''';
			];
		]).register('rpc', [
			new Template('rpc') => [
				template = '''
					rpc ${1:rpc-name} {
					  $0
					}
				''';
				documentation = '''
					The "rpc" statement is used to define an RPC operation. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed rpc information. This argument is the name of the RPC.
					
					RFC 7950, Section 7.14: https://tools.ietf.org/html/rfc7950#section-7.14
				''';
			];
		]).register('input', [
			new Template('input') => [
				template = '''
					input {
					  $0
					}
				''';
				documentation = '''
					The "input" statement, which is optional, is used to define input parameters to the operation. It does not take an argument. The substatements to "input" define nodes under the operation's input node.
					
					RFC 7950, Section 7.14.2: https://tools.ietf.org/html/rfc7950#section-7.14.2
				''';
			];
		]).register('output', [
			new Template('output') => [
				template = '''
					output {
					  $0
					}
				''';
				documentation = '''
					The "output" statement, which is optional, is used to define output parameters to the RPC operation. It does not take an argument. The substatements to "output" define nodes under the operation's output node.
					
					RFC 7950, Section 7.14.3: https://tools.ietf.org/html/rfc7950#section-7.14.3
				''';
			];
		]).register('action', [
			new Template('action') => [
				template = '''
					action ${1:action-name} {
					  $0
					}
				''';
				documentation = '''
					The "action" statement is used to define an operation connected to a specific container or list data node. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed action information. The argument is the name of the action.
					
					RFC 7950, Section 7.15: https://tools.ietf.org/html/rfc7950#section-7.15
				''';
			];
		]).register('notification', [
			new Template('notification') => [
				template = '''
					notification ${1:action-name} {
					  $0
					}
				''';
				documentation = '''
					The "notification" statement is used to define a notification. It takes one argument, which is an identifier, followed by a block of substatements that holds detailed notification information. The "notification" statement defines a notification node in the schema tree.
					
					RFC 7950, Section 7.16: https://tools.ietf.org/html/rfc7950#section-7.16
				''';
			];
		]).register('augment', [
			new Template('augment') => [
				template = '''
					augment ${1:} {
					  $0
					}
				''';
				documentation = '''
					The "augment" statement allows a module or submodule to add to a schema tree defined in an external module, or in the current module and its submodules, and to add to the nodes from a grouping in a "uses" statement. The argument is a string that identifies a node in the schema tree.
					
					RFC 7950, Section 7.17: https://tools.ietf.org/html/rfc7950#section-7.17
				''';
			];
		]).register('identity', [
			new Template('identity') => [
				template = '''
					identity ${1:identity-name} {
					  $0
					}
				''';
				documentation = '''
					The "identity" statement is used to define a new globally unique, abstract, and untyped identity. The identity's only purpose is to denote its name, semantics, and existence. An identity can be either defined from scratch or derived from one or more base identities.
					
					RFC 7950, Section 7.18: https://tools.ietf.org/html/rfc7950#section-7.18
				''';
			];
		]).register('base', [
			new Template('base') => [
				template = '''
					base ${1:};$0
				''';
				documentation = '''
					The "base" statement, which is optional, takes as an argument a string that is the name of an existing identity, from which the new identity is derived.
					
					RFC 7950, Section 7.18.2: https://tools.ietf.org/html/rfc7950#section-7.18.2
				''';
			];
		]).register('extension', [
			new Template('extension') => [
				template = '''
					extension ${1:extension-name} {
					  $0
					}
				''';
				documentation = '''
					The "extension" statement allows the definition of new statements within the YANG language. This new statement definition can be imported and used by other modules.
					
					RFC 7950, Section 7.19: https://tools.ietf.org/html/rfc7950#section-7.19
				''';
			];
		]).register('argument', [
			new Template('argument') => [
				template = '''
					argument ${1:argument-name} {
					  $0
					}
				''';
				documentation = '''
					The "argument" statement, which is optional, takes as an argument a string that is the name of the argument to the keyword. The argument's name is used in the YIN mapping, where it is used as an XML attribute or element name, depending on the argument's "yin-element" statement.
					
					RFC 7950, Section 7.19.2: https://tools.ietf.org/html/rfc7950#section-7.19.2
				''';
			];
		]).register('yin-element', [
			new Template('yin-element') => [
				template = '''
					yin-element ${1:yin-element-name} {
					  $0
					}
				''';
				documentation = '''
					The "yin-element" statement, which is optional, takes as an argument the string "true" or "false".  This statement indicates whether the argument is mapped to an XML element in YIN or to an XML attribute.
					
					RFC 7950, Section 7.19.2.2: https://tools.ietf.org/html/rfc7950#section-7.19.2.2
				''';
			];
		]).register('feature', [
			new Template('feature') => [
				template = '''
					feature ${1:feature-name} {
					  $0
					}
				''';
				documentation = '''
					The "feature" statement is used to define a mechanism by which portions of the schema are marked as conditional.  A feature name is defined that can later be referenced using the "if-feature" statement.
					
					RFC 7950, Section 7.20.1: https://tools.ietf.org/html/rfc7950#section-7.20.1
				''';
			];
		]).register('if-feature', [
			new Template('if-feature') => [
				template = '''
					if-feature ${1:}$2;$0
				''';
				documentation = '''
					The "if-feature" statement makes its parent statement conditional. The argument is a boolean expression over feature names.  In this expression, a feature name evaluates to "true" if and only if the feature is supported by the server.
					
					RFC 7950, Section 7.20.2: https://tools.ietf.org/html/rfc7950#section-7.20.2
				''';
			];
		]).register('deviation', [
			new Template('deviation') => [
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
			];
		]).register('deviate', [
			new Template('deviate') => [
				template = '''
					deviate ${1:deviate-action} {
					  $2
					}$0
				''';
				documentation = '''
					The "deviate" statement defines how the server's implementation of the target node deviates from its original definition.  The argument is one of the strings "not-supported", "add", "replace", or "delete".
					
					RFC 7950, Section 7.20.3.2: https://tools.ietf.org/html/rfc7950#section-7.20.3.2
				''';
			];
		]).register('config', [
			new Template('config') => [
				template = '''
					config ${1:false};$0
				''';
				documentation = '''
					The "config" statement takes as an argument the string "true" or "false".  If "config" is "true", the definition represents configuration.  Data nodes representing configuration are part of configuration datastores.
					
					RFC 7950, Section 7.21.1: https://tools.ietf.org/html/rfc7950#section-7.21.1
				''';
			];
		]).register('status', [
			new Template('status') => [
				template = '''
					status ${1:current};$0
				''';
				documentation = '''
					The "status" statement takes as an argument one of the strings "current", "deprecated", or "obsolete". If no status is specified, the default is "current".
					
					RFC 7950, Section 7.21.2: https://tools.ietf.org/html/rfc7950#section-7.21.2
				''';
			];
		]).register('description', [
			new Template('description') => [
				template = '''
					description "${1:}";$0
				''';
				documentation = '''
					The "description" statement takes as an argument a string that contains a human-readable textual description of this definition. The text is provided in a language (or languages) chosen by the module developer.
					
					RFC 7950, Section 7.21.3: https://tools.ietf.org/html/rfc7950#section-7.21.3
				''';
			];
		]).register('reference', [
			new Template('reference') => [
				template = '''
					reference "${1:}";$0
				''';
				documentation = '''
					The "reference" statement takes as an argument a string that is a human-readable cross-reference to an external document -- either another module that defines related management information or a document that provides additional information relevant to this definition.
					
					RFC 7950, Section 7.21.4: https://tools.ietf.org/html/rfc7950#section-7.21.4
				''';
			];
		]).register('when', [
			new Template('when') => [
				template = '''
					when "${1:expression}";$0
				''';
				documentation = '''
					 The "when" statement makes its parent data definition statement conditional.  The node defined by the parent data definition statement is only valid when the condition specified by the "when" statement is satisfied.  The statement's argument is an XPath expression, which is used to formally specify this condition.
					
					RFC 7950, Section 7.21.5: https://tools.ietf.org/html/rfc7950#section-7.21.5
				''';
			];
		]).unmodifiableMultimap;

	}

}
