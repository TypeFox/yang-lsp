package io.typefox.yang.types

import com.google.common.collect.ImmutableList
import com.google.common.collect.Lists
import com.google.common.collect.Range
import java.util.List

/**
 * Immutable representation of a <a href="https://tools.ietf.org/html/rfc7950#section-9.2.4">YANG range</a>.
 * 
 * @author akos.kitta
 */
class YangRange<C extends Comparable<C>> {

	val List<Range<C>> disjoints;

	static def create(io.typefox.yang.yang.Range range) {
		
	}

	new(C first, C... rest) {
		this(first.singleValueOf, rest.map[singleValueOf]);
	}

	new(Range<C> first, Range<C>... rest) {
		this(Lists.asList(first, rest));
	}
	
	private new(Iterable<Range<C>> ranges) {
		disjoints = ImmutableList.copyOf(ranges);
	}

	def boolean isValid() {
		// TODO consider concrete value case that exceeds the built-in range.
		if (disjoints.size > 1) {
			val itr = disjoints.listIterator;
			itr.next; // Skip the first item. We always compare the actual one with the previous element.
			while (itr.hasNext) {
				val previous = itr.previous;
				val current = itr.next;
				// MUST be disjoint.
				if (!previous.intersection(current).empty) {
					return false;
				}
				// MUST be in ascending order.
				if (previous.upperBoundType >= current.lowerBoundType) {
					return false;
				} 
			}
		}
		return true;
	}

	override toString() {
		return disjoints.map[label].join(' | ');
	}

	// Label pattern: `36` or `0..36`.
	private def getLabel(Range<C> it) {
		return '''«lowerBoundType»«IF lowerEndpoint != upperEndpoint»..«upperEndpoint»«ENDIF»''';
	}

	private static def <C extends Comparable<C>> singleValueOf(C c) {
		return Range.closed(c, c);
	}

}
