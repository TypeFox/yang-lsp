package io.typefox.yang.utils

import com.google.common.collect.ArrayListMultimap
import com.google.common.collect.Multimap
import org.eclipse.xtext.xbase.lib.Functions.Function1

/**
 * Contains a collection of extension methods for {@link Iterable iterable}s.
 * 
 * @author akos.kitta 
 */
class IterableExtensions2 {

	/**
	 * Returns a multimap where each key is the result of invoking the supplied function {@code computeKeys}
	 * on its corresponding value. If the function produces the same key for different values, multiple 
	 * values will be available for that particular key.
	 * 
	 * @param values
	 *            the values to use when constructing the {@code Multimap}. Must not be {@code null}.
	 * @param computeKeys
	 *            the function used to produce the key for each value. Must not be {@code null}.
	 */
	static def <K, V> Multimap<K, V> toMultimap(Iterable<? extends V> values, Function1<? super V, K> computeKeys) {
		val map = ArrayListMultimap.create;
		values.forEach[map.put(computeKeys.apply(it), it)];
		return map;
	}
}
