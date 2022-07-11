package io.typefox.yang.processor;

import static com.google.common.collect.Lists.newArrayList;

import java.util.List;

import io.typefox.yang.yang.AbstractModule;
import io.typefox.yang.yang.Container;
import io.typefox.yang.yang.DataSchemaNode;
import io.typefox.yang.yang.Leaf;
import io.typefox.yang.yang.Rpc;
import io.typefox.yang.yang.SchemaNode;
import io.typefox.yang.yang.Statement;

public class ProcessedDataTree {

	List<ModuleData> modules;

	public void addModule(AbstractModule module) {
		if (modules == null)
			modules = newArrayList();
		modules.add(new ModuleData(module));
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
	}

	public static class Named extends HasStatements {
		String name;

		public String getName() {
			return name;
		}
	}

	public static class ModuleData extends Named {
		private List<HasStatements> rpcs;

		public ModuleData(AbstractModule yangModule) {
			this.name = yangModule.getName();
			processChildren(yangModule, this);
		}

		public void addToRpcs(LeafData rpc) {
			if (rpcs == null)
				rpcs = newArrayList();
			rpcs.add(rpc);
		}
	}

	public static class ContainerData extends Named {
		public ContainerData(Container ele) {
			this.name = ele.getName();
			processChildren(ele, this);
		}
	}

	public static class LeafData extends Named {
		public LeafData(SchemaNode ele) {
			this.name = ele.getName();
			processChildren(ele, this);
		}
	}

	private static void processChildren(Statement statement, HasStatements parent) {
		statement.getSubstatements().stream().forEach(ele -> {
			if (ele instanceof Container) {
				parent.addToChildren(new ContainerData((Container) ele));
			} else if (ele instanceof Leaf) {
				parent.addToChildren(new LeafData((Leaf) ele));
			} else if (ele instanceof List) {
				parent.addToChildren(new LeafData((DataSchemaNode) ele));
			} else if (ele instanceof Rpc) {
				((ModuleData) parent).addToRpcs(new LeafData((Rpc) ele));
			}
		});
	}
}
