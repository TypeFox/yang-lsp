package io.typefox.yang.processor;

import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

import io.typefox.yang.yang.Feature;

public class FeatureEvaluationContext {

	private Map<String, Boolean> cache = Maps.newHashMap();

	private Set<String> include = Sets.newHashSet(), exclude = Sets.newHashSet();

	public FeatureEvaluationContext(List<String> includedFeatures, List<String> excludedFeatures) {
		include.addAll(includedFeatures);
		exclude.addAll(excludedFeatures);
	}

	public boolean isActive(Feature feature) {
		var featureQName = ProcessorUtility.moduleIdentifier(feature).name + ":" + feature.getName();
		if (cache.containsKey(featureQName)) {
			return cache.get(featureQName);
		}
		var active = isActive(featureQName) && featureIfConditionsActive(feature);
		cache.put(featureQName, active);
		return active;
	}

	private boolean featureIfConditionsActive(Feature feature) {
		return ProcessorUtility.checkIfFeatures(ProcessorUtility.findIfFeatures(feature), this);
	}

	private boolean isActive(String featureQName) {
		return (include.isEmpty() || include.contains(featureQName))
				&& (exclude.isEmpty() || !exclude.contains(featureQName));
	}
}