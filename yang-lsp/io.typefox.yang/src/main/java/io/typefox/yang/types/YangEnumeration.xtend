package io.typefox.yang.types

import com.google.common.collect.HashMultimap
import com.google.common.collect.ImmutableList
import com.google.common.primitives.Ints
import io.typefox.yang.utils.ValidationMessageAcceptorExt
import io.typefox.yang.utils.YangTypeExtensions
import io.typefox.yang.yang.Enum
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Value
import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.validation.ValidationMessageAcceptor

import static com.google.common.base.CharMatcher.*
import static com.google.common.base.Preconditions.*
import static io.typefox.yang.validation.IssueCodes.*
import static io.typefox.yang.yang.YangPackage.Literals.*
import static org.eclipse.xtext.validation.ValidationMessageAcceptor.INSIGNIFICANT_INDEX

import static extension io.typefox.yang.utils.ValidationMessageAcceptorExt.wrappedAcceptor

/**
 * Representation of a YANG <a href="https://tools.ietf.org/html/rfc7950#section-9.6">enumeration</a> built-in type.
 * 
 * @author akos.kitta
 */
class YangEnumeration {

	/**
	 * NOOP enumeration. Never logs any kind of issues during the validation.
	 */
	public static val NOOP = new YangEnumeration(0, emptyList, null) {

		override validate(ValidationMessageAcceptor it) {
			return true;
		}

		override toString() {
			return 'NOOP';
		}

	}

	/**
	 * Creates a data object that represents the YANG enumeration.
	 */
	static def create(Type it, YangEnumeration parentEnumeration) {
		checkArgument(eResource instanceof XtextResource, '''Unexpected EResource: «eResource»''');
		if (!(eResource as XtextResource).resourceServiceProvider.get(YangTypeExtensions).isSubtypeOfEnumeration(it)) {
			throw new IllegalArgumentException('''Type argument is not a subtype of the YANG enumeration type: «it»''');
		}
		val items = substatements.filter(Enum).map [
			new Individual(name, substatements.filter(Value).head?.value, it, null)
		];
		val maxValue = newArrayList(-1L);
		val substitutedItems = newArrayList();
		items.forEach [ currentItem |
			val substitutedValue = getValueSafe(currentItem, maxValue.head);
			if (substitutedValue > maxValue.head) {
				maxValue.set(0, substitutedValue);
			}
			substitutedItems.add(
				new Individual(currentItem.name, currentItem.value, currentItem.node, '''«substitutedValue»'''));
		]
		return new YangEnumeration(maxValue.head, substitutedItems, parentEnumeration);
	}

	private static def long getValueSafe(Individual item, long currentMax) {
		if (item.value === null) {
			return currentMax + 1;
		}
		try {
			// Although the value can only be between minimum and maximum integer, we make sure not to lose the value
			// and raise a validation error later instead. https://tools.ietf.org/html/rfc7950#section-9.6.4.2
			return Long.parseLong(item.value);
		} catch (NumberFormatException e) {
			return currentMax + 1;
		}
	}

	val long maxValue;
	val List<Individual> items;
	val YangEnumeration parentEnumeration;

	private new(long maxValue, Iterable<Individual> items, YangEnumeration parentEnumeration) {
		this.maxValue = maxValue;
		this.items = ImmutableList.copyOf(items);
		this.parentEnumeration = parentEnumeration;
	}

	/**
	 * Validates the enumeration, return {@code true} if no validation errors were log for the current instance,
	 * otherwise {@code false}.
	 */
	def boolean validate(ValidationMessageAcceptor it) {
		val acceptor = wrappedAcceptor;
		validateNames(acceptor);
		validateRestrictions(acceptor);
		return !acceptor.hasError;
	}

	private def boolean validateNames(ValidationMessageAcceptorExt acceptor) {
		val names = HashMultimap.create;
		items.forEach [
			names.put(name, it);
		];
		names.asMap.forEach [ name, individuals |
			// Validate name with respect of its length and any leading/trailing whitespace characters.
			individuals.forEach [
				val message = if (name.length === 0) {
						'''The name must not be zero-length.'''
					} else if (name != WHITESPACE.or(BREAKING_WHITESPACE).trimFrom(name)) {
						'''The name must not have any leading or trailing whitespace characters.'''
					} else {
						null;
					}
				if (message !== null) {
					acceptor.acceptError(message, node, ENUM__NAME, INSIGNIFICANT_INDEX, TYPE_ERROR);
				}
			];

			// Validate name uniqueness.
			if (individuals.size > 1) {
				individuals.forEach [
					val message = '''Assigned names in an enumeration MUST be unique: "«name»."''';
					acceptor.acceptError(message, node, ENUM__NAME, INSIGNIFICANT_INDEX, TYPE_ERROR);
				];
			}
		];
		return !acceptor.hasError;
	}

	private def boolean validateRestrictions(ValidationMessageAcceptorExt acceptor) {
		val currentItems = items.toMap[name];
		val parentItems = parentEnumeration.items.toMap[name];
		val visitedValues = HashMultimap.create;
		currentItems.forEach [ name, currentItem |
			val parentItem = parentItems.get(name);
			if (parentItem === null && parentEnumeration != NOOP) {
				val message = '''A new assigned name must not declared when restricting an existing enumeration.''';
				acceptor.acceptError(message, currentItem.node, ENUM__NAME, INSIGNIFICANT_INDEX, TYPE_ERROR);
			} else {
				if (currentItem.value !== null) {
					// Validate the value of the enumeration first.
					var String message = null;
					try {
						val value = Long.parseLong(currentItem.value);
						try {
							Ints.checkedCast(value);
							visitedValues.put(currentItem.substitutedValue, currentItem);
						} catch (IllegalArgumentException e) {
							throw new NumberFormatException();
						}
					} catch (NumberFormatException e) {
						message = '''The value must be an integer between -2147483648 to 2147483647.''';
					}
					if (message !== null) {
						val object = currentItem.node.substatements.filter(Value).head;
						acceptor.acceptError(message, object, VALUE__VALUE, INSIGNIFICANT_INDEX, TYPE_ERROR);
					}
				}
			}
		];
		visitedValues.asMap.entrySet.forEach[
			if (value.size > 1) {
				value.forEach[
					val message = '''The value must be unique within the enumeration type.''';			
					val object = node.substatements.filter(Value).head;
					acceptor.acceptError(message, object, VALUE__VALUE, INSIGNIFICANT_INDEX, TYPE_ERROR);
				];
			}
		];
		return !acceptor.hasError;
	}

	@Data
	private static class Individual {
		val String name;
		val String value;
		val Statement node;
		val String substitutedValue
	}

}
