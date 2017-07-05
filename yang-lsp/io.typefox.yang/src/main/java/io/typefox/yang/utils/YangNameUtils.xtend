package io.typefox.yang.utils

import com.google.common.base.Preconditions
import io.typefox.yang.yang.Statement
import org.eclipse.emf.ecore.EClass

import static com.google.common.base.CaseFormat.*

/**
 * Utility class for getting the YANG name from EObject instances and EClasses.
 * 
 * <p>
 * For instance {@code YangVersion} will return with {@code yang-version}.
 * 
 * @author akos.kitta
 */
abstract class YangNameUtils {

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

	private new() {
	}

}
