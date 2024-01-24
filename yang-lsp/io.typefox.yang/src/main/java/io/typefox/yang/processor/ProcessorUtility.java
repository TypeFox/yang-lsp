package io.typefox.yang.processor;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.common.notify.impl.AdapterImpl;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EcoreUtil.Copier;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.impl.CompositeNodeWithSemanticElement;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;

import io.typefox.yang.processor.FeatureExpressions.FeatureCondition;
import io.typefox.yang.processor.ProcessedDataModel.ElementIdentifier;
import io.typefox.yang.processor.YangProcessor.ForeignModuleAdapter;
import io.typefox.yang.utils.YangExtensions;
import io.typefox.yang.yang.AbstractModule;
import io.typefox.yang.yang.Augment;
import io.typefox.yang.yang.IfFeature;
import io.typefox.yang.yang.OtherStatement;
import io.typefox.yang.yang.Prefix;
import io.typefox.yang.yang.SchemaNode;
import io.typefox.yang.yang.Statement;
import io.typefox.yang.yang.Submodule;
import io.typefox.yang.yang.XpathExpression;

public class ProcessorUtility {

	public static String getPrefix(OtherStatement statment) {
		return new YangExtensions().getPrefix(statment);
	}

	public static String getPrefix(Submodule statment) {
		return new YangExtensions().getPrefix(statment);
	}

	public static String getPrefix(SchemaNode node) {
		var module = EcoreUtil2.getContainerOfType(node, AbstractModule.class);
		return getPrefix(module);
	}

	public static ElementIdentifier moduleIdentifier(EObject eObj) {
		ForeignModuleAdapter foreignAdapter = ForeignModuleAdapter.find(eObj);
		if (foreignAdapter != null) {
			return foreignAdapter.moduleId;
		}
		var module = new YangExtensions().getMainModule(eObj);
		if (module == null) {
			return ElementIdentifier.UNRESOLVED;
		}
		Prefix prefix = (Prefix) module.getSubstatements().stream().filter(s -> (s instanceof Prefix)).findFirst()
				.get();
		return new ElementIdentifier(module.getName(), prefix != null ? prefix.getPrefix() : null);
	}

	public static List<IfFeature> findIfFeatures(Statement statement) {
		return statement.getSubstatements().stream().filter(sub -> sub instanceof IfFeature).map(IfFeature.class::cast)
				.collect(Collectors.toList());
	}

	public static <T> List<T> findSubstatement(Statement statement, Class<T> type) {
		return statement.getSubstatements().stream().filter(type::isInstance).map(type::cast)
				.collect(Collectors.toList());
	}

	public static boolean isEnabled(Statement statement, FeatureEvaluationContext evalCtx) {
		return checkIfFeatures(findIfFeatures(statement), evalCtx);
	}

	public static boolean checkIfFeatures(List<IfFeature> ifFeatures, FeatureEvaluationContext evalCtx) {
		if (ifFeatures.isEmpty()) {
			return true;
		}
		return ifFeatures.stream().allMatch(feature -> {
			FeatureCondition condition = FeatureCondition.create(feature.getCondition());
			return condition.evaluate(evalCtx);
		});
	}

	public static ElementIdentifier qualifiedName(SchemaNode node) {
		ForeignModuleAdapter foreignAdapter = ForeignModuleAdapter.find(node);
		String prefix = null;
		if (foreignAdapter != null) {
			prefix = foreignAdapter.moduleId.prefix;
		}
		return new ElementIdentifier(node.getName(), prefix);
	}

	public static <T extends EObject> T copyEObject(T eObj) {
		return copyAllEObjects(Arrays.asList(eObj)).iterator().next();
	}

	public static <T> Collection<T> copyAllEObjects(Collection<? extends T> eObjects) {
		Copier copier = new Copier() {
			private static final long serialVersionUID = 4555795110183792853L;

			@Override
			protected EObject createCopy(EObject eObject) {
				EObject createCopy = super.createCopy(eObject);
				var node = NodeModelUtils.getNode(eObject);
				if (node instanceof CompositeNodeWithSemanticElement) {
					// store text information. e.g. to serialize XPath
					createCopy.eAdapters().add((CompositeNodeWithSemanticElement) node);
				}
				
				EObject origin = OriginElementAdapter.find(eObject);
				if (origin == null) {
					origin = eObject;
				}
				// trace origin reference
				createCopy.eAdapters().add(OriginElementAdapter.create(origin));
				
				// trace created copy in the source
				eObject.eAdapters().add(new CopiedObjectAdapter(createCopy));
				
				if (eObject instanceof Augment && InsideUsesMutationAdapter.find(eObject)) {
					// propagate marker to copies
					createCopy.eAdapters().add(InsideUsesMutationAdapter.create());
				}
				return createCopy;
			}
		};
		Collection<T> result = copier.copyAll(eObjects);
		copier.copyReferences();
		return result;
	}

	public static String serializedXpath(XpathExpression reference) {
		if (reference == null) {
			return null;
		}
		// TODO use serializer or implement a an own simple one
		ICompositeNode nodeFor = NodeModelUtils.findActualNodeFor(reference);
		if (nodeFor != null) {
			var nodeText = nodeFor.getText();
			nodeText = nodeText.replaceAll("\"|'|\\s|\n|\r", "").replaceAll("\\+", "");
			int firstColon = nodeText.indexOf(":");
			if (firstColon > 0) {
				nodeText = nodeText.substring(0, firstColon)
						+ nodeText.substring(firstColon).replaceAll("\\/[a-zA-Z]+:", "/");
			}
			return nodeText;
		}
		return "leafref";
	}

	/**
	 * 
	 * <p>
	 * Adapter holds a reference to the origin object.
	 * </p>
	 * This adapter is added to copied objects only and currently only used for better debugging.
	 */
	public static class OriginElementAdapter extends AdapterImpl {
		private final EObject origin;

		public OriginElementAdapter(EObject origin) {
			this.origin = origin;
		}

		public static OriginElementAdapter create(EObject origin) {
			return new OriginElementAdapter(origin);
		}

		public static EObject find(EObject eObj) {
			for (Adapter adapter : eObj.eAdapters()) {
				if (adapter instanceof OriginElementAdapter) {
					return ((OriginElementAdapter) adapter).origin;
				}
			}
			return null;
		}
	}

	/**
	 * <p>
	 * Adapter that marks an object being copied. The copy of this object being made
	 * is the adapter's <code>copy</code> field.
	 * </p>
	 * according to the "refine" and "augment" statements.
	 */
	public static class CopiedObjectAdapter extends AdapterImpl {
		final EObject copy;

		public CopiedObjectAdapter(EObject copy) {
			this.copy = copy;
		}

		public EObject getCopy() {
			return copy;
		}

		public static Stream<CopiedObjectAdapter> findAll(EObject eObject) {
			return eObject.eAdapters().stream().filter(a -> a instanceof CopiedObjectAdapter)
					.map(a -> ((CopiedObjectAdapter) a));
		}

	}

	/**
	 * <p>
	 * Marks an augment that was inside a uses xyz {} block.
	 * </p>
	 * 
	 * 
	 * The effect of a "uses" reference to a grouping is that the nodes defined by
	 * the grouping are copied into the current schema tree and are then updated
	 * 
	 */
	public static class InsideUsesMutationAdapter extends AdapterImpl {
		public static InsideUsesMutationAdapter create() {
			return new InsideUsesMutationAdapter();
		}

		public static boolean find(EObject eObj) {
			for (Adapter adapter : eObj.eAdapters()) {
				if (adapter instanceof InsideUsesMutationAdapter) {
					return true;
				}
			}
			return false;
		}
	}

}
