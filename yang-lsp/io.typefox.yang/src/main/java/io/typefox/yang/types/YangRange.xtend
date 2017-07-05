package io.typefox.yang.types

import com.google.common.base.Splitter
import com.google.common.base.Supplier
import com.google.common.base.Suppliers
import io.typefox.yang.yang.BinaryOperation
import io.typefox.yang.yang.Literal
import io.typefox.yang.yang.Max
import io.typefox.yang.yang.Min
import io.typefox.yang.yang.Range
import io.typefox.yang.yang.util.YangSwitch
import java.util.Collections
import java.util.List
import org.eclipse.xtext.xbase.lib.Functions.Function1

import static extension com.google.common.collect.ImmutableList.copyOf

/**
 * Immutable representation of a <a href="https://tools.ietf.org/html/rfc7950#section-9.2.4">YANG range</a>.
 * 
 * @author akos.kitta
 */
class YangRange {

	static val MIN = 'min';
	static val MAX = 'max';

	val List<Pair<String, String>> disjoints;
	val YangRange parentRange;
	val Supplier<String> minSupplier;
	val Supplier<String> maxSupplier;

	static def create(Range range, YangRange parentRange) {
		return new YangRange(new RangeTransformer(parentRange).apply(range), parentRange);
	}

	static def createBuiltin(String range) {
		return new YangRange(Collections.singleton(range), null);
	}

	private new(Iterable<String> ranges, YangRange parentRange) {
		disjoints = ranges.map[Splitter.on('..').omitEmptyStrings.trimResults.split(it)].map [
			head -> if(size === 1) head else last;
		].copyOf;
		this.parentRange = parentRange;
		maxSupplier = Suppliers.memoize [
			val max = disjoints.last.value;
			if (max == MAX) {
				if (parentRange === null) {
					throw new IllegalStateException('''Cannot use 'min' keyword when parent range is not specified.''');
				}
				return parentRange.max;
			}
			return max;
		];
		minSupplier = Suppliers.memoize [
			val min = disjoints.head.key;
			if (min == MIN) {
				if (parentRange === null) {
					throw new IllegalStateException('''Cannot use 'min' keyword when parent range is not specified.''');
				}
				return parentRange.min;
			}
			return min;
		];
	}

	def String getMin() {
		return minSupplier.get;
	}

	def String getMax() {
		return maxSupplier.get;
	}

	override toString() {
		return disjoints.map[label].join(' | ');
	}

	// Label pattern: `36` or `0..36`.
	private def getLabel(Pair<?, ?> it) {
		val bounds = #[key, value].map [
			switch (it) {
				case MIN: min
				case MAX: max
				default: it
			}
		];
		return '''«bounds.head»«IF bounds.head != bounds.last»..«bounds.last»«ENDIF»''';
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
			return MIN;
		}

		override caseMax(Max object) {
			return MAX;
		}

		override caseLiteral(Literal it) {
			return value;
		}

	}

}
