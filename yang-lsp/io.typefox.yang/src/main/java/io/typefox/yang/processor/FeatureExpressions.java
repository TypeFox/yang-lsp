package io.typefox.yang.processor;

import io.typefox.yang.processor.ProcessorUtility.ModuleIdentifier;
import io.typefox.yang.yang.BinaryOperation;
import io.typefox.yang.yang.Expression;
import io.typefox.yang.yang.Feature;
import io.typefox.yang.yang.FeatureReference;
import io.typefox.yang.yang.UnaryOperation;

public class FeatureExpressions {

	public static abstract class FeatureCondition {

		abstract boolean evaluate(FeatureEvaluationContext ctx);

		public static FeatureCondition create(Expression exp) {
			return build(exp);
		}

		private static FeatureCondition build(Expression exp) {
			if (exp instanceof FeatureReference) {
				return new IsFeatureCondition(((FeatureReference) exp).getFeature(),
						ProcessorUtility.moduleIdentifier(exp));
			} else if (exp instanceof UnaryOperation) {
				return new IsFeatureCondition(((FeatureReference) exp).getFeature(), true,
						ProcessorUtility.moduleIdentifier(exp));
			} else if (exp instanceof BinaryOperation) {
				BinaryOperation bin = (BinaryOperation) exp;
				return new BinaryFeatureCondition(build(bin.getLeft()), build(bin.getRight()),
						"and".equals(bin.getOperator()));
			}
			return null;
		}
	}

	public static class IsFeatureCondition extends FeatureCondition {

		final private Feature feature;
		final private boolean not;
		final private ModuleIdentifier conditionModule;

		public IsFeatureCondition(Feature feature, ModuleIdentifier conditionModule) {
			this(feature, false, conditionModule);
		}

		public IsFeatureCondition(Feature feature, boolean not, ModuleIdentifier conditionModule) {
			this.feature = feature;
			this.conditionModule = conditionModule;
			this.not = not;
		}

		@Override
		boolean evaluate(FeatureEvaluationContext ctx) {
			return not ? !ctx.isActive(feature) : ctx.isActive(feature);
		}

		private String toStringValue = null;

		@Override
		public String toString() {
			if (toStringValue == null) {
				ModuleIdentifier featureModule = ProcessorUtility.moduleIdentifier(feature);
				String prefix = conditionModule.name.equals(featureModule.name) ? "" : featureModule.prefix + ":";
				toStringValue = (not ? "!" : "") + prefix + feature.getName();
			}
			return toStringValue;
		}
	}

	public static class BinaryFeatureCondition extends FeatureCondition {
		final private FeatureCondition left, right;
		final private boolean isAnd;

		/**
		 * Creates an OR binary condition
		 * 
		 * @param left
		 * @param right
		 */
		public BinaryFeatureCondition(FeatureCondition left, FeatureCondition right) {
			this(left, right, false);
		}

		/**
		 * @param left
		 * @param right
		 * @param isAnd <code>true</code> if it's an AND binary condition. Default is
		 *              <code>false</code>: OR
		 */
		public BinaryFeatureCondition(FeatureCondition left, FeatureCondition right, boolean isAnd) {
			super();
			this.left = left;
			this.right = right;
			this.isAnd = isAnd;
		}

		@Override
		boolean evaluate(FeatureEvaluationContext ctx) {
			return isAnd ? left.evaluate(ctx) && right.evaluate(ctx) : left.evaluate(ctx) || right.evaluate(ctx);
		}

		@Override
		public String toString() {
			return left.toString() + (isAnd ? " and " : " or ") + right.toString();
		}
	}
}
