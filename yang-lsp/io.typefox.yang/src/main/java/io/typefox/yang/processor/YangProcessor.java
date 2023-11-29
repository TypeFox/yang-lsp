package io.typefox.yang.processor;

import static com.google.common.collect.Lists.newArrayList;

import java.util.List;

import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.common.notify.impl.AdapterImpl;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;

import com.google.common.collect.Lists;
import com.google.gson.GsonBuilder;

import io.typefox.yang.processor.ProcessedDataTree.ElementData;
import io.typefox.yang.processor.ProcessedDataTree.ElementIdentifier;
import io.typefox.yang.processor.ProcessedDataTree.ElementKind;
import io.typefox.yang.processor.ProcessedDataTree.HasStatements;
import io.typefox.yang.processor.ProcessedDataTree.ListData;
import io.typefox.yang.processor.ProcessedDataTree.ModuleData;
import io.typefox.yang.yang.AbstractModule;
import io.typefox.yang.yang.Action;
import io.typefox.yang.yang.Augment;
import io.typefox.yang.yang.Case;
import io.typefox.yang.yang.Choice;
import io.typefox.yang.yang.Container;
import io.typefox.yang.yang.DataSchemaNode;
import io.typefox.yang.yang.Deviate;
import io.typefox.yang.yang.Deviation;
import io.typefox.yang.yang.Grouping;
import io.typefox.yang.yang.GroupingRef;
import io.typefox.yang.yang.IfFeature;
import io.typefox.yang.yang.Input;
import io.typefox.yang.yang.Leaf;
import io.typefox.yang.yang.LeafList;
import io.typefox.yang.yang.Notification;
import io.typefox.yang.yang.Output;
import io.typefox.yang.yang.Prefix;
import io.typefox.yang.yang.Refine;
import io.typefox.yang.yang.Rpc;
import io.typefox.yang.yang.SchemaNode;
import io.typefox.yang.yang.Statement;
import io.typefox.yang.yang.Uses;

public class YangProcessor {

	/**
	 * 
	 * @param modules          loaded modules
	 * @param includedFeatures features to include
	 * @param excludedFeatures features to exclude
	 * @return ProcessedDataTree or <code>null</code> if modules is
	 *         <code>null</code> or empty.
	 */
	public ProcessedDataTree process(List<AbstractModule> modules, List<String> includedFeatures,
			List<String> excludedFeatures) {
		if (modules == null || modules.isEmpty()) {
			return null;
		}
		return processInternal(modules, includedFeatures == null ? newArrayList() : includedFeatures,
				excludedFeatures == null ? newArrayList() : excludedFeatures);
	}

	/**
	 * @param processedData data to serialize
	 * @param format        tree or json. tree is default
	 * @param output        target
	 */
	public void serialize(ProcessedDataTree processedData, String format, StringBuilder output) {

		if ("json".equals(format)) {
			new GsonBuilder().setPrettyPrinting().create().toJson(processedData, output);
		} else {
			// pick module by file name
			output.append(new DataTreeSerializer().serialize(processedData.getModules().get(0)));
		}
	}

	protected ProcessedDataTree processInternal(List<AbstractModule> modules, List<String> includedFeatures,
			List<String> excludedFeatures) {
		var evalCtx = new FeatureEvaluationContext(includedFeatures, excludedFeatures);
		ProcessedDataTree processedDataTree = new ProcessedDataTree();
		modules.forEach((module) -> module.eAllContents().forEachRemaining((ele) -> {
			if (ele instanceof Deviate) {
				/*
				 * var deviation = ((Deviation) ele); deviation.getSubstatements().forEach((sub)
				 * -> { });
				 */
				Deviate deviate = (Deviate) ele;
				switch (deviate.getArgument()) {
				case "add":
				case "replace":
					break;
				case "delete":
				case "not-supported":
					var deviation = ((Deviation) ele.eContainer());
					SchemaNode schemaNode = deviation.getReference().getSchemaNode();
					Object eGet = schemaNode.eContainer().eGet(schemaNode.eContainingFeature(), true);
					if (eGet instanceof EList) {
						((EList<?>) eGet).remove(schemaNode);
					}
					break;
				}
			} else if (ele instanceof Augment) {
				var augment = (Augment) ele;
				List<IfFeature> ifFeatures = ProcessorUtility.findIfFeatures(augment);
				boolean featuresMatch = ProcessorUtility.checkIfFeatures(ifFeatures, evalCtx);
				// disabled by feature
				if (!featuresMatch) {
					return;
				}
				var globalModuleId = ProcessorUtility.moduleIdentifier(module);

				augment.getSubstatements().stream().filter(sub -> !(sub instanceof IfFeature))
						.forEach((subStatement) -> {
							// TODO check what can be added
							if (subStatement instanceof SchemaNode) {
								SchemaNode copy = ProcessorUtility.copyEObject((SchemaNode) subStatement);
								// add augment's feature conditions to copied augment children
								copy.getSubstatements().addAll(ProcessorUtility.copyAllEObjects(ifFeatures));

								// memorize source module information as adapter
								copy.eAdapters().add(new ForeignModuleAdapter(globalModuleId));

								// Remove same named existing node
								var existing = augment.getPath().getSchemaNode().getSubstatements().stream()
										.filter((statement) -> {
											if (statement instanceof SchemaNode) {
												return copy.getName().equals(((SchemaNode) statement).getName());
											}
											return false;
										}).findFirst();
								if (existing.isPresent()) {
									augment.getPath().getSchemaNode().getSubstatements().remove(existing.get());
								}
								augment.getPath().getSchemaNode().getSubstatements().add(copy);
							}
						});
			}
		}));

		modules.forEach((module) -> {
			String prefix = null;
			List<Prefix> prefixStatements = ProcessorUtility.findSubstatement(module, Prefix.class);
			if (!prefixStatements.isEmpty())
				prefix = prefixStatements.get(0).getPrefix();
			var moduleData = new ModuleData(new ElementIdentifier(module.getName(), prefix));
			processedDataTree.addModule(moduleData);
			processChildren(module, moduleData, evalCtx);
		});
		return processedDataTree;
	}

	protected void processChildren(Statement statement, HasStatements parent, FeatureEvaluationContext evalCtx) {
		statement.getSubstatements().stream().filter(ele -> ProcessorUtility.isEnabled(ele, evalCtx)).forEach((ele) -> {
			ElementData child = null;
			if (ele instanceof Container) {
				child = new ElementData((Container) ele, ElementKind.Container);
			} else if (ele instanceof Leaf) {
				child = new ElementData((DataSchemaNode) ele, ElementKind.Leaf);
			} else if (ele instanceof LeafList) {
				child = new ElementData((DataSchemaNode) ele, ElementKind.LeafList);
			} else if (ele instanceof io.typefox.yang.yang.List) {
				child = new ListData((io.typefox.yang.yang.List) ele, ElementKind.List);
			} else if (ele instanceof Choice) {
				child = new ElementData((SchemaNode) ele, ElementKind.Choice);
			} else if (ele instanceof Case) {
				child = new ElementData((SchemaNode) ele, ElementKind.Case);
			} else if (ele instanceof Action) {
				child = new ElementData((SchemaNode) ele, ElementKind.Action);
			} else if (ele instanceof Grouping) {
				child = new ElementData((SchemaNode) ele, ElementKind.Grouping);
			} else if (ele instanceof Uses) {
				/*
				 * The effect of a "uses" reference to a grouping is that the nodes defined by
				 * the grouping are copied into the current schema tree and are then updated
				 * according to the "refine" and "augment" statements.
				 */
				GroupingRef groupingRef = ((Uses) ele).getGrouping();
				Grouping grouping = groupingRef.getNode();
				ForeignModuleAdapter adapted = ForeignModuleAdapter.find(ele);
				if (adapted != null) {
					ForeignModuleAdapter moduleAdapter = new ForeignModuleAdapter(adapted.moduleId);
					// used groupings are bound to the namespace of the current module
					grouping.eAdapters().add(moduleAdapter);
				}
				processChildren(grouping, parent, evalCtx);

			} else if (ele instanceof Refine) {
				child = new ElementData((SchemaNode) ele, ElementKind.Refine);
			} else if (ele instanceof Input) {
				child = new ElementData((SchemaNode) ele, ElementKind.Input, "input");
			} else if (ele instanceof Output) {
				child = new ElementData((SchemaNode) ele, ElementKind.Output, "output");
			} else if (ele instanceof Notification) {
				child = new ElementData((SchemaNode) ele, ElementKind.Notification);
			} else if (ele instanceof Rpc) {
				var rpc = new ElementData((Rpc) ele, ElementKind.Rpc);
				((ModuleData) parent).addToRpcs(rpc);
				processChildren(ele, rpc, evalCtx);
			}
			if (child != null) {
				// Wrap choice's direct non-case children into case Element
				// See https://www.rfc-editor.org/rfc/rfc6020#section-7.9.2
				if (parent instanceof ElementData && ((ElementData) parent).elementKind == ElementKind.Choice
						&& ElementKind.mayOmitCase.contains(child.elementKind)) {
					var caseWraper = ElementData.createNamedWrapper(child.getName(), ElementKind.Case);
					caseWraper.addToChildren(child);
					child = caseWraper;
				}
				parent.addToChildren(child);
				processChildren(ele, child, evalCtx);
			}
		});
	}

//	private ModuleData parentModule(HasStatements element) {
//		if (element instanceof ModuleData) {
//			return (ModuleData) element;
//		} else if (element.getParent() != null) {
//			return parentModule(element.getParent());
//		}
//		return null;
//	}

	public static class ForeignModuleAdapter extends AdapterImpl {
		final ElementIdentifier moduleId;

		public ForeignModuleAdapter(ElementIdentifier moduleId) {
			this.moduleId = moduleId;
		}

		public static ForeignModuleAdapter find(EObject eObject) {
			ForeignModuleAdapter containerAdapter = null;
			if (eObject.eContainer() != null) {
				containerAdapter = find(eObject.eContainer());
			}
			// Container adapter has precedence because of 'uses' statement
			if (containerAdapter != null) {
				return containerAdapter;
			}
			// Take last added adapter
			for (Adapter adapter : Lists.reverse(eObject.eAdapters())) {
				if (adapter instanceof ForeignModuleAdapter) {
					return (ForeignModuleAdapter) adapter;
				}
			}
			return null;
		}

		public String toString() {
			return moduleId.toString();
		}
	}
}
