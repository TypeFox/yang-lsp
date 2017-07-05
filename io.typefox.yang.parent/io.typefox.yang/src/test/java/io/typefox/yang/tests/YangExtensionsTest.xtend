package io.typefox.yang.tests

import com.google.inject.Inject
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.yang.YangFactory
import org.junit.Test

import static org.junit.Assert.*

/**
 * Testing the YANG extensions.
 * 
 * @author akos.kitta
 */
class YangExtensionsTest extends AbstractYangTest {

	@Inject
	extension YangExtensions;

	@Test
	def void checkImplicitVersion_Expect_1() {
		val it = load('''
			module example-system {
			}
		''');
		assertEquals(YangExtensions.YANG_1, root.yangVersion);
	}

	@Test
	def void checkExplicitVersion_Expect_1() {
		val it = load('''
			module example-system {
			  yang-version 1;
			}
		''');
		assertEquals(YangExtensions.YANG_1, root.yangVersion);
	}

	@Test
	def void checkExplicitVersion_Expect_1_1() {
		val it = load('''
			module example-system {
			  yang-version 1.1;
			}
		''');
		assertEquals(YangExtensions.YANG_1_1, root.yangVersion);
	}

	@Test
	def void checkExplicitVersion_Invalid_Expect_Null() {
		val it = load('''
			module example-system {
			  yang-version 1.2;
			}
		''');
		assertEquals(null, root.yangVersion);
	}

	@Test
	def void checkExplicitVersion_Broken_Expect_Null() {
		assertEquals(null, YangFactory.eINSTANCE.createYangVersion.yangVersion);
	}

}
