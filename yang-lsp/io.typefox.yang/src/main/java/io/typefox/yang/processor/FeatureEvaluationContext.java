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
	private Set<String> exclude = Sets.newHashSet();

	public FeatureEvaluationContext(List<String> includedFeatures, List<String> excludedFeatures) {
		for (var featureToInclude : includedFeatures) {
			Pair<String, String[]> parsedFeature = parseFeature(featureToInclude);
			if (parsedFeature != null) {
				include.put(parsedFeature.getFirst(), Sets.newHashSet(parsedFeature.getSecond()).stream()
						.map(it -> it.trim()).collect(Collectors.toSet()));
			}
		}
		exclude.addAll(excludedFeatures);
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
		var active = isActive(featureModule.name + ":", featureQName, feature.getName())
				&& featureIfConditionsActive(feature);
		cache.put(featureQName, active);
		return active;
	}

	private boolean featureIfConditionsActive(Feature feature) {
		return ProcessorUtility.checkIfFeatures(ProcessorUtility.findIfFeatures(feature), this);
	}

	public boolean isActive(String modulePrefix, String featureQName, String featureName) {
		// include <module>: means include none of <module> features.
		var moduleEntry = include.get(modulePrefix);
		// if <module>: not listed in include, all features are enabled by default.
		boolean included = true;
		if (moduleEntry != null) {
			// include e.g. 'example-system-ext:' means any of example-system-ext module
			// features should be included
			included = moduleEntry.contains(featureName);
		}
		return (included) && (exclude.isEmpty() || !(exclude.contains(featureQName) || exclude.contains(modulePrefix)));
	}

	private String featureGlobalQName(ElementIdentifier module, String featureName) {
		return module.name + ":" + featureName;
	}
}