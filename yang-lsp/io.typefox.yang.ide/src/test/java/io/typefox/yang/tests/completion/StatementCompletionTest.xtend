package io.typefox.yang.tests.completion

import com.google.common.base.Splitter
import io.typefox.yang.tests.AbstractYangLSPTest
import java.util.Date
import org.eclipse.xtext.ide.server.Document
import org.eclipse.xtext.testing.TestCompletionConfiguration
import org.junit.Test

import static io.typefox.yang.utils.YangDateUtils.getRevisionDateFormat

class StatementCompletionTest extends AbstractYangLSPTest {

	static val MODEL = '''
		module amodule {
		/*03*/
		  namespace "urn:test:amodule";
		/*04*/
		  prefix "amodule";
		/*05*/
		
		  organization "organização güi";
		/*06*/
		  contact "àéïç¢ô";
		/*07*/
		
		  grouping x {
		/*08*/
		    leaf y { type string; }
		/*09*/
		  }
		/*10*/
		
		  rpc run {
		    input { uses x; }
		/*11*/
		    output { uses x; }
		  }
		/*12*/
		  container amodule {
		/*13*/
		    choice z;
		  }
		
		  augment /amodule/z {
		/*14*/
		    container foo {
		/*15*/
		      leaf a {
		        type string;
		      }
		    }
		  }
		
		}
	'''

	@Test def void testStatement_01() {
		testCompletion [
			model = '''
			m'''
			line = 0
			column = 1
			expectedCompletionItems = '''
				module (Creates a new "module" statement.) -> module ${1:MyModel} {
				    yang-version 1.1;
				    namespace urn:ietf:params:xml:ns:yang:${1:MyModel};
				    prefix ${1:MyModel};
				
				    $0
				}
				 [[0, 0] .. [0, 1]]
			'''
		]
	}

	@Test def void testStatement_02() {
		testCompletion [
			model = '''
			mo'''
			line = 0
			column = 2
			expectedCompletionItems = '''
				module (Creates a new "module" statement.) -> module ${1:MyModel} {
				    yang-version 1.1;
				    namespace urn:ietf:params:xml:ns:yang:${1:MyModel};
				    prefix ${1:MyModel};
				
				    $0
				}
				 [[0, 0] .. [0, 2]]
			'''
		]
	}

	@Test def void testStatement_03() {
		testCompletion(MODEL.createConfiguration('/*03*/', [
			'''
				yang-version (Creates a new "yang-version" statement.) -> yang-version ${1:1.1};$0
				 [[1, 6] .. [1, 6]]
			'''
		]));
	}

	@Test def void testStatement_04() {
		testCompletion(MODEL.createConfiguration('/*04*/', [
			'''
				yang-version (Creates a new "yang-version" statement.) -> yang-version ${1:1.1};$0
				 [[3, 6] .. [3, 6]]
			'''
		]));
	}

	@Test def void testStatement_05() {
		val now = now;
		testCompletion(MODEL.createConfiguration('/*05*/', [
			'''
				description (Creates a new "description" statement.) -> description "${1:}";$0
				 [[5, 6] .. [5, 6]]
				import (Creates a new "import" statement.) -> import ${1:} {
				    prefix ${1:};
				    revision-date ${2:«now.get(0)»}-${3:«now.get(1)»}-${4:«now.get(2)»};
				}$0
				 [[5, 6] .. [5, 6]]
				include (Creates a new "include" statement.) -> include ${1:} {
				    revision-date ${2:«now.get(0)»}-${3:«now.get(1)»}-${4:«now.get(2)»};
				}$0
				 [[5, 6] .. [5, 6]]
				reference (Creates a new "reference" statement.) -> reference "${1:}";$0
				 [[5, 6] .. [5, 6]]
				yang-version (Creates a new "yang-version" statement.) -> yang-version ${1:1.1};$0
				 [[5, 6] .. [5, 6]]
			'''
		]));
	}

	@Test def void testStatement_06() {
		testCompletion(MODEL.createConfiguration('/*06*/', [
			'''
				description (Creates a new "description" statement.) -> description "${1:}";$0
				 [[8, 6] .. [8, 6]]
				reference (Creates a new "reference" statement.) -> reference "${1:}";$0
				 [[8, 6] .. [8, 6]]
			'''
		]));
	}

	@Test def void testStatement_07() {
		val now = now;
		testCompletion(MODEL.createConfiguration('/*07*/', [
			'''
				anyxml (Creates a new "anyxml" statement.) -> anyxml ${1:xml};$0
				 [[10, 6] .. [10, 6]]
				augment (Creates a new "augment" statement.) -> augment ${1:} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
				choice (Creates a new "choice" statement.) -> choice ${1:choice-name} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
				container (Creates a new "container" statement.) -> container ${1:container-name} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
				description (Creates a new "description" statement.) -> description "${1:}";$0
				 [[10, 6] .. [10, 6]]
				deviation (Creates a new "deviation" statement.) -> deviation ${1:node-identifier} {
				    deviate ${2:deviate-action} {
				        $3
				    }
				    $0
				}
				 [[10, 6] .. [10, 6]]
				extension (Creates a new "extension" statement.) -> extension ${1:extension-name} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
				feature (Creates a new "feature" statement.) -> feature ${1:feature-name} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
				grouping (Creates a new "grouping" statement.) -> grouping ${1:grouping-name} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
				identity (Creates a new "identity" statement.) -> identity ${1:identity-name} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
				leaf (Creates a new "leaf" statement.) -> leaf ${1:leaf-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[10, 6] .. [10, 6]]
				leaf-list (Creates a new "leaf-list" statement.) -> leaf-list ${1:leaf-list-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[10, 6] .. [10, 6]]
				list (Creates a new "list" statement.) -> list ${1:list-name} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
				notification (Creates a new "notification" statement.) -> notification ${1:action-name} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
				reference (Creates a new "reference" statement.) -> reference "${1:}";$0
				 [[10, 6] .. [10, 6]]
				revision (Creates a new "revision" statement.) -> revision ${1:«now.get(0)»}-${2:«now.get(1)»}-${3:«now.get(2)»} {
				    description "${4}";$0
				}
				 [[10, 6] .. [10, 6]]
				rpc (Creates a new "rpc" statement.) -> rpc ${1:rpc-name} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
				typedef (Creates a new "typedef" statement.) -> typedef ${1:type-name} {
				    type ${2:};$0
				}
				 [[10, 6] .. [10, 6]]
				uses (Creates a new "uses" statement.) -> uses ${1:group-name} {
				    $0
				}
				 [[10, 6] .. [10, 6]]
			'''
		]));
	}

	@Test def void testStatement_08() {
		testCompletion(MODEL.createConfiguration('/*08*/', [
			'''
				anyxml (Creates a new "anyxml" statement.) -> anyxml ${1:xml};$0
				 [[13, 6] .. [13, 6]]
				choice (Creates a new "choice" statement.) -> choice ${1:choice-name} {
				    $0
				}
				 [[13, 6] .. [13, 6]]
				container (Creates a new "container" statement.) -> container ${1:container-name} {
				    $0
				}
				 [[13, 6] .. [13, 6]]
				description (Creates a new "description" statement.) -> description "${1:}";$0
				 [[13, 6] .. [13, 6]]
				grouping (Creates a new "grouping" statement.) -> grouping ${1:grouping-name} {
				    $0
				}
				 [[13, 6] .. [13, 6]]
				leaf (Creates a new "leaf" statement.) -> leaf ${1:leaf-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[13, 6] .. [13, 6]]
				leaf-list (Creates a new "leaf-list" statement.) -> leaf-list ${1:leaf-list-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[13, 6] .. [13, 6]]
				list (Creates a new "list" statement.) -> list ${1:list-name} {
				    $0
				}
				 [[13, 6] .. [13, 6]]
				reference (Creates a new "reference" statement.) -> reference "${1:}";$0
				 [[13, 6] .. [13, 6]]
				status (Creates a new "status" statement.) -> status ${1:current};$0
				 [[13, 6] .. [13, 6]]
				typedef (Creates a new "typedef" statement.) -> typedef ${1:type-name} {
				    type ${2:};$0
				}
				 [[13, 6] .. [13, 6]]
				uses (Creates a new "uses" statement.) -> uses ${1:group-name} {
				    $0
				}
				 [[13, 6] .. [13, 6]]
			'''
		]));
	}

	@Test def void testStatement_09() {
		testCompletion(MODEL.createConfiguration('/*09*/', [
			'''
				anyxml (Creates a new "anyxml" statement.) -> anyxml ${1:xml};$0
				 [[15, 6] .. [15, 6]]
				choice (Creates a new "choice" statement.) -> choice ${1:choice-name} {
				    $0
				}
				 [[15, 6] .. [15, 6]]
				container (Creates a new "container" statement.) -> container ${1:container-name} {
				    $0
				}
				 [[15, 6] .. [15, 6]]
				description (Creates a new "description" statement.) -> description "${1:}";$0
				 [[15, 6] .. [15, 6]]
				grouping (Creates a new "grouping" statement.) -> grouping ${1:grouping-name} {
				    $0
				}
				 [[15, 6] .. [15, 6]]
				leaf (Creates a new "leaf" statement.) -> leaf ${1:leaf-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[15, 6] .. [15, 6]]
				leaf-list (Creates a new "leaf-list" statement.) -> leaf-list ${1:leaf-list-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[15, 6] .. [15, 6]]
				list (Creates a new "list" statement.) -> list ${1:list-name} {
				    $0
				}
				 [[15, 6] .. [15, 6]]
				reference (Creates a new "reference" statement.) -> reference "${1:}";$0
				 [[15, 6] .. [15, 6]]
				status (Creates a new "status" statement.) -> status ${1:current};$0
				 [[15, 6] .. [15, 6]]
				typedef (Creates a new "typedef" statement.) -> typedef ${1:type-name} {
				    type ${2:};$0
				}
				 [[15, 6] .. [15, 6]]
				uses (Creates a new "uses" statement.) -> uses ${1:group-name} {
				    $0
				}
				 [[15, 6] .. [15, 6]]
			'''
		]));
	}

	@Test def void testStatement_10() {
		testCompletion(MODEL.createConfiguration('/*10*/', [
			'''
				anyxml (Creates a new "anyxml" statement.) -> anyxml ${1:xml};$0
				 [[17, 6] .. [17, 6]]
				augment (Creates a new "augment" statement.) -> augment ${1:} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
				choice (Creates a new "choice" statement.) -> choice ${1:choice-name} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
				container (Creates a new "container" statement.) -> container ${1:container-name} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
				deviation (Creates a new "deviation" statement.) -> deviation ${1:node-identifier} {
				    deviate ${2:deviate-action} {
				        $3
				    }
				    $0
				}
				 [[17, 6] .. [17, 6]]
				extension (Creates a new "extension" statement.) -> extension ${1:extension-name} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
				feature (Creates a new "feature" statement.) -> feature ${1:feature-name} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
				grouping (Creates a new "grouping" statement.) -> grouping ${1:grouping-name} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
				identity (Creates a new "identity" statement.) -> identity ${1:identity-name} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
				leaf (Creates a new "leaf" statement.) -> leaf ${1:leaf-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[17, 6] .. [17, 6]]
				leaf-list (Creates a new "leaf-list" statement.) -> leaf-list ${1:leaf-list-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[17, 6] .. [17, 6]]
				list (Creates a new "list" statement.) -> list ${1:list-name} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
				notification (Creates a new "notification" statement.) -> notification ${1:action-name} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
				rpc (Creates a new "rpc" statement.) -> rpc ${1:rpc-name} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
				typedef (Creates a new "typedef" statement.) -> typedef ${1:type-name} {
				    type ${2:};$0
				}
				 [[17, 6] .. [17, 6]]
				uses (Creates a new "uses" statement.) -> uses ${1:group-name} {
				    $0
				}
				 [[17, 6] .. [17, 6]]
			'''
		]));
	}

	@Test def void testStatement_11() {
		testCompletion(MODEL.createConfiguration('/*11*/', [
			'''
				description (Creates a new "description" statement.) -> description "${1:}";$0
				 [[21, 6] .. [21, 6]]
				grouping (Creates a new "grouping" statement.) -> grouping ${1:grouping-name} {
				    $0
				}
				 [[21, 6] .. [21, 6]]
				if-feature (Creates a new "if-feature" statement.) -> if-feature ${1:}$2;$0
				 [[21, 6] .. [21, 6]]
				reference (Creates a new "reference" statement.) -> reference "${1:}";$0
				 [[21, 6] .. [21, 6]]
				status (Creates a new "status" statement.) -> status ${1:current};$0
				 [[21, 6] .. [21, 6]]
				typedef (Creates a new "typedef" statement.) -> typedef ${1:type-name} {
				    type ${2:};$0
				}
				 [[21, 6] .. [21, 6]]
			'''
		]));
	}

	@Test def void testStatement_12() {
		testCompletion(MODEL.createConfiguration('/*12*/', [
			'''
				anyxml (Creates a new "anyxml" statement.) -> anyxml ${1:xml};$0
				 [[24, 6] .. [24, 6]]
				augment (Creates a new "augment" statement.) -> augment ${1:} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
				choice (Creates a new "choice" statement.) -> choice ${1:choice-name} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
				container (Creates a new "container" statement.) -> container ${1:container-name} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
				deviation (Creates a new "deviation" statement.) -> deviation ${1:node-identifier} {
				    deviate ${2:deviate-action} {
				        $3
				    }
				    $0
				}
				 [[24, 6] .. [24, 6]]
				extension (Creates a new "extension" statement.) -> extension ${1:extension-name} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
				feature (Creates a new "feature" statement.) -> feature ${1:feature-name} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
				grouping (Creates a new "grouping" statement.) -> grouping ${1:grouping-name} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
				identity (Creates a new "identity" statement.) -> identity ${1:identity-name} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
				leaf (Creates a new "leaf" statement.) -> leaf ${1:leaf-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[24, 6] .. [24, 6]]
				leaf-list (Creates a new "leaf-list" statement.) -> leaf-list ${1:leaf-list-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[24, 6] .. [24, 6]]
				list (Creates a new "list" statement.) -> list ${1:list-name} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
				notification (Creates a new "notification" statement.) -> notification ${1:action-name} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
				rpc (Creates a new "rpc" statement.) -> rpc ${1:rpc-name} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
				typedef (Creates a new "typedef" statement.) -> typedef ${1:type-name} {
				    type ${2:};$0
				}
				 [[24, 6] .. [24, 6]]
				uses (Creates a new "uses" statement.) -> uses ${1:group-name} {
				    $0
				}
				 [[24, 6] .. [24, 6]]
			'''
		]));
	}

	@Test def void testStatement_13() {
		testCompletion(MODEL.createConfiguration('/*13*/', [
			'''
				anyxml (Creates a new "anyxml" statement.) -> anyxml ${1:xml};$0
				 [[26, 6] .. [26, 6]]
				choice (Creates a new "choice" statement.) -> choice ${1:choice-name} {
				    $0
				}
				 [[26, 6] .. [26, 6]]
				config (Creates a new "config" statement.) -> config ${1:false};$0
				 [[26, 6] .. [26, 6]]
				container (Creates a new "container" statement.) -> container ${1:container-name} {
				    $0
				}
				 [[26, 6] .. [26, 6]]
				description (Creates a new "description" statement.) -> description "${1:}";$0
				 [[26, 6] .. [26, 6]]
				grouping (Creates a new "grouping" statement.) -> grouping ${1:grouping-name} {
				    $0
				}
				 [[26, 6] .. [26, 6]]
				if-feature (Creates a new "if-feature" statement.) -> if-feature ${1:}$2;$0
				 [[26, 6] .. [26, 6]]
				leaf (Creates a new "leaf" statement.) -> leaf ${1:leaf-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[26, 6] .. [26, 6]]
				leaf-list (Creates a new "leaf-list" statement.) -> leaf-list ${1:leaf-list-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[26, 6] .. [26, 6]]
				list (Creates a new "list" statement.) -> list ${1:list-name} {
				    $0
				}
				 [[26, 6] .. [26, 6]]
				must (Creates a new "must" statement.) -> must "${1:expression}";$0
				 [[26, 6] .. [26, 6]]
				presence (Creates a new "presence" statement.) -> presence ${1:meaning};$0
				 [[26, 6] .. [26, 6]]
				reference (Creates a new "reference" statement.) -> reference "${1:}";$0
				 [[26, 6] .. [26, 6]]
				status (Creates a new "status" statement.) -> status ${1:current};$0
				 [[26, 6] .. [26, 6]]
				typedef (Creates a new "typedef" statement.) -> typedef ${1:type-name} {
				    type ${2:};$0
				}
				 [[26, 6] .. [26, 6]]
				uses (Creates a new "uses" statement.) -> uses ${1:group-name} {
				    $0
				}
				 [[26, 6] .. [26, 6]]
				when (Creates a new "when" statement.) -> when "${1:expression}";$0
				 [[26, 6] .. [26, 6]]
			'''
		]));
	}

	@Test def void testStatement_14() {
		testCompletion(MODEL.createConfiguration('/*14*/', [
			'''
				anyxml (Creates a new "anyxml" statement.) -> anyxml ${1:xml};$0
				 [[31, 6] .. [31, 6]]
				case (Creates a new "case" statement.) -> case ${1:case-name} {
				    $0
				}
				 [[31, 6] .. [31, 6]]
				choice (Creates a new "choice" statement.) -> choice ${1:choice-name} {
				    $0
				}
				 [[31, 6] .. [31, 6]]
				container (Creates a new "container" statement.) -> container ${1:container-name} {
				    $0
				}
				 [[31, 6] .. [31, 6]]
				description (Creates a new "description" statement.) -> description "${1:}";$0
				 [[31, 6] .. [31, 6]]
				if-feature (Creates a new "if-feature" statement.) -> if-feature ${1:}$2;$0
				 [[31, 6] .. [31, 6]]
				leaf (Creates a new "leaf" statement.) -> leaf ${1:leaf-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[31, 6] .. [31, 6]]
				leaf-list (Creates a new "leaf-list" statement.) -> leaf-list ${1:leaf-list-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[31, 6] .. [31, 6]]
				list (Creates a new "list" statement.) -> list ${1:list-name} {
				    $0
				}
				 [[31, 6] .. [31, 6]]
				reference (Creates a new "reference" statement.) -> reference "${1:}";$0
				 [[31, 6] .. [31, 6]]
				status (Creates a new "status" statement.) -> status ${1:current};$0
				 [[31, 6] .. [31, 6]]
				uses (Creates a new "uses" statement.) -> uses ${1:group-name} {
				    $0
				}
				 [[31, 6] .. [31, 6]]
				when (Creates a new "when" statement.) -> when "${1:expression}";$0
				 [[31, 6] .. [31, 6]]
			'''
		]));
	}

	@Test def void testStatement_15() {
		testCompletion(MODEL.createConfiguration('/*15*/', [
			'''
				anyxml (Creates a new "anyxml" statement.) -> anyxml ${1:xml};$0
				 [[33, 6] .. [33, 6]]
				choice (Creates a new "choice" statement.) -> choice ${1:choice-name} {
				    $0
				}
				 [[33, 6] .. [33, 6]]
				config (Creates a new "config" statement.) -> config ${1:false};$0
				 [[33, 6] .. [33, 6]]
				container (Creates a new "container" statement.) -> container ${1:container-name} {
				    $0
				}
				 [[33, 6] .. [33, 6]]
				description (Creates a new "description" statement.) -> description "${1:}";$0
				 [[33, 6] .. [33, 6]]
				grouping (Creates a new "grouping" statement.) -> grouping ${1:grouping-name} {
				    $0
				}
				 [[33, 6] .. [33, 6]]
				if-feature (Creates a new "if-feature" statement.) -> if-feature ${1:}$2;$0
				 [[33, 6] .. [33, 6]]
				leaf (Creates a new "leaf" statement.) -> leaf ${1:leaf-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[33, 6] .. [33, 6]]
				leaf-list (Creates a new "leaf-list" statement.) -> leaf-list ${1:leaf-list-name} {
				    type ${2:type-name} {
				        $0
				    }
				}
				 [[33, 6] .. [33, 6]]
				list (Creates a new "list" statement.) -> list ${1:list-name} {
				    $0
				}
				 [[33, 6] .. [33, 6]]
				must (Creates a new "must" statement.) -> must "${1:expression}";$0
				 [[33, 6] .. [33, 6]]
				presence (Creates a new "presence" statement.) -> presence ${1:meaning};$0
				 [[33, 6] .. [33, 6]]
				reference (Creates a new "reference" statement.) -> reference "${1:}";$0
				 [[33, 6] .. [33, 6]]
				status (Creates a new "status" statement.) -> status ${1:current};$0
				 [[33, 6] .. [33, 6]]
				typedef (Creates a new "typedef" statement.) -> typedef ${1:type-name} {
				    type ${2:};$0
				}
				 [[33, 6] .. [33, 6]]
				uses (Creates a new "uses" statement.) -> uses ${1:group-name} {
				    $0
				}
				 [[33, 6] .. [33, 6]]
				when (Creates a new "when" statement.) -> when "${1:expression}";$0
				 [[33, 6] .. [33, 6]]
			'''
		]));
	}

	private def testCompletion(TestCompletionConfiguration config) {
		testCompletion[
			model = config.model;
			line = config.line;
			column = config.column;
			expectedCompletionItems = config.expectedCompletionItems;
		];
	}

	private def createConfiguration(String content, String searchTerm, ()=>CharSequence expected) {
		val indexOf = content.indexOf(searchTerm);
		if (indexOf < 0) {
			throw new IllegalArgumentException('''Search term: '«searchTerm»' does not exist in the content: «content».''');
		}
		val offset = indexOf + searchTerm.length;
		val doc = new Document(0, content);
		val position = doc.getPosition(offset);
		return new TestCompletionConfiguration() => [
			model = doc.contents
			line = position.line
			column = position.character
			expectedCompletionItems = expected.apply().toString
		];
	}
	
	private def getNow() {
		Splitter.on('-').trimResults.splitToList(revisionDateFormat.format(new Date()));
	}

}
