package io.typefox.yang.processor;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.eclipse.xtext.util.Pair;
import org.eclipse.xtext.util.Tuples;

import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

import io.typefox.yang.processor.ProcessedDataModel.ElementIdentifier;
import io.typefox.yang.yang.Feature;

public class FeatureEvaluationContext {

	private Map<String, Boolean> cache = Maps.newHashMap();

	private Map<String, Set<String>> include = Maps.newHashMap();
	private Map<String, Set<String>> exclude = Maps.newHashMap();

	public FeatureEvaluationContext(List<String> includedFeatures, List<String> excludedFeatures) {
		processConfiguration(includedFeatures, include);
		processConfiguration(excludedFeatures, exclude);
	}

	private void processConfiguration(List<String> features, Map<String, Set<String>> featureMap) {
		for (var featureEntry : features) {
			Pair<String, String[]> parsedFeature = parseFeature(featureEntry);
			if (parsedFeature != null) {
				Set<String> existingInclude = featureMap.get(parsedFeature.getFirst());
				Set<String> toAdd = Sets.newHashSet(parsedFeature.getSecond()).stream().map(it -> it.trim())
						.filter(it -> !it.isEmpty()).collect(Collectors.toSet());
				if (existingInclude != null) {
					existingInclude.addAll(toAdd);
				} else {
					featureMap.put(parsedFeature.getFirst(), toAdd);
				}
			}
		}
	}

	private Pair<String, String[]> parseFeature(String featureToInclude) {
		var colonIdx = featureToInclude.indexOf(':');
		if (colonIdx > 0) {
			var module = featureToInclude.substring(0, colonIdx + 1);
			var features = featureToInclude.substring(colonIdx + 1).split(",");
			return Tuples.pair(module, features);
		} else {
			System.out.println("Feature include '" + featureToInclude
					+ "' ignored. Must match the pattern: modulename:[feature(,feature)*]");
		}
		return null;
	}

	public boolean isActive(Feature feature) {
		ElementIdentifier featureModule = ProcessorUtility.moduleIdentifier(feature);
		var featureQName = featureGlobalQName(featureModule, feature.getName());
		if (cache.containsKey(featureQName)) {
			return cache.get(featureQName);
		}
		var active = isActive(featureModule.name + ":", feature.getName()) && featureIfConditionsActive(feature);
		cache.put(featureQName, active);
		return active;
	}

	private boolean featureIfConditionsActive(Feature feature) {
		return ProcessorUtility.checkIfFeatures(ProcessorUtility.findIfFeatures(feature), this);
	}

	/**
	 * For testing only. Use cached
	 * {@link FeatureEvaluationContext#isActive(Feature)} instead.
	 * 
	 * @param modulePrefix
	 * @param featureName
	 * @return
	 */
	public boolean isActive(String modulePrefix, String featureName) {
		// All modules and features are enabled by default.
		boolean included = true;
		var includeEntry = include.get(modulePrefix);
		if (includeEntry != null) {
			// include e.g. 'example-system-ext:' means any of example-system-ext module
			// features should be included
			included = includeEntry.contains(featureName);
		}

		if (!included) {
			return false;
		}

		boolean excluded = false;
		var excludeEntry = exclude.get(modulePrefix);
		if (excludeEntry != null) {
			if (excludeEntry.isEmpty()) {
				// exclude all e.g. 'example-system-ext:' means exclude all of example-system-ex
				// features
				excluded = true;
			} else {
				// otherwise check feature entry
				excluded = excludeEntry.contains(featureName);
			}
		}

		return included && !excluded;
	}

	private String featureGlobalQName(ElementIdentifier module, String featureName) {
		return module.name + ":" + featureName;
	}
}