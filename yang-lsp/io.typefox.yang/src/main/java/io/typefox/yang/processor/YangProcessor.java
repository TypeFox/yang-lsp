package io.typefox.yang.processor;

import static com.google.common.collect.Lists.newArrayList;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.common.notify.impl.AdapterImpl;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider;

import com.google.common.base.Objects;
import com.google.common.collect.Lists;

import io.typefox.yang.processor.ProcessedDataModel.ElementData;
import io.typefox.yang.processor.ProcessedDataModel.ElementIdentifier;
import io.typefox.yang.processor.ProcessedDataModel.ElementKind;
import io.typefox.yang.processor.ProcessedDataModel.HasStatements;
import io.typefox.yang.processor.ProcessedDataModel.ListData;
import io.typefox.yang.processor.ProcessedDataModel.ModuleData;
import io.typefox.yang.processor.ProcessorUtility.CopiedObjectAdapter;
import io.typefox.yang.utils.YangNameUtils;
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
import io.typefox.yang.yang.Rpc;
import io.typefox.yang.yang.SchemaNode;
import io.typefox.yang.yang.Statement;
import io.typefox.yang.yang.Uses;
import io.typefox.yang.yang.YangPackage;

public class YangProcessor {

	public static enum Format {
		tree, json
	}

	/**
	 * 
	 * @param modules          loaded modules
	 * @param includedFeatures features to include
	 * @param excludedFeatures features to exclude
	 * @return ProcessedDataTree or <code>null</code> if modules is
	 *         <code>null</code> or empty.
	 */
	public ProcessedDataModel process(List<AbstractModule> modules, List<String> includedFeatures,
			List<String> excludedFeatures) {
		if (modules == null || modules.isEmpty()) {
			return null;
		}
		return processInternal(modules, includedFeatures == null ? newArrayList() : includedFeatures,
				excludedFeatures == null ? newArrayList() : excludedFeatures);
	}

	/**
	 * @param moduleData data to serialize
	 * @param format     tree or json. tree is default
	 * @param output     target
	 */
	public void serialize(ModuleData moduleData, Format format, StringBuilder output) {
		switch (format) {
		case json: {
			new JsonSerializer().serialize(moduleData, output);
			break;
		}
		case tree: {
			output.append(new DataTreeSerializer().serialize(moduleData));
			break;
		}
		}
	}

	protected ProcessedDataModel processInternal(List<AbstractModule> modules, List<String> includedFeatures,
			List<String> excludedFeatures) {
		var evalCtx = new FeatureEvaluationContext(includedFeatures, excludedFeatures);
		ProcessedDataModel processedModel = new ProcessedDataModel();
		collectResourceErrors(modules.get(0), processedModel);

		modules.forEach((module) -> expandUses(module, evalCtx));

		List<Deviate> deviations = new ArrayList<>();
		List<Augment> augments = new ArrayList<>();
		modules.forEach((module) -> module.eAllContents().forEachRemaining((ele) -> {
			if (ele instanceof Deviate) {
				deviations.add((Deviate) ele);
			} else if (ele instanceof Augment) {
				// don't process augments that are parts of grouping or uses statement.
				// Also ignore augments inside action outputs, as it not clear how to deal with that
				if (EcoreUtil2.getContainerOfType(ele, Uses.class) == null
						&& EcoreUtil2.getContainerOfType(ele, Grouping.class) == null) {
					augments.add((Augment) ele);
				}
			}
		}));

		augments.forEach(augm -> processAugment(augm, evalCtx));
		deviations.forEach(dev -> processDeviate(dev, processedModel));

		modules.forEach((module) -> {
			String prefix = null;
			List<Prefix> prefixStatements = ProcessorUtility.findSubstatement(module, Prefix.class);
			if (!prefixStatements.isEmpty())
				prefix = prefixStatements.get(0).getPrefix();
			var moduleData = new ModuleData(new ElementIdentifier(module.getName(), prefix));
			moduleData.setURI(module.eResource().getURI().toString());
			processedModel.addModule(moduleData);
			processChildren(module, moduleData, evalCtx);
		});
		return processedModel;
	}

	private void expandUses(AbstractModule module, FeatureEvaluationContext evalCtx) {
		module.eContents().forEach((ele) -> {
			expandUses(ele, evalCtx);
		});
	}

	private void expandUses(EObject eObj, FeatureEvaluationContext evalCtx) {
		if (eObj.eClass() == YangPackage.Literals.USES) {
			if (EcoreUtil2.getContainerOfType(eObj, Grouping.class) != null) {
				// ignore uses inside a grouping as it will be processed, when the group is used
			} else {
				expandUses((Uses) eObj, evalCtx);
			}
		} else {
			eObj.eContents().forEach(e -> expandUses(e, evalCtx));
		}
	}

	private void expandUses(Uses uses, FeatureEvaluationContext evalCtx) {
		if (!ProcessorUtility.isEnabled(uses, evalCtx)) {
			return;
		}
		GroupingRef groupingRef = uses.getGrouping();
		Grouping grouping = groupingRef.getNode();
		ForeignModuleAdapter adapted = ForeignModuleAdapter.find(uses);
		if (adapted != null) {
			ForeignModuleAdapter moduleAdapter = new ForeignModuleAdapter(adapted.moduleId);
			// used groupings are bound to the namespace of the current module
			grouping.eAdapters().add(moduleAdapter);
		}
		List<Statement> nodesToAdd = newArrayList();
		// grouping nodes
		nodesToAdd.addAll(ProcessorUtility.copyAllEObjects(grouping.getSubstatements().stream()
				.filter(ele -> ProcessorUtility.isEnabled(ele, evalCtx)).collect(Collectors.toList())));
		// uses nodes
		nodesToAdd.addAll(ProcessorUtility.copyAllEObjects(uses.getSubstatements().stream()
				.filter(ele -> ProcessorUtility.isEnabled(ele, evalCtx)).collect(Collectors.toList())));
		if (uses.eContainer() instanceof Statement) {
			Statement parent = (Statement) uses.eContainer();
			parent.getSubstatements().addAll(parent.getSubstatements().indexOf(uses), nodesToAdd);
			nodesToAdd.forEach(eObj -> expandUses(eObj, evalCtx));
		}
	}

	private void collectResourceErrors(AbstractModule entryModule, ProcessedDataModel processedModel) {
		var moduleFile = moduleFileName(entryModule);
		entryModule.eResource().getErrors().forEach(diagnostic -> {
			processedModel.addError(moduleFile, diagnostic.getLine(), diagnostic.getColumn(), diagnostic.getMessage(),
					false);
		});
	}

	/*
	 * The deviates's Substatements: config, default, mandatory, max-elements,
	 * min-elements, must, type, unique, units. Properties 'must' and 'unique' are
	 * 0..n
	 */
	protected void processDeviate(Deviate deviate, ProcessedDataModel processedModel) {
		var moduleFileName = moduleFileName(deviate);
		var deviation = (Deviation) deviate.eContainer();
		SchemaNode targetNode = deviation.getReference().getSchemaNode();

		if (targetNode == null || targetNode.eIsProxy()) {
			processedModel.addProcessorError(moduleFileName, deviation.getReference(),
					"Deviation target node not found");
			return;
		}
		final String argument = deviate.getArgument();
		switch (argument) {
		case "add": {
			for (Statement statement : deviate.getSubstatements()) {
				boolean error = false;
				if (statement.eClass() != YangPackage.Literals.MUST && statement.eClass() != YangPackage.Literals.UNIQUE
						&& statement.eClass() != YangPackage.Literals.UNKNOWN) {
					var existingProperty = targetNode.getSubstatements().stream()
							.filter(child -> child.eClass() == statement.eClass()).findFirst();
					if (existingProperty.isPresent()) {
						error = true;
						processedModel.addProcessorError(moduleFileName, statement,
								"the \"" + YangNameUtils.getYangName(statement)
										+ "\" property already exists in node \"" + nodeQName(targetNode) + "\"");
					}
				}
				if (!error) {
					var copy = ProcessorUtility.copyEObject(statement);
					targetNode.getSubstatements().add(copy);
				}
			}
			break;
		}
		case "delete":
			for (Statement statement : deviate.getSubstatements()) {
				var existingProperty = targetNode.getSubstatements().stream()
						.filter(child -> matchingArguments(child, statement)).findFirst();
				if (existingProperty.isPresent()) {
					targetNode.getSubstatements().remove(existingProperty.get());
				} else {
					processedModel.addProcessorError(moduleFileName, statement,
							"the \"" + YangNameUtils.getYangName(statement) + "\" property does not exist in node \""
									+ nodeQName(targetNode) + "\"");
				}
			}
			break;
		case "replace":
			for (Statement statement : deviate.getSubstatements()) {
				var existingProperty = targetNode.getSubstatements().stream()
						.filter(child -> child.eClass() == statement.eClass()).findFirst();
				if (existingProperty.isPresent()) {
					targetNode.getSubstatements().remove(existingProperty.get());
					var copy = ProcessorUtility.copyEObject(statement);
					targetNode.getSubstatements().add(copy);
				} else {
					if (statement.eClass() == YangPackage.Literals.CONFIG) {
						// config could be inherited from parent or be default = true
						targetNode.getSubstatements().add(ProcessorUtility.copyEObject(statement));
					} else {
						processedModel.addProcessorError(moduleFileName, statement,
								"the \"" + YangNameUtils.getYangName(statement)
										+ "\" property does not exist in node \"" + nodeQName(targetNode) + "\"");
					}
				}
			}
			break;
		case "not-supported":
			if (targetNode.eContainer() == null) {
				if (!Objects.equal("not-supported", DeviationAdapter.find(targetNode))) {
					processedModel.addProcessorError(moduleFileName, deviation.getReference(),
							"Deviation target node has no parent.");
				}
				break;
			}
			removeFromContainer(targetNode);
			DeviationAdapter.add(targetNode, argument);
			break;
		}
	}

	private void removeFromContainer(EObject objToRemove) {
		if (objToRemove.eContainer() != null) {
			Object eGet = objToRemove.eContainer().eGet(objToRemove.eContainingFeature(), true);
			if (eGet instanceof EList && EcoreUtil2.getContainerOfType(objToRemove, Uses.class) == null) {
				((EList<?>) eGet).remove(objToRemove);
			}
			
		}
		Iterator<CopiedObjectAdapter> iterator = CopiedObjectAdapter.findAll(objToRemove).iterator();
		if (iterator.hasNext()) {
			iterator.forEachRemaining(adapter -> removeFromContainer(adapter.getCopy()));
		}
	}

	protected String moduleFileName(EObject eObj) {
		return eObj.eResource().getURI().lastSegment();
	}

	protected String nodeQName(SchemaNode node) {
		// TODO use injected version
		var qName = new DefaultDeclarativeQualifiedNameProvider().getFullyQualifiedName(node);
		return String.join(":", qName.getSegments());
	}

	/**
	 * The properties to delete are identified by substatements to the "delete"
	 * statement. The substatement's keyword MUST match a corresponding keyword in
	 * the target node, and the argument's string MUST be equal to the corresponding
	 * keyword's argument string in the target node.
	 * 
	 * @param candidate
	 * @param objToMatch
	 * @return true if candidate matches the objToMatch
	 */
	protected boolean matchingArguments(Statement candidate, Statement objToMatch) {
		if (candidate.eClass() != objToMatch.eClass()) {
			return false;
		}
		for (EStructuralFeature feat : objToMatch.eClass().getEStructuralFeatures()) {
			var toMatch = objToMatch.eGet(feat, true);
			var candidateState = candidate.eGet(feat, true);
			if (feat instanceof EReference && toMatch instanceof EObject && candidateState instanceof EObject) {
				if (!EcoreUtil.equals((EObject) toMatch, (EObject) candidateState)) {
					return false;
				}
			} else {
				if (!Objects.equal(toMatch, candidateState)) {
					return false;
				}
			}
		}
		return true;
	}

	protected void processAugment(Augment augment, FeatureEvaluationContext evalCtx) {
		List<IfFeature> ifFeatures = ProcessorUtility.findIfFeatures(augment);
		boolean featuresMatch = ProcessorUtility.checkIfFeatures(ifFeatures, evalCtx);
		// disabled by feature
		if (!featuresMatch) {
			return;
		}

		SchemaNode schemaNode = augment.getPath().getSchemaNode();
		for (Statement st : augment.getSubstatements()) {
			if(st.eClass() == YangPackage.Literals.CONTAINER) {
				if(((Container)st).getName().equals("encrypted-private-key1")) {
					
					System.out.println("YangProcessor.processAugment()" + schemaNode.getName());
					if(EcoreUtil2.getContainerOfType(augment, Augment.class) == null) {
						return;
					}
				}
			}
		}
		Set<SchemaNode> targetNodeAndCopies = collectCopies(schemaNode, new LinkedHashSet<>());

		if (targetNodeAndCopies.size() > 0) {
			processAugments(targetNodeAndCopies, augment);
		} else {
			processAugments(newArrayList(schemaNode), augment);
		}
	}

	protected Set<SchemaNode> collectCopies(SchemaNode schemaNode, Set<SchemaNode> collector) {
		CopiedObjectAdapter.findAll(schemaNode).map(a -> ((SchemaNode) a.getCopy())).forEach(copy -> {
			collector.add(copy);
			collectCopies(copy, collector);
		});

		return collector;
	}

	protected void processAugments(Collection<SchemaNode> targets, Augment source) {
		var globalModuleId = ProcessorUtility.moduleIdentifier(source);
		List<IfFeature> ifFeatures = ProcessorUtility.findIfFeatures(source);
		targets.forEach((schemaNode) -> {
			source.getSubstatements().stream().filter(sub -> !(sub instanceof IfFeature)).forEach((subStatement) -> {
				// TODO check what can be added
				if (subStatement instanceof SchemaNode) {
					SchemaNode copy = ProcessorUtility.copyEObject((SchemaNode) subStatement);
					// add augment's feature conditions to copied augment children
					copy.getSubstatements().addAll(ProcessorUtility.copyAllEObjects(ifFeatures));

					// memorize source module information as adapter
					copy.eAdapters().add(new ForeignModuleAdapter(globalModuleId));

					// Remove same named existing node
					var existing = schemaNode.getSubstatements().stream().filter((statement) -> {
						if (statement instanceof SchemaNode) {
							return copy.getName().equals(((SchemaNode) statement).getName());
						}
						return false;
					}).findFirst();
					if (existing.isPresent()) {
						schemaNode.getSubstatements().remove(existing.get());
					}
					schemaNode.getSubstatements().add(copy);
				}
			});
		});
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
				// Don't add grouping definitions to the output
				// child = new ElementData((SchemaNode) ele, ElementKind.Grouping);
			} else if (ele instanceof Uses) {
				// handled earlier in expandUses

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

	public static class DeviationAdapter extends AdapterImpl {
		final String argument;

		public DeviationAdapter(String argument) {
			this.argument = argument;
		}

		public static String find(EObject eObject) {
			for (Adapter adapter : eObject.eAdapters()) {
				if (adapter instanceof DeviationAdapter) {
					return ((DeviationAdapter) adapter).argument;
				}
			}
			return null;
		}

		public static void add(EObject eObject, String argument) {
			eObject.eAdapters().add(new DeviationAdapter(argument));
		}

		public String toString() {
			return "Deviated with: " + argument;
		}
	}
}
