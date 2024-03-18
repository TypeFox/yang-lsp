package io.typefox.yang.tests.processor;

import static org.junit.Assert.*;

import java.util.Collections;

import org.junit.Test;

import com.google.common.collect.Lists;

import io.typefox.yang.processor.FeatureEvaluationContext;

public class FeatureContextTest {
	// Include
	@Test
	public void testIncludeOneFeature() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Lists.newArrayList("module:feature1"),
				Collections.emptyList());
		assertTrue(ctx.isActive("module:", "feature1"));
		assertFalse(ctx.isActive("module:", "feature2"));
		// all other modules that are not listed are completely enabled
		assertTrue(ctx.isActive("module2:", "feature1"));
		assertTrue(ctx.isActive("module2:", "feature2"));
	}

	@Test
	public void testIncludeNoFeature() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Lists.newArrayList("module:"),
				Collections.emptyList());
		assertFalse(ctx.isActive("module:", "feature1"));
		assertFalse(ctx.isActive("module:", "feature2"));
		assertTrue(ctx.isActive("module2:", "feature1"));
		assertTrue(ctx.isActive("module2:", "feature2"));
	}

	@Test
	public void testIncludeAllFeaturesOneModule() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(
				Lists.newArrayList("module:feature1", "module:feature2"), Collections.emptyList());
		assertTrue(ctx.isActive("module:", "feature1"));
		assertTrue(ctx.isActive("module:", "feature2"));
		assertTrue(ctx.isActive("module2:", "feature1"));
		assertTrue(ctx.isActive("module2:", "feature2"));
	}
	@Test
	public void testIncludeTwoFeatures() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(
				Lists.newArrayList("module:feature1", "module2:feature1"), Collections.emptyList());
		assertTrue(ctx.isActive("module:", "feature1"));
		assertFalse(ctx.isActive("module:", "feature2"));
		assertTrue(ctx.isActive("module2:", "feature1"));
		assertFalse(ctx.isActive("module2:", "feature2"));
	}

	@Test
	public void testIncludeTwoFeaturesCommaNotation() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Lists.newArrayList("module:feature1,feature2"),
				Collections.emptyList());
		assertTrue(ctx.isActive("module:", "feature1"));
		assertTrue(ctx.isActive("module:", "feature2"));
		assertTrue(ctx.isActive("module2:", "feature1"));
		assertTrue(ctx.isActive("module2:", "feature2"));
	}

	@Test
	public void testIncludeAllFeatures() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(
				Lists.newArrayList("module:feature1", "module:feature2", "module2:feature1", "module2:feature2"),
				Collections.emptyList());
		assertTrue(ctx.isActive("module:", "feature1"));
		assertTrue(ctx.isActive("module:", "feature2"));
		assertTrue(ctx.isActive("module2:", "feature1"));
		assertTrue(ctx.isActive("module2:", "feature2"));
	}

	@Test
	public void testMissingFeatureInclude() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Collections.emptyList(), Collections.emptyList());
		assertTrue(ctx.isActive("module:", "feature1"));
		assertTrue(ctx.isActive("module:", "feature2"));
		assertTrue(ctx.isActive("module2:", "feature1"));
		assertTrue(ctx.isActive("module2:", "feature2"));
	}

	// Excludes
	@Test
	public void testExcludeOneFeature() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Collections.emptyList(),
				Lists.newArrayList("module:feature1"));
		assertFalse(ctx.isActive("module:", "feature1"));
		assertTrue(ctx.isActive("module:", "feature2"));
	}

	@Test
	public void testExcludeNoFeature() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Collections.emptyList(),
				Lists.newArrayList("module:"));
		assertFalse(ctx.isActive("module:", "feature1"));
		assertFalse(ctx.isActive("module:", "feature2"));
	}

	@Test
	public void testExcludeTwoFeatures() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Collections.emptyList(),
				Lists.newArrayList("module:feature1", "module:feature2"));
		assertFalse(ctx.isActive("module:", "feature1"));
		assertFalse(ctx.isActive("module:", "feature2"));
	}

	@Test
	public void testExcludeTwoFeaturesCommaNotation() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Collections.emptyList(),
				Lists.newArrayList("module:feature1,feature2"));
		assertFalse(ctx.isActive("module:", "feature1"));
		assertFalse(ctx.isActive("module:", "feature2"));
	}
}
