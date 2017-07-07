package io.typefox.yang.types

import com.google.common.collect.HashMultimap
import com.google.common.collect.ImmutableList
import io.typefox.yang.utils.ValidationMessageAcceptorExt
import io.typefox.yang.utils.YangTypeExtensions
import io.typefox.yang.yang.Enum
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Value
import java.util.List
import org.eclipse.emf.ecore.EObject
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
	public static val NOOP = new YangEnumeration(emptyList, null) {

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
		val items = substatements.filter(Enum).map[new Individual(name, substatements.filter(Value).head?.value, it)];
		return new YangEnumeration(items, parentEnumeration);
	}

	val List<Individual> items;
	val YangEnumeration parentEnumeration;

	private new(Iterable<Individual> items, YangEnumeration parentEnumeration) {
		this.items = ImmutableList.copyOf(items);
		this.parentEnumeration = parentEnumeration;
	}

	/**
	 * Validates the enumeration, return {@code true} if no validation errors were log for the current instance,
	 * otherwise {@code false}.
	 */
	def boolean validate(ValidationMessageAcceptor it) {
		val acceptor = wrappedAcceptor;
		return validateNames(acceptor);
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

	@Data
	private static class Individual {
		val String name;
		val String ordinal;
		val EObject node;
	}

}
