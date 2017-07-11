package io.typefox.yang.tests

import io.typefox.yang.yang.Pattern
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.Typedef
import org.junit.Assert
import org.junit.Test

/**
 * Test for checking the string escaping in the value converter service.
 * 
 * @author akos.kitta
 */
class YangValueConverterServiceTest extends AbstractYangTest {

	@Test
	def void checkConvertSingleQuotedString() {
		val it = '''
			module foo {
			  typedef ipv6-address {
			    type string {
			      pattern '((:|[0-9a-fA-F]{0,4}):)([0-9a-fA-F]{0,4}:){0,5}'
			        + '((([0-9a-fA-F]{0,4}:)?(:|[0-9a-fA-F]{0,4}))|'
			        + '(((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}'
			        + '(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])))'
			        + '(%[\p{N}\p{L}]+)?';
			    }
			  }
			}
		'''.load;
		val pattern = root.firstSubstatementsOfType(Typedef).firstSubstatementsOfType(Type).
			firstSubstatementsOfType(Pattern);
		Assert.
			assertEquals('''((:|[0-9a-fA-F]{0,4}):)([0-9a-fA-F]{0,4}:){0,5}((([0-9a-fA-F]{0,4}:)?(:|[0-9a-fA-F]{0,4}))|(((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])))(%[\p{N}\p{L}]+)?'''.toString,
				pattern.regexp);
	}
	
	@Test
	def void checkConvertDoubleQuotedString() {
		val it = '''
			module foo {
			  typedef ipv6-address {
			    type string {
			      pattern "((:|[0-9a-fA-F]{0,4}):)([0-9a-fA-F]{0,4}:){0,5}"
			        + "((([0-9a-fA-F]{0,4}:)?(:|[0-9a-fA-F]{0,4}))|"
			        + "(((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}"
			        + "(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])))"
			        + "(%[\p{N}\p{L}]+)?";
			    }
			  }
			}
		'''.load;
		val pattern = root.firstSubstatementsOfType(Typedef).firstSubstatementsOfType(Type).
			firstSubstatementsOfType(Pattern);
		Assert.
			assertEquals('''((:|[0-9a-fA-F]{0,4}):)([0-9a-fA-F]{0,4}:){0,5}((([0-9a-fA-F]{0,4}:)?(:|[0-9a-fA-F]{0,4}))|(((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])))(%[\p{N}\p{L}]+)?'''.toString,
				pattern.regexp);
	}

}
