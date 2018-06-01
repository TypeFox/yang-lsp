package io.typefox.yang.utils

import com.google.common.base.Preconditions
import com.google.common.cache.CacheBuilder
import io.typefox.yang.yang.BelongsTo
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.YangPackage
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtend.lib.annotations.Data

import static com.google.common.base.CaseFormat.*
import static com.google.common.base.CharMatcher.*

/**
 * Utility class for getting the YANG name from EObject instances and EClasses.
 * 
 * <p>
 * For instance {@code YangVersion} will return with {@code yang-version}.
 * 
 * @author akos.kitta
 */
abstract class YangNameUtils {

	static val NAME_TO_ECLASS_CACHE = CacheBuilder.newBuilder.<String, EClassWrapper>build([
		val simpleName = LOWER_HYPHEN.converterTo(UPPER_CAMEL).convert(it);
		val classifier = YangPackage.eINSTANCE.getEClassifier(simpleName);
		if (classifier instanceof EClass) {
			return new EClassWrapper(classifier);
		}
		return EClassWrapper.MISSING;
	]);

	/**
	 * Returns with the human readable statement of the YANG statement. 
	 */
	static def dispatch String getYangName(Statement statement) {
		Preconditions.checkNotNull(statement, 'statement');
		return statement.eClass.yangName;
	}

	/**
	 * Returns with the human readable YANG name for the EClass argument. 
	 */
	static def dispatch String getYangName(EClass clazz) {
		Preconditions.checkNotNull(clazz, 'clazz');
		return clazz.instanceClass.yangName;
	}

	/**
	 * Returns with the YANG name of the class argument. 
	 */
	static def dispatch String getYangName(Class<?> clazz) {
		Preconditions.checkNotNull(clazz, 'clazz');
		return UPPER_CAMEL.converterTo(LOWER_HYPHEN).convert(clazz.simpleName).toFirstLower;
	}

	/**
	 * Returns with the EClass for the YANG name or {@code null} if the EClass cannot be resolved.
	 * <p>
	 * For instance returns with {@link BelongsTo} for {@code belongs-to}.
	 */
	static def EClass getEClassForName(String yangName) {
		return if(yangName.nullOrEmpty) null else NAME_TO_ECLASS_CACHE.getUnchecked(yangName).orNull;
	}

	/**
	 * Replaces all whitespace (and invisible) characters with a hyphen (@code {-}) character in the 
	 * argument and returns with it. Consecutive whitespace character will be replaced with one single
	 * hyphen. Trailing and leading whitespace characters will not be replaces but just trimmed. 
	 */	
	static def String escapeModuleName(String it) {
		return whitespace.or(breakingWhitespace).or(invisible).trimAndCollapseFrom(trim, '-');
	}

	private new() {
	}

	/**
	 * Wraps an EClass because the loading cache must not return with {@code null}.
	 */
	@Data
	static final class EClassWrapper {

		static val MISSING = new EClassWrapper(null);

		val EClass clazz;

		def private orNull() {
			return if(clazz === null || this === MISSING) null else clazz;
		}

	}

}
