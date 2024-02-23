package io.typefox.yang.processor;

import static com.google.common.collect.Lists.newArrayList;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.annotation.Nullable;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;

import com.google.common.base.Objects;
import com.google.common.collect.Sets;

import io.typefox.yang.processor.FeatureExpressions.FeatureCondition;
import io.typefox.yang.yang.Anyxml;
import io.typefox.yang.yang.Config;
import io.typefox.yang.yang.Container;
import io.typefox.yang.yang.Default;
import io.typefox.yang.yang.IfFeature;
import io.typefox.yang.yang.Key;
import io.typefox.yang.yang.Leaf;
import io.typefox.yang.yang.LeafList;
import io.typefox.yang.yang.Mandatory;
import io.typefox.yang.yang.MaxElements;
import io.typefox.yang.yang.MinElements;
import io.typefox.yang.yang.Must;
import io.typefox.yang.yang.Path;
import io.typefox.yang.yang.Presence;
import io.typefox.yang.yang.SchemaNode;
import io.typefox.yang.yang.Type;
import io.typefox.yang.yang.TypeReference;
import io.typefox.yang.yang.Typedef;

public class ProcessedDataModel {

	private List<ModuleData> modules;
	private List<MessageEntry> messages = new ArrayList<>();

	public void addModule(ModuleData moduleData) {
		if (modules == null)
			modules = newArrayList();
		modules.add(moduleData);
	}

	@Nullable
	public List<ModuleData> getModules() {
		return modules;
	}

	public void addError(String moduleFile, int line, int col, String message, boolean processorError) {
		var msgEntry = new MessageEntry();
		msgEntry.moduleFile = moduleFile == null ? "<unknown>" : moduleFile;
		msgEntry.line = line;
		msgEntry.col = col;
		msgEntry.severity = Severity.Error;
		msgEntry.message = message;
		msgEntry.loadingError = !processorError;
		messages.add(msgEntry);
	}

	public void addProcessorError(String moduleFile, EObject source, String message) {
		var line = -1;
		ICompositeNode node = NodeModelUtils.getNode(source);
		if (node != null) {
			line = node.getStartLine();
		}
		addError(moduleFile, line, -1, message, true);
	}

	public Iterator<MessageEntry> getLoadingErrors() {
		return messages.stream().filter(msg -> msg.loadingError).iterator();
	}

	public Iterator<MessageEntry> getProcessingErrors() {
		return messages.stream().filter(msg -> !msg.loadingError).iterator();
	}

	public List<MessageEntry> getMessages() {
		return messages;
	}

	public static class HasStatements extends Named {

		public HasStatements(ElementIdentifier id) {
			super(id);
		}

		private List<HasStatements> children;
		private transient HasStatements parent;

		public void addToChildren(HasStatements child) {
			if (children == null)
				children = newArrayList();
			children.add(child);
			child.parent = this;
		}

		public HasStatements getParent() {
			return parent;
		}

		public List<HasStatements> getChildren() {
			return children;
		}
	}

	public static class ElementIdentifier {
		final public String name, prefix;

		final static public ElementIdentifier UNRESOLVED = new ElementIdentifier("<unresoved>", null);

		public ElementIdentifier(String name, String prefix) {
			super();
			this.name = name;
			this.prefix = prefix;
		}

		@Override
		public String toString() {
			return prefix != null ? (prefix + ":" + name) : name;
		}

		@Override
		public int hashCode() {
			final int prime = 31;
			int result = 1;
			result = prime * result + ((this.name == null) ? 0 : this.name.hashCode());
			return prime * result + ((this.prefix == null) ? 0 : this.prefix.hashCode());
		}

		@Override
		public boolean equals(final Object obj) {
			if (this == obj)
				return true;
			if (obj == null)
				return false;
			if (getClass() != obj.getClass())
				return false;
			ElementIdentifier other = (ElementIdentifier) obj;
			if (this.name == null) {
				if (other.name != null)
					return false;
			} else if (!this.name.equals(other.name))
				return false;
			if (this.prefix == null) {
				if (other.prefix != null)
					return false;
			} else if (!this.prefix.equals(other.prefix))
				return false;
			return true;
		}
	}

	public static class Named {
		private ElementIdentifier id;

		public Named(ElementIdentifier id) {
			this.id = id;
		}

		public ElementIdentifier getName() {
			return id;
		}

		public String getSimpleName() {
			if (id == null) {
				return null;
			}
			return id.name;
		}
	}

	public static class ModuleData extends HasStatements {
		private transient String uri;

		private List<HasStatements> rpcs;

		public ModuleData(ElementIdentifier name) {
			super(name);
		}

		public void addToRpcs(ElementData rpc) {
			if (rpcs == null)
				rpcs = newArrayList();
			rpcs.add(rpc);
		}

		public List<HasStatements> getRpcs() {
			return rpcs;
		}

		public void setURI(String uri) {
			this.uri = uri;
		}

		public String getUri() {
			return uri;
		}
	}

	static public class ValueType {
		final String prefix, name;
		final transient boolean forceSimpleName;

		public ValueType(String prefix, String name) {
			this(prefix, name, false);
		}

		public ValueType(String prefix, String name, boolean forceSimpleName) {
			super();
			this.prefix = prefix;
			this.name = name == null ? "unknown" : name;
			this.forceSimpleName = forceSimpleName;
		}

		@Override
		public String toString() {
			return (prefix != null && !forceSimpleName) ? (prefix + ":" + name) : name;
		}
	}

	static public enum ElementKind {
		// SchemaNodes
		Action, Case, Choice,
		// DataSchemaNodes
		AnyXml, Container, Leaf, LeafList, List,
		// SchemaNodes
		Grouping, Input, Notification, Output, Rpc;

		public static Set<ElementKind> mayOmitCase = Sets.newHashSet(AnyXml, Container, Leaf, List, LeafList);

		/**
		 * If choices case can be omitted for this child statement. It's elementkind is
		 * returned. null otherwise.
		 */
		public static ElementKind mayOmitCaseKind(EObject obj) {
			if(obj instanceof Anyxml) {
				return AnyXml;
			} else if(obj instanceof Container) {
				return Container;
			} else if(obj instanceof Leaf) {
				return Leaf;
			} else if(obj instanceof List) {
				return List;
			} else if(obj instanceof LeafList) {
				return LeafList;
			}
			return null;
		}
	}

	static public enum AccessKind {
		not_set, rw, w, x, ro, n
	}

	static public enum Cardinality {
		not_set(null), mandatory(""), optional("?"), many("*"), presence("!");

		private String label;

		Cardinality(String label) {
			this.label = label;
		}

		@Override
		public String toString() {
			return label;
		}
	}

	static public enum Status {
		current("+"), obsolete("o"), deprecated("x");

		private String label;

		Status(String label) {
			this.label = label;
		}

		@Override
		public String toString() {
			return label;
		}

		static Status toStatus(String name) {
			try {
				return valueOf(name);
			} catch (IllegalArgumentException e) {
			}
			return current;
		}
	}

	public static class ElementData extends HasStatements {

		final ElementKind elementKind;
		ValueType type;
		private List<String> featureConditions;
		private AccessKind accessKind = AccessKind.not_set;
		Cardinality cardinality;
		Status status;

		transient private SchemaNode origin;

		/**
		 * 0..1 Node properties that can be changed by a Deviate
		 */
		public String defaultValue, maxElements, minElements = null;

		/**
		 * 0..n Node properties that can be changed by a Deviate
		 */
		public List<String> mustConstraint = null;

		private ElementData(ElementIdentifier elementId, ElementKind elementKind) {
			super(elementId);
			this.elementKind = elementKind;
		}

		public ElementData(SchemaNode ele, ElementKind elementKind) {
			this(ProcessorUtility.qualifiedName(ele), elementKind);
			this.origin = ele;
			configureElement(ele);
		}

		public ElementData(SchemaNode ele, ElementKind elementKind, String name) {
			this(new ElementIdentifier(name, ProcessorUtility.qualifiedName(ele).prefix), elementKind);
			this.origin = ele;
			configureElement(ele);
		}

		public SchemaNode getOrigin() {
			return origin;
		}

		public AccessKind getAccessKind() {
			return accessKind;
		}

		protected void configureElement(SchemaNode ele) {

			this.accessKind = AccessKind.rw;
			this.cardinality = Cardinality.optional;

			if (elementKind == ElementKind.Input) {
				this.accessKind = AccessKind.w;
				this.cardinality = Cardinality.mandatory;
			} else if (elementKind == ElementKind.Output) {
				this.accessKind = AccessKind.ro;
				this.cardinality = Cardinality.mandatory;
			} else if (elementKind == ElementKind.Rpc || elementKind == ElementKind.Action) {
				this.accessKind = AccessKind.x;
				this.cardinality = Cardinality.mandatory;
			} else if (elementKind == ElementKind.Notification) {
				this.accessKind = AccessKind.n;
				this.cardinality = Cardinality.mandatory;
			} else if (elementKind == ElementKind.Case) {
				this.cardinality = Cardinality.mandatory;
			} else if (elementKind == ElementKind.LeafList) {
				this.cardinality = Cardinality.many;
			} else if (elementKind == ElementKind.List) {
				this.cardinality = Cardinality.many;
			} else if (elementKind == ElementKind.Container) {
				this.cardinality = Cardinality.not_set;
			}
			ele.getSubstatements().stream().forEach((sub) -> {
				if (sub instanceof Type) {
					this.type = createValueType((Type) sub);
				} else if (sub instanceof IfFeature) {
					this.addFeatureCondition(FeatureCondition.create(((IfFeature) sub).getCondition()).toString());
				} else if (sub instanceof Config) {
					if (!"true".equals(((Config) sub).getIsConfig())) {
						this.accessKind = AccessKind.ro;
					}
				} else if (sub instanceof Mandatory) {
					this.cardinality = Cardinality.mandatory;
				} else if (sub instanceof Presence) {
					this.cardinality = Cardinality.presence;
				} else if (sub instanceof Default) {
					this.defaultValue = ((Default) sub).getDefaultStringValue();
				} else if (sub instanceof MaxElements) {
					this.maxElements = ((MaxElements) sub).getMaxElements();
				} else if (sub instanceof MinElements) {
					this.minElements = ((MinElements) sub).getMinElements();
				} else if (sub instanceof Must) {
					if (this.mustConstraint == null) {
						this.mustConstraint = new ArrayList<>();
					}
					var exprAsString = ProcessorUtility.serializedXpath(((Must) sub).getConstraint());
					this.mustConstraint.add(exprAsString);
				} else if (sub instanceof io.typefox.yang.yang.Status) {
					this.status = Status.toStatus(((io.typefox.yang.yang.Status) sub).getArgument());
				}
			});
		}

		private ValueType createValueType(Type typeStatement) {
			var typeRef = typeStatement.getTypeRef();
			if (typeRef.getBuiltin() != null) {
				if ("leafref".equals(typeRef.getBuiltin())) {
					Path pathRef = (Path) typeStatement.getSubstatements().stream().filter(s -> s instanceof Path)
							.findFirst().get();
					if (pathRef != null && pathRef.getReference() != null) {
						return new ValueType(null, "-> " + ProcessorUtility.serializedXpath(pathRef.getReference()));
					}
				}
				return new ValueType(null, typeRef.getBuiltin());
			}

			Typedef typeDef = typeRef.getType();
			// FIXME use import statement prefix
			var typeModule = ProcessorUtility.moduleIdentifier(typeDef);
			var typeRefModule = ProcessorUtility.moduleIdentifier(typeRef);
			var sameModule = Objects.equal(typeModule.name, typeRefModule.name);
			String prefix = sameModule ? null : typeModule.prefix;

			var refText = referenceText(typeRef);
			if (prefix != null && refText != null && !refText.equals(prefix + ":" + typeDef.getName())) {
				// use reference text if type
				return new ValueType(prefix, typeDef.getName(), true);
			}
			return new ValueType(prefix, typeDef.getName());
		}

		private String referenceText(TypeReference typeRef) {
			var node = NodeModelUtils.getNode(typeRef);
			if (node == null) {
				return null;
			}
			return NodeModelUtils.getTokenText(node);
		}

		private void addFeatureCondition(String condition) {
			if (condition == null) {
				throw new IllegalArgumentException("Feature condition may not be null");
			}
			if (featureConditions == null)
				featureConditions = newArrayList();
			featureConditions.add(condition);
		}

		public ValueType getType() {
			return type;
		}

		@Override
		public void addToChildren(HasStatements child) {
			super.addToChildren(child);
			if (child instanceof ElementData) {
				ElementData elementData = (ElementData) child;
				// default not set
				if (elementData.accessKind == AccessKind.rw) {
					if (accessKind == AccessKind.ro || accessKind == AccessKind.w) {
						elementData.accessKind = accessKind;
					} else if (elementKind == ElementKind.Notification) {
						elementData.accessKind = AccessKind.not_set;
					}
				}
			}
		}

		public static ElementData createNamedWrapper(ElementIdentifier elementId, ElementKind elementKind) {
			return new ElementData(elementId, elementKind);
		}

		public List<String> getFeatureConditions() {
			return featureConditions;
		}

	}

	public static class ListData extends ElementData {

		private List<String> keys;

		public ListData(io.typefox.yang.yang.List ele, ElementKind elementKind) {
			super(ele, elementKind);
			ele.getSubstatements().stream().forEach((sub) -> {
				if (sub instanceof Key) {
					((Key) sub).getReferences().forEach((keyRef) -> {
						getKeys().add(keyRef.getNode().getName());
					});
				}
			});
		}

		public List<String> getKeys() {
			if (keys == null)
				keys = newArrayList();
			return keys;
		}

		@Override
		public void addToChildren(HasStatements child) {
			super.addToChildren(child);
			if (child instanceof ElementData) {
				ElementData elementData = (ElementData) child;
				if (getKeys().contains(elementData.getSimpleName())) {
					elementData.cardinality = Cardinality.mandatory;
				}
			}
		}
	}

	public static class MessageEntry {
		boolean loadingError;
		String moduleFile;
		int line, col = -1;
		Severity severity;
		String message;

		@Override
		public String toString() {
			return moduleFile + ":" + line + ":" + (col < 0 ? "" : col) + " " + severity + ": " + message;
		}
	}

	public static enum Severity {
		Error, Warning
	}

}
