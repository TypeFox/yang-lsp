package io.typefox.yang.processor;

import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

import io.typefox.yang.processor.ProcessedDataTree.ElementIdentifier;
import io.typefox.yang.yang.Feature;

public class FeatureEvaluationContext {

	private Map<String, Boolean> cache = Maps.newHashMap();

	private Set<String> include = Sets.newHashSet(), exclude = Sets.newHashSet();

	public FeatureEvaluationContext(List<String> includedFeatures, List<String> excludedFeatures) {
		include.addAll(includedFeatures);
		exclude.addAll(excludedFeatures);
	}

	public boolean isActive(Feature feature) {
		ElementIdentifier featureModule = ProcessorUtility.moduleIdentifier(feature);
		var featureQName = featureGlobalQName(featureModule, feature.getName());
		if (cache.containsKey(featureQName)) {
			return cache.get(featureQName);
		}
		var active = isActive(featureModule.name + ":", featureQName) && featureIfConditionsActive(feature);
		cache.put(featureQName, active);
		return active;
	}

	private boolean featureIfConditionsActive(Feature feature) {
		return ProcessorUtility.checkIfFeatures(ProcessorUtility.findIfFeatures(feature), this);
	}

	private boolean isActive(String modulePrefix, String featureQName) {
		// include <module>: means include none of <module> features...???
		if(include.contains(modulePrefix) && !include.contains(featureQName)) {
			// include e.g. 'example-system-ext:' means any of example-system-ext module features should be included
			return false;
		}
		return (include.isEmpty() || include.contains(featureQName))
				&& (exclude.isEmpty() || !(exclude.contains(featureQName) || exclude.contains(modulePrefix)));
	}

	private String featureGlobalQName(ElementIdentifier module, String featureName) {
		return module.name + ":" + featureName;
	}
}