package io.typefox.yang.tests.processor;

import static org.junit.Assert.*;

import java.util.Collections;

import org.junit.Test;

import com.google.common.collect.Lists;

import io.typefox.yang.processor.FeatureEvaluationContext;

public class FeatureContextTest {

	@Test
	public void testIncludeOneFeature() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Lists.newArrayList("module:feature1"),
				Collections.emptyList());
		assertTrue(ctx.isActive("module:", "module:feature1", "feature1"));
		assertFalse(ctx.isActive("module:", "module:feature2", "feature2"));
	}
	
	@Test
	public void testIncludeNoFeature() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Lists.newArrayList("module:"),
				Collections.emptyList());
		assertFalse(ctx.isActive("module:", "module:feature1", "feature1"));
		assertFalse(ctx.isActive("module:", "module:feature2", "feature2"));
	}
	@Test
	public void testIncludeTwoFeatures() {
		FeatureEvaluationContext ctx = new FeatureEvaluationContext(Lists.newArrayList("module:feature1,feature2"),
				Collections.emptyList());
		assertTrue(ctx.isActive("module:", "module:feature1", "feature1"));
		assertTrue(ctx.isActive("module:", "module:feature2", "feature2"));
	}
}
