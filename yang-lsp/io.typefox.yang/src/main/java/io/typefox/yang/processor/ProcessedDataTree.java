package io.typefox.yang.processor;

import static com.google.common.collect.Lists.newArrayList;

import java.util.List;
import java.util.Set;

import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;

import com.google.common.base.Objects;
import com.google.common.collect.Sets;

import io.typefox.yang.processor.FeatureExpressions.FeatureCondition;
import io.typefox.yang.yang.AbstractModule;
import io.typefox.yang.yang.Config;
import io.typefox.yang.yang.IfFeature;
import io.typefox.yang.yang.Key;
import io.typefox.yang.yang.Mandatory;
import io.typefox.yang.yang.Path;
import io.typefox.yang.yang.Presence;
import io.typefox.yang.yang.SchemaNode;
import io.typefox.yang.yang.Type;
import io.typefox.yang.yang.Typedef;
import io.typefox.yang.yang.XpathExpression;

public class ProcessedDataTree {

	private List<ModuleData> modules;

	public void addModule(ModuleData moduleData) {
		if (modules == null)
			modules = newArrayList();
		modules.add(moduleData);
	}

	public List<ModuleData> getModules() {
		return modules;
	}

	public static class HasStatements {
		private List<HasStatements> children;

		public void addToChildren(HasStatements child) {
			if (children == null)
				children = newArrayList();
			children.add(child);
		}

		public List<HasStatements> getChildren() {
			return children;
		}
	}

	public static class Named extends HasStatements {
		protected String name;

		public String getName() {
			return name;
		}
	}

	public static class ModuleData extends Named {
		private List<HasStatements> rpcs;

		public ModuleData(AbstractModule ele) {
			this.name = ele.getName();
		}

		public void addToRpcs(ElementData rpc) {
			if (rpcs == null)
				rpcs = newArrayList();
			rpcs.add(rpc);
		}

		public List<HasStatements> getRpcs() {
			return rpcs;
		}
	}

	static public class ValueType {
		final String prefix, name;

		public ValueType(String prefix, String name) {
			super();
			this.prefix = prefix;
			this.name = name;
		}

		@Override
		public String toString() {
			return prefix != null ? (prefix + ":" + name) : name;
		}
	}

	static public enum ElementKind {
		Container, Leaf, LeafList, List, Rpc, Choice, Case, Action, Grouping, Refine, Uses, Input, Output, Notification,
		AnyXml;

		public static Set<ElementKind> mayOmitCase = Sets.newHashSet(AnyXml, Container, Leaf, List, LeafList);
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

	public static class ElementData extends Named {

		transient private ElementData parent;

		final ElementKind elementKind;
		ValueType type;
		private List<String> featureConditions;
		AccessKind accessKind;
		Cardinality cardinality;


		private ElementData(String name, ElementKind elementKind) {
			this.name = name;
			this.elementKind = elementKind;
		}

		public ElementData(SchemaNode ele, ElementKind elementKind) {
			this(ProcessorUtility.qualifiedName(ele), elementKind);
			configureElement(ele);
		}

		protected void configureElement(SchemaNode ele) {
			if (elementKind == ElementKind.Input) {
				this.name = "input";
				this.accessKind = AccessKind.w;
			} else if (elementKind == ElementKind.Rpc) {
				this.accessKind = AccessKind.x;
			} else if (elementKind == ElementKind.Notification) {
				this.accessKind = AccessKind.n;
			} else if (elementKind == ElementKind.Case) {
				this.cardinality = Cardinality.mandatory;
			} else if (elementKind == ElementKind.LeafList) {
				this.cardinality = Cardinality.many;
			} else if (elementKind == ElementKind.List) {
				this.cardinality = Cardinality.many;
			} else if (elementKind == ElementKind.Container) {
				this.cardinality = Cardinality.not_set;
			} else {
				this.cardinality = Cardinality.optional;
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
						return new ValueType(null, "-> " + serializedXpath(pathRef.getReference()));
					}
				}
				return new ValueType(null, typeRef.getBuiltin());
			}

			Typedef typedef = typeRef.getType();
			// FIXME use import statement prefix
			var typeModule = ProcessorUtility.moduleIdentifier(typedef);
			String prefix = Objects.equal(typeModule.name, ProcessorUtility.moduleIdentifier(typeRef).name) ? null
					: typeModule.prefix;
			return new ValueType(prefix, typedef.getName());
		}

		private String serializedXpath(XpathExpression reference) {
			// TODO use serializer or implement a an own simple one
			ICompositeNode nodeFor = NodeModelUtils.findActualNodeFor(reference);
			if (nodeFor != null) {
				var nodeText = nodeFor.getText();
				nodeText = nodeText.replaceAll("\"|'|\s|\n|\r", "").replaceAll("\\+", "");
				return nodeText;
			}
			return "leafref";
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

		public AccessKind getAccessKind() {
			if (accessKind != null)
				return accessKind;
			else if (parent != null)
				return parent.getAccessKind();
			else
				return AccessKind.not_set;
		}

		@Override
		public void addToChildren(HasStatements child) {
			super.addToChildren(child);
			if (child instanceof ElementData)
				((ElementData) child).parent = this;
		}

		public static ElementData createNamedWrapper(String name, ElementKind elementKind) {
			return new ElementData(name, elementKind);
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
				if (getKeys().contains(elementData.getName())) {
					elementData.cardinality = Cardinality.mandatory;
				}
			}
		}
	}

}
