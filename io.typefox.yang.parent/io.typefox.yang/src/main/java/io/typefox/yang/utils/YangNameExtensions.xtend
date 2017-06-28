package io.typefox.yang.utils

import com.google.common.base.Preconditions
import com.google.inject.Singleton
import io.typefox.yang.yang.Statement

import static com.google.common.base.CaseFormat.*

@Singleton
class YangNameExtensions {

	/**
	 * Returns with the human readable statement of the YANG statement. 
	 */
	def getYangName(Statement statement) {
		Preconditions.checkNotNull(statement, 'statement');
		return UPPER_CAMEL.converterTo(LOWER_HYPHEN).convert(statement.eClass.instanceClass.simpleName).toFirstLower;
	}

}
