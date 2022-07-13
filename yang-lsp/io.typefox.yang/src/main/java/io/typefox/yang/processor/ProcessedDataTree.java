package io.typefox.yang.processor;

import static com.google.common.collect.Lists.newArrayList;

import java.util.List;

import com.google.common.base.Objects;

import io.typefox.yang.yang.AbstractModule;
import io.typefox.yang.yang.Config;
import io.typefox.yang.yang.Expression;
import io.typefox.yang.yang.FeatureReference;
import io.typefox.yang.yang.IfFeature;
import io.typefox.yang.yang.Key;
import io.typefox.yang.yang.Mandatory;
import io.typefox.yang.yang.Presence;
import io.typefox.yang.yang.SchemaNode;
import io.typefox.yang.yang.Type;
import io.typefox.yang.yang.Typedef;

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
		Container, Leaf, LeafList, List, Rpc, Choice, Case, Action, Grouping, Refine, Uses, Input, Output, Notification
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

		ElementKind elementKind = ElementKind.Leaf;
		ValueType type;
		List<String> featureConditions;
		AccessKind accessKind;
		Cardinality cardinality;

		public ElementData(SchemaNode ele, ElementKind elementKind) {
			this.name = ProcessorUtility.qualifiedName(ele);
			this.elementKind = elementKind;
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
					var typeRef = ((Type) sub).getTypeRef();
					if (typeRef.getBuiltin() != null) {
						this.type = new ValueType(null, typeRef.getBuiltin());
					} else {
						Typedef typedef = typeRef.getType();
						String typePrefix = ProcessorUtility.getPrefix(typedef);
						String prefix = Objects.equal(typePrefix, ProcessorUtility.getPrefix(ele)) ? null : typePrefix;
						this.type = new ValueType(prefix, typedef.getName());
					}
				} else if (sub instanceof IfFeature) {
					this.addFeatureCondition(createFeatureCondition(((IfFeature) sub).getCondition()));
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

		private void addFeatureCondition(String condition) {
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

	public static String createFeatureCondition(Expression condition) {
		if (condition instanceof FeatureReference) {
			return ((FeatureReference) condition).getFeature().getName();
		}
		return null;
	}

}
