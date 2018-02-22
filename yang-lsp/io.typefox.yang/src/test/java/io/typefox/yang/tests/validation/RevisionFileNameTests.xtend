package io.typefox.yang.tests.validation

import com.google.inject.Inject
import io.typefox.yang.tests.YangInjectorProvider
import io.typefox.yang.yang.AbstractModule
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.runner.RunWith
import org.junit.Test
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import static io.typefox.yang.validation.IssueCodes.*
import static io.typefox.yang.yang.YangPackage.Literals.*

@InjectWith(YangInjectorProvider)
@RunWith(XtextRunner)
class RevisionFileNameTests {

	@Inject extension ParseHelper<AbstractModule>
	@Inject XtextResourceSet resourceSet
	@Inject extension ValidationTestHelper validationTestHelper
	
	@Test
	def void testIllegalFilename() {
		'''
			module foo {
				prefix foo;
				namespace foo;
			}
		'''
			.parse(URI.createURI('test@invalidformat.yang'), resourceSet)
			.assertWarning(ABSTRACT_MODULE, INVALID_REVISION_FORMAT)
	} 	

	@Test
	def void testWrongFilename() {
		'''
			module foo {
				prefix foo;
				namespace foo;
				revision 2012-12-12 {
					description 'what a revision!';
				}
			}
		'''
			.parse(URI.createURI('test@2000-01-01.yang'), resourceSet)
			.assertWarning(REVISION, REVISION_MISMATCH)
	} 	
}