package io.typefox.yang.types

import com.google.common.base.Splitter
import com.google.common.collect.Lists
import io.typefox.yang.yang.BinaryOperation
import io.typefox.yang.yang.Literal
import io.typefox.yang.yang.Max
import io.typefox.yang.yang.Min
import io.typefox.yang.yang.Range
import io.typefox.yang.yang.util.YangSwitch
import java.math.BigDecimal
import java.util.List
import org.eclipse.xtext.xbase.lib.Functions.Function1

import static com.google.common.collect.Range.closed

import static extension com.google.common.collect.ImmutableList.copyOf

/**
 * Immutable representation of a <a href="https://tools.ietf.org/html/rfc7950#section-9.2.4">YANG range</a>.
 * 
 * @author akos.kitta
 */
class YangRange {

	val List<com.google.common.collect.Range<BigDecimal>> disjoints;

	static def create(Range range, YangRange parentRange) {
		return new YangRange(new RangeTransformer(parentRange).apply(range));
	}

	/**
	 * Where each string argument represent either range ({@code NUMBER .. NUMBER}) or an concrete value ({@code NUMBER}). 
	 */
	new(String first, String... rest) {
		this(Lists.asList(first, rest));
	}

	private new(Iterable<String> ranges) {
		disjoints = ranges.map[Splitter.on('..').omitEmptyStrings.trimResults.split(it)].map [
			closed(new BigDecimal(head), new BigDecimal(if(size === 1) head else last));
		].copyOf;
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

	def getMin() {
		return disjoints.head.lowerEndpoint;
	}

	def getMax() {
		return disjoints.last.upperEndpoint;
	}

	override toString() {
		return disjoints.map[label].join(' | ');
	}

	// Label pattern: `36` or `0..36`.
	private def getLabel(com.google.common.collect.Range<?> it) {
		return '''«lowerEndpoint»«IF lowerEndpoint != upperEndpoint»..«upperEndpoint»«ENDIF»''';
	}

	/**
	 * YANG range visitor that transforms the AST nodes into a list of range strings. 
	 */
	private static class RangeTransformer extends YangSwitch<String> implements Function1<Range, Iterable<String>> {

		val YangRange parentRange;

		private new(YangRange parentRange) {
			this.parentRange = parentRange;
		}

		override apply(Range it) {
			return Splitter.on('|').omitEmptyStrings.trimResults.split(doSwitch);
		}

		override caseRange(Range it) {
			return doSwitch(expression);
		}

		override caseBinaryOperation(BinaryOperation it) {
			return '''«doSwitch(left)»«operator.trim»«doSwitch(right)»''';
		}

		override caseMin(Min object) {
			return '''«parentRange.min»''';
		}

		override caseMax(Max object) {
			return '''«parentRange.max»''';
		}

		override caseLiteral(Literal it) {
			return value;
		}

	}

}
