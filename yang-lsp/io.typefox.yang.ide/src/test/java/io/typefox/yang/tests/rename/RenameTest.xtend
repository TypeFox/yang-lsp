package io.typefox.yang.tests.rename

import io.typefox.yang.tests.AbstractYangLSPTest
import org.eclipse.lsp4j.Position
import org.eclipse.lsp4j.RenameParams
import org.eclipse.lsp4j.TextDocumentIdentifier
import org.junit.Test
import org.junit.Ignore

/**
 * @author koehnlein - Initial contribution and API
 */
class RenameTest extends AbstractYangLSPTest {
	
	@Test
	@Ignore('FIXME: Empty region returned')
	def void testRenameInput() {
		val model = '''
			module inputaugment {
			    namespace "foo:inputaugment";
			    prefix "ia";
			    rpc foo {
			        input {
			            container param {
			            }
			        }
			    }
			}
		'''
        val file = 'inputaugment.yang'.writeFile(model)
        initialize
        val line = 5
        val column = '            container '.length
        val params = new RenameParams(new TextDocumentIdentifier(file), new Position(line, column), 'bar')
        val workspaceEdit = languageServer.rename(params).get
        assertEquals('''
			changes :
			    inputaugment.yang : bar [[«line», «column»] .. [«line», «column + 5»]]
			documentChanges : 
		     '''.toString, toExpectation(workspaceEdit))
	}
	
	@Test
	@Ignore('FIXME: ClassCastException thrown')
	def void testRenameInputAugment() {
		val model = '''
			module inputaugment {
			    namespace "foo:inputaugment";
			    prefix "ia";
			    augment "/foo/input/param" {
			        leaf l {
			            type string;
			        }
			    }
			    rpc foo {
			        input {
			            container param {
			            }
			        }
			    }
			}
		'''
        val file = 'inputaugment.yang'.writeFile(model)
        initialize
        val line = 10
        val column = '            container '.length
        val refColumn = '    augment "/foo/input/'.length
        val params = new RenameParams(new TextDocumentIdentifier(file), new Position(line, column), 'bar')
        val workspaceEdit = languageServer.rename(params).get
        assertEquals('''
			changes :
			    inputaugment.yang : bar [[3, «refColumn»] .. [3, «refColumn + 5»]]
			    inputaugment.yang : bar [[«line», «column»] .. [«line», «column + 5»]]
			documentChanges : 
		     '''.toString, toExpectation(workspaceEdit))
	}
	
	
}
