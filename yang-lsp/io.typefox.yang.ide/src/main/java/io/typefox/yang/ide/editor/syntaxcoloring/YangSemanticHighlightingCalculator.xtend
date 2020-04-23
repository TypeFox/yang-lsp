package io.typefox.yang.ide.editor.syntaxcoloring

import com.google.common.base.Preconditions
import com.google.common.base.Predicate
import com.google.common.collect.ImmutableList
import com.google.common.collect.ImmutableSet
import com.google.common.collect.Lists
import com.google.inject.Inject
import com.google.inject.Singleton
import io.typefox.yang.findReferences.YangReferenceFinder
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.yang.Action
import io.typefox.yang.yang.Anydata
import io.typefox.yang.yang.Anyxml
import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.Case
import io.typefox.yang.yang.Choice
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Default
import io.typefox.yang.yang.Description
import io.typefox.yang.yang.Deviation
import io.typefox.yang.yang.Extension
import io.typefox.yang.yang.Feature
import io.typefox.yang.yang.Grouping
import io.typefox.yang.yang.GroupingRef
import io.typefox.yang.yang.Identity
import io.typefox.yang.yang.IfFeature
import io.typefox.yang.yang.Key
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.LeafList
import io.typefox.yang.yang.Must
import io.typefox.yang.yang.Notification
import io.typefox.yang.yang.Refine
import io.typefox.yang.yang.Rpc
import io.typefox.yang.yang.SchemaNode
import io.typefox.yang.yang.Typedef
import io.typefox.yang.yang.When
import java.util.List
import org.eclipse.core.runtime.OperationCanceledException
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.ide.editor.syntaxcoloring.DefaultSemanticHighlightingCalculator
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor
import org.eclipse.xtext.ide.server.semanticHighlight.ISemanticHighlightingStyleToTokenMapper
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.internal.Log

import static io.typefox.yang.yang.YangPackage.Literals.*
import org.eclipse.xtext.ide.editor.syntaxcoloring.HighlightingStyles

@Log
@Singleton
class YangSemanticHighlightingCalculator extends DefaultSemanticHighlightingCalculator implements ISemanticHighlightingStyleToTokenMapper {

	/**
	 * The double-quote (&quot;) character.
	 */
	static val char DOUBLE_QUOTE = '"';

	/**
	 * The single-quote (&apos;) character.
	 */
	static val char QUOTE = "'".charAt(0);

	/**
	 * The space separator character.
	 */
	static val char SPACE_SEPARATOR = ' ';

	@Inject
	extension YangExtensions;

	@Inject
	extension YangReferenceFinder;

	static interface Styles {
		/*1a*/ val NORMAL_DATA_NODE_STYLE = 'yang-normal-data-node';
		/*1b*/ val ALTERNATIVE_DATA_NODE_STYLE = 'yang-alternative-data-node';
		/*1c*/ val REUSABLE_DATA_NODE_STYLE = 'yang-reusable-data-node';
		/*2 */ val EXTENDIBLE_MODULE_STATEMENT_STYLE = 'yang-extendible-module-statement';
		/*3a*/ val CONDITIONAL_MODULE_STATEMENT_STYLE = 'yang-conditional-module-statement';
		/*3b*/ val CONSTRAINT_MODULE_STATEMENT_STYLE = 'yang-constraint-module-statement';
		/*4 */ val INTERFACE_STATEMENT_STYLE = 'yang-interface-statement';
		/*5 */ val REFERENCEABLE_STATEMENT_STYLE = 'yang-referenceable-statement';
		/*6a*/ val DESCRIPTION_STYLE = 'yang-description-statement';
		/*6b*/ val DEFAULT_STYLE = 'yang-default-statement';
		/*6c*/ val KEY_STYLE = 'yang-key-statement,';
	}

	static interface Scopes {
		val NORMAL_DATA_NODE_SCOPES = #['keyword.control'].yang;
		val ALTERNATIVE_DATA_NODE_SCOPES = #['beginning.punctuation.definition.list.markdown'].yang;
		val REUSABLE_DATA_NODE_SCOPES = #['support.type.property-name'].yang;
		val EXTENDIBLE_MODULE_STATEMENT_SCOPES = #['punctuation.definition.tag'].yang;
		val CONDITIONAL_MODULE_STATEMENT_SCOPES = #['emphasis'].yang;
		val CONSTRAINT_MODULE_STATEMENT_SCOPES = #['strong'].yang;
		val INTERFACE_STATEMENT_SCOPES = #['support.type.property-name'].yang;
		val REFERENCEABLE_STATEMENT_SCOPES = #['constant.regexp'].yang;
		val DESCRIPTION_SCOPES = #['keyword.other.unit'].yang;
		val DEFAULT_SCOPES = #['keyword.operator'].yang;
		val KEY_SCOPES = #['string.regexp'].yang;
	}

	public static val STYLE_MAPPINGS = #{
		Styles.NORMAL_DATA_NODE_STYLE -> Scopes.NORMAL_DATA_NODE_SCOPES,
		Styles.ALTERNATIVE_DATA_NODE_STYLE -> Scopes.ALTERNATIVE_DATA_NODE_SCOPES,
		Styles.REUSABLE_DATA_NODE_STYLE -> Scopes.REUSABLE_DATA_NODE_SCOPES,
		Styles.EXTENDIBLE_MODULE_STATEMENT_STYLE -> Scopes.EXTENDIBLE_MODULE_STATEMENT_SCOPES,
		Styles.CONDITIONAL_MODULE_STATEMENT_STYLE -> Scopes.CONDITIONAL_MODULE_STATEMENT_SCOPES,
		Styles.CONSTRAINT_MODULE_STATEMENT_STYLE -> Scopes.CONSTRAINT_MODULE_STATEMENT_SCOPES,
		Styles.INTERFACE_STATEMENT_STYLE -> Scopes.INTERFACE_STATEMENT_SCOPES,
		Styles.REFERENCEABLE_STATEMENT_STYLE -> Scopes.REFERENCEABLE_STATEMENT_SCOPES,
		Styles.DESCRIPTION_STYLE -> Scopes.DESCRIPTION_SCOPES,
		Styles.DEFAULT_STYLE -> Scopes.DEFAULT_SCOPES,
		Styles.KEY_STYLE -> Scopes.KEY_SCOPES
	};

	override protected highlightElement(EObject object, IHighlightedPositionAcceptor acceptor,
		CancelIndicator cancelIndicator) {

		if (cancelIndicator.canceled) {
			throw new OperationCanceledException();
		}

		object.doHighlightConditionalStatement(acceptor);
		return object.doHighlightElement(acceptor);
	}

	protected dispatch def boolean doHighlightElement(EObject it, IHighlightedPositionAcceptor acceptor) {
		return false;
	}

	/*
	 * 1.
	 * Data Definition Node, Schema Node and Reusable Node:
	 * In short, when presenting data in yang modeling language, there has different kinds of data nodes to be highlighted,
	 * (normal data, alternative data, and reusable data).
	 */
	/*
	 * 1a.
	 * Data Def Node (leaf, leaf-list, list, container, anydata, anyxml) are subset of Schema Node, they really exists in the real final data tree. 
	 */
	protected dispatch def boolean doHighlightElement(Leaf it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.NORMAL_DATA_NODE_STYLE);
	}

	protected dispatch def boolean doHighlightElement(LeafList it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.NORMAL_DATA_NODE_STYLE);
	}

	protected dispatch def boolean doHighlightElement(io.typefox.yang.yang.List it,
		IHighlightedPositionAcceptor acceptor) {

		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.NORMAL_DATA_NODE_STYLE);
	}

	protected dispatch def boolean doHighlightElement(Container it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.NORMAL_DATA_NODE_STYLE);
	}

	protected dispatch def boolean doHighlightElement(Anydata it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.NORMAL_DATA_NODE_STYLE);
	}

	protected dispatch def boolean doHighlightElement(Anyxml it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.NORMAL_DATA_NODE_STYLE);
	}

	/*
	 * 1b.
	 * In Schema node (choice, case and data def node), choice and case defines a set of alternatives of data, so not all cases will appear in
	 * the final data tree.
	 */
	protected dispatch def boolean doHighlightElement(Choice it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.ALTERNATIVE_DATA_NODE_STYLE);
	}

	protected dispatch def boolean doHighlightElement(Case it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.ALTERNATIVE_DATA_NODE_STYLE);
	}

	/*
	 * 1c.
	 * Reusable Node, (grouping: reusable def, uses: reusable reference), grouping only defines reusable data, but until it (grouping) is be
	 * 'uses' somewhere else, they (data def in grouping) will not appear in final data tree.
	 */
	protected dispatch def boolean doHighlightElement(Grouping it, IHighlightedPositionAcceptor acceptor) {
		if (referencedFromUses) {
			doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.REUSABLE_DATA_NODE_STYLE);
		}
		return false;
	}

	protected def boolean isReferencedFromUses(Grouping it) {
		val resource = eResource;
		return isReferencedFrom(it, [
			val groupingRef = resource.getEObject(key.fragment);
			if (groupingRef instanceof GroupingRef) {
				return USES.isSuperTypeOf(groupingRef.eContainer?.eClass);
			}
			return false;
		]);
	}

	/*
	 * 2.
	 * Extendible module statement:
	 * Augment, Refine and Deviation statements have the ability to extend/impact (Add, Replace, Remove, Disable) existing modules.
	 * All of them can change specific existing module, and then a new derived module will be used in runtime.
	 * The difference between them is that they have their own extending target and extending ways.
	 * Therefore, it is important to highlight these extending part of a module.
	 */
	protected dispatch def boolean doHighlightElement(Augment it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, AUGMENT__PATH, Styles.EXTENDIBLE_MODULE_STATEMENT_STYLE);
	}

	protected dispatch def boolean doHighlightElement(Refine it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, REFINE__NODE, Styles.EXTENDIBLE_MODULE_STATEMENT_STYLE);
	}

	protected dispatch def boolean doHighlightElement(Deviation it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, DEVIATION__REFERENCE, Styles.EXTENDIBLE_MODULE_STATEMENT_STYLE);
	}

	/*
	 * 3.
	 * Conditional module statement:
	 * In yang modeling language, 'when', 'if-feature' could be used to define conditional schema node. 'must' are used to define constraint
	 * of some schema node and operation.
	 * They all indicate that those nodes which applied with them (when, if-feature, must) are conditionally enabled/valid/available.
	 * So they are also valuable to be highlighted.
	 * 
	 * For 'when', it is like 'if-feature', but just considering information from other aspect (for example, during system runtime, when a
	 * system trying to load yang module). So simply to say, when a schema node has when/if-feature, the schema node will not always be valid/exists,
	 * it needs additional information to decide.
	 * 
	 * For 'must', it is one kind of constraint for schema node. If the defined constraint is violated, there should have some warning/error message.
	 * So it will be good to highlight a node when it has 'must'. It will reminder yang module designer or user, there might be waring/error message
	 * trigger by that node. Of cause, there is no need to analysis/evaluate these condition/constraint in detail, but just show those nodes which
	 * has conditional definition and highlight them to yang designer and user.
	 */
	protected def void doHighlightConditionalStatement(EObject it, IHighlightedPositionAcceptor acceptor) {
		if (it instanceof SchemaNode) {
			if (!substatementsOfType(When).nullOrEmpty || !substatementsOfType(IfFeature).nullOrEmpty) {
				doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.CONDITIONAL_MODULE_STATEMENT_STYLE);
			}
			if (!substatementsOfType(Must).nullOrEmpty) {
				doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.CONSTRAINT_MODULE_STATEMENT_STYLE);
			}
		}
	}

	/*
	 * 4.
	 * Interface statement:
	 * There are Action/RPC/Notification statement in yang modeling language. Apparently, they are quite different comparing with data nodes.
	 * They are interface (Operation/Notification) definition of some models. It makes sense to distinguish them apart from data nodes.
	 */
	protected dispatch def boolean doHighlightElement(Rpc it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.INTERFACE_STATEMENT_STYLE);
	}

	protected dispatch def boolean doHighlightElement(Notification it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.INTERFACE_STATEMENT_STYLE);
	}

	protected dispatch def boolean doHighlightElement(Action it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.INTERFACE_STATEMENT_STYLE);
	}

	/*
	 * 5.
	 * Referenceable statement:
	 * Identify/Feature/Extension/TypeDef are other conceptional definition statement.
	 * They will only be valuable or meaningful when they are referenced from other schema node or interface/operation node.
	 */
	protected dispatch def boolean doHighlightElement(Identity it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightReferenceableStatement(acceptor);
	}

	protected dispatch def boolean doHighlightElement(Feature it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightReferenceableStatement(acceptor);
	}

	protected dispatch def boolean doHighlightElement(Extension it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightReferenceableStatement(acceptor);
	}

	protected dispatch def boolean doHighlightElement(Typedef it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightReferenceableStatement(acceptor);
	}

	protected def boolean doHighlightReferenceableStatement(EObject it, IHighlightedPositionAcceptor acceptor) {
		if (referencedFromSchemaNode) {
			doHighlightNodeForFeature(acceptor, SCHEMA_NODE__NAME, Styles.REFERENCEABLE_STATEMENT_STYLE);
		}
		return false;
	}

	protected def boolean isReferencedFromSchemaNode(EObject it) {
		return isReferencedFrom(it, [SCHEMA_NODE.isSuperTypeOf(value.EReferenceType)]);
	}

	protected def boolean isReferencedFrom(EObject it, Predicate<Pair<URI, EReference>> predicate) {
		val resource = eResource;
		val resourceUri = resource.URI;
		val allReferences = collectReferences(resource);
		// Everything that references the current object from the current resource.
		val referencesForObject = allReferences.get(EcoreUtil.getURI(it)).filter[resourceUri == key.trimFragment];
		if (referencesForObject.nullOrEmpty) {
			return false;
		}
		return referencesForObject.exists[predicate.apply(it)];
	}

	/*
	 * 6.
	 * Other statement:
	 * Of cause, there are lot's of other statements. From our experience, currently, 'key', 'default' could be considered to be highlighted.
	 * Meanwhile 'description' providers most important info for all kinds of nodes, so it is important to make 'description' much readable.
	 */
	protected dispatch def boolean doHighlightElement(Description it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, DESCRIPTION__DESCRIPTION, Styles.DESCRIPTION_STYLE);
	}

	protected dispatch def boolean doHighlightElement(Default it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, DEFAULT__DEFAULT_STRING_VALUE, Styles.DEFAULT_STYLE);
	}

	protected dispatch def boolean doHighlightElement(Key it, IHighlightedPositionAcceptor acceptor) {
		return doHighlightNodeForFeature(acceptor, KEY__REFERENCES, Styles.KEY_STYLE);
	}

	// Null-guard when working with broken ASTs.
	protected dispatch def boolean doHighlightElement(Void it, IHighlightedPositionAcceptor acceptor) {
		return true;
	}

	protected def boolean doHighlightNodeForFeature(EObject object, IHighlightedPositionAcceptor acceptor,
		EStructuralFeature feature, String styleId) {

		val nodes = NodeModelUtils.findNodesForFeature(object, feature)
		acceptor.acceptNodes(nodes, styleId);
		return false;
	}

	protected def void acceptNode(IHighlightedPositionAcceptor acceptor, INode node, String style, String... rest) {
		if (node !== null) {
			val text = node.text;
			var length = node.length;
			var offset = node.offset;
			val firstQuoteOffset = text.firstQuoteOffset;
			if (firstQuoteOffset > 0) {
				offset = offset - firstQuoteOffset;
				length = length + firstQuoteOffset + 1;
			}
			acceptor.addPosition(offset, length, Lists.asList(style, rest));
		}
	}

	/**
	 * Returns the offset of the first non-whitespace character if that is either a single- or a double-quote and the last character
	 * of the {@code text} argument does not equal with the first matching quote.
	 * Otherwise, returns {@code 0};
	 */
	// TODO: Review this. This code stinks!
	protected def int getFirstQuoteOffset(String text) {
		if (text.nullOrEmpty) {
			return 0;
		}
		var counter = 0;
		for (var i = 0; i < text.length; i++) {
			val c = text.charAt(i);
			if (SPACE_SEPARATOR === c) {
				counter++;
			} else {
				// Starts with quote or double quote, and does not end with that.
				if ((c === QUOTE || c === DOUBLE_QUOTE) && text.charAt(text.length - 1) !== c) {
					return counter;
				}
				return 0;
			}
		}
		return 0;
	}

	protected def void acceptNodes(IHighlightedPositionAcceptor acceptor, Iterable<INode> nodes, String style,
		String... rest) {

		nodes.forEach[acceptor.acceptNode(it, style, rest)];
	}

	override getAllStyleIds() {
		return ImmutableSet.copyOf(STYLE_MAPPINGS.keySet);
	}

	override toScopes(String styleId) {
		if (styleId == HighlightingStyles.TASK_ID) {
			return emptyList;
		}
		val scopes = STYLE_MAPPINGS.get(styleId);
		Preconditions.checkNotNull(scopes, '''Cannot map style ID '«styleId»' to the corresponding TextMate scopes.''');
		return scopes;
	}

	private static def List<String> yang(List<String> scopes) {
		return ImmutableList.builder.addAll(scopes).add('source.yang').build;
	}

}
