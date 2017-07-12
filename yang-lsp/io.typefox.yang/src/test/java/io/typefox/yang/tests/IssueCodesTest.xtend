package io.typefox.yang.tests

import com.google.common.collect.Maps
import com.google.inject.Inject
import io.typefox.yang.validation.IssueCodes
import org.junit.Rule
import org.junit.Test
import org.junit.rules.ErrorCollector

import static extension java.lang.reflect.Modifier.*

/**
 * Test to verify that all issues codes are available from the {@link IssueCodes#getConfigurableIssueCodes() 
 * configurable issue codes}.
 * 
 * @author akos.kitta
 */
class IssueCodesTest extends AbstractYangTest {

	@Rule
	public val collector = new ErrorCollector();

	@Inject
	extension IssueCodes;

	@Test
	def void checkCodes() {
		val copy = Maps.newHashMap(configurableIssueCodes);
		val issueCodes = IssueCodes.declaredFields.filter [
			modifiers.static && modifiers.public && type === String
		].map[
			get(null) as String
		];
		issueCodes.forEach[
			val value = copy.remove(it);
			if (value === null) {
				val message = '''Issue code '«it»' was not registerted among the configurable codes although it is declared as a code.''';
				collector.addError(new IllegalStateException(message));
			}
		];
		copy.keySet.forEach[
			val message = '''Issue code '«it»' was registerted among the configurable codes although it is not declared as a code.''';
			collector.addError(new IllegalStateException(message));
		];
	}

}
