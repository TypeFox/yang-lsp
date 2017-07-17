package io.typefox.yang.tests.completion

import io.typefox.yang.tests.AbstractYangLSPTest
import org.eclipse.xtext.ide.server.Document
import org.eclipse.xtext.testing.TestCompletionConfiguration
import org.junit.Test

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
				module -> module [[0, 0] .. [0, 1]]
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
				module -> module [[0, 0] .. [0, 2]]
			'''
		]
	}

	@Test def void testStatement_03() {
		testCompletion(MODEL.createConfiguration('/*03*/', [
			'''
				yang-version -> yang-version [[1, 6] .. [1, 6]]
			'''
		]));
	}

	@Test def void testStatement_04() {
		testCompletion(MODEL.createConfiguration('/*04*/', [
			'''
				yang-version -> yang-version [[3, 6] .. [3, 6]]
			'''
		]));
	}

	@Test def void testStatement_05() {
		testCompletion(MODEL.createConfiguration('/*05*/', [
			'''
				description -> description [[5, 6] .. [5, 6]]
				import -> import [[5, 6] .. [5, 6]]
				include -> include [[5, 6] .. [5, 6]]
				reference -> reference [[5, 6] .. [5, 6]]
				yang-version -> yang-version [[5, 6] .. [5, 6]]
			'''
		]));
	}

	@Test def void testStatement_06() {
		testCompletion(MODEL.createConfiguration('/*06*/', [
			'''
				description -> description [[8, 6] .. [8, 6]]
				reference -> reference [[8, 6] .. [8, 6]]
			'''
		]));
	}

	@Test def void testStatement_07() {
		testCompletion(MODEL.createConfiguration('/*07*/', [
			'''
				anyxml -> anyxml [[10, 6] .. [10, 6]]
				augment -> augment [[10, 6] .. [10, 6]]
				choice -> choice [[10, 6] .. [10, 6]]
				container -> container [[10, 6] .. [10, 6]]
				description -> description [[10, 6] .. [10, 6]]
				deviation -> deviation [[10, 6] .. [10, 6]]
				extension -> extension [[10, 6] .. [10, 6]]
				feature -> feature [[10, 6] .. [10, 6]]
				grouping -> grouping [[10, 6] .. [10, 6]]
				identity -> identity [[10, 6] .. [10, 6]]
				leaf -> leaf [[10, 6] .. [10, 6]]
				leaf-list -> leaf-list [[10, 6] .. [10, 6]]
				list -> list [[10, 6] .. [10, 6]]
				notification -> notification [[10, 6] .. [10, 6]]
				reference -> reference [[10, 6] .. [10, 6]]
				revision -> revision [[10, 6] .. [10, 6]]
				rpc -> rpc [[10, 6] .. [10, 6]]
				typedef -> typedef [[10, 6] .. [10, 6]]
				uses -> uses [[10, 6] .. [10, 6]]
			'''
		]));
	}

	@Test def void testStatement_08() {
		testCompletion(MODEL.createConfiguration('/*08*/', [
			'''
				anyxml -> anyxml [[13, 6] .. [13, 6]]
				choice -> choice [[13, 6] .. [13, 6]]
				container -> container [[13, 6] .. [13, 6]]
				description -> description [[13, 6] .. [13, 6]]
				grouping -> grouping [[13, 6] .. [13, 6]]
				leaf -> leaf [[13, 6] .. [13, 6]]
				leaf-list -> leaf-list [[13, 6] .. [13, 6]]
				list -> list [[13, 6] .. [13, 6]]
				reference -> reference [[13, 6] .. [13, 6]]
				status -> status [[13, 6] .. [13, 6]]
				typedef -> typedef [[13, 6] .. [13, 6]]
				uses -> uses [[13, 6] .. [13, 6]]
			'''
		]));
	}

	@Test def void testStatement_09() {
		testCompletion(MODEL.createConfiguration('/*09*/', [
			'''
				anyxml -> anyxml [[15, 6] .. [15, 6]]
				choice -> choice [[15, 6] .. [15, 6]]
				container -> container [[15, 6] .. [15, 6]]
				description -> description [[15, 6] .. [15, 6]]
				grouping -> grouping [[15, 6] .. [15, 6]]
				leaf -> leaf [[15, 6] .. [15, 6]]
				leaf-list -> leaf-list [[15, 6] .. [15, 6]]
				list -> list [[15, 6] .. [15, 6]]
				reference -> reference [[15, 6] .. [15, 6]]
				status -> status [[15, 6] .. [15, 6]]
				typedef -> typedef [[15, 6] .. [15, 6]]
				uses -> uses [[15, 6] .. [15, 6]]
			'''
		]));
	}

	@Test def void testStatement_10() {
		testCompletion(MODEL.createConfiguration('/*10*/', [
			'''
				anyxml -> anyxml [[17, 6] .. [17, 6]]
				augment -> augment [[17, 6] .. [17, 6]]
				choice -> choice [[17, 6] .. [17, 6]]
				container -> container [[17, 6] .. [17, 6]]
				deviation -> deviation [[17, 6] .. [17, 6]]
				extension -> extension [[17, 6] .. [17, 6]]
				feature -> feature [[17, 6] .. [17, 6]]
				grouping -> grouping [[17, 6] .. [17, 6]]
				identity -> identity [[17, 6] .. [17, 6]]
				leaf -> leaf [[17, 6] .. [17, 6]]
				leaf-list -> leaf-list [[17, 6] .. [17, 6]]
				list -> list [[17, 6] .. [17, 6]]
				notification -> notification [[17, 6] .. [17, 6]]
				rpc -> rpc [[17, 6] .. [17, 6]]
				typedef -> typedef [[17, 6] .. [17, 6]]
				uses -> uses [[17, 6] .. [17, 6]]
			'''
		]));
	}

	@Test def void testStatement_11() {
		testCompletion(MODEL.createConfiguration('/*11*/', [
			'''
				description -> description [[21, 6] .. [21, 6]]
				grouping -> grouping [[21, 6] .. [21, 6]]
				if-feature -> if-feature [[21, 6] .. [21, 6]]
				reference -> reference [[21, 6] .. [21, 6]]
				status -> status [[21, 6] .. [21, 6]]
				typedef -> typedef [[21, 6] .. [21, 6]]
			'''
		]));
	}

	@Test def void testStatement_12() {
		testCompletion(MODEL.createConfiguration('/*12*/', [
			'''
				anyxml -> anyxml [[24, 6] .. [24, 6]]
				augment -> augment [[24, 6] .. [24, 6]]
				choice -> choice [[24, 6] .. [24, 6]]
				container -> container [[24, 6] .. [24, 6]]
				deviation -> deviation [[24, 6] .. [24, 6]]
				extension -> extension [[24, 6] .. [24, 6]]
				feature -> feature [[24, 6] .. [24, 6]]
				grouping -> grouping [[24, 6] .. [24, 6]]
				identity -> identity [[24, 6] .. [24, 6]]
				leaf -> leaf [[24, 6] .. [24, 6]]
				leaf-list -> leaf-list [[24, 6] .. [24, 6]]
				list -> list [[24, 6] .. [24, 6]]
				notification -> notification [[24, 6] .. [24, 6]]
				rpc -> rpc [[24, 6] .. [24, 6]]
				typedef -> typedef [[24, 6] .. [24, 6]]
				uses -> uses [[24, 6] .. [24, 6]]
			'''
		]));
	}

	@Test def void testStatement_13() {
		testCompletion(MODEL.createConfiguration('/*13*/', [
			'''
				anyxml -> anyxml [[26, 6] .. [26, 6]]
				choice -> choice [[26, 6] .. [26, 6]]
				config -> config [[26, 6] .. [26, 6]]
				container -> container [[26, 6] .. [26, 6]]
				description -> description [[26, 6] .. [26, 6]]
				grouping -> grouping [[26, 6] .. [26, 6]]
				if-feature -> if-feature [[26, 6] .. [26, 6]]
				leaf -> leaf [[26, 6] .. [26, 6]]
				leaf-list -> leaf-list [[26, 6] .. [26, 6]]
				list -> list [[26, 6] .. [26, 6]]
				must -> must [[26, 6] .. [26, 6]]
				presence -> presence [[26, 6] .. [26, 6]]
				reference -> reference [[26, 6] .. [26, 6]]
				status -> status [[26, 6] .. [26, 6]]
				typedef -> typedef [[26, 6] .. [26, 6]]
				uses -> uses [[26, 6] .. [26, 6]]
				when -> when [[26, 6] .. [26, 6]]
			'''
		]));
	}

	@Test def void testStatement_14() {
		testCompletion(MODEL.createConfiguration('/*14*/', [
			'''
				anyxml -> anyxml [[31, 6] .. [31, 6]]
				case -> case [[31, 6] .. [31, 6]]
				choice -> choice [[31, 6] .. [31, 6]]
				container -> container [[31, 6] .. [31, 6]]
				description -> description [[31, 6] .. [31, 6]]
				if-feature -> if-feature [[31, 6] .. [31, 6]]
				leaf -> leaf [[31, 6] .. [31, 6]]
				leaf-list -> leaf-list [[31, 6] .. [31, 6]]
				list -> list [[31, 6] .. [31, 6]]
				reference -> reference [[31, 6] .. [31, 6]]
				status -> status [[31, 6] .. [31, 6]]
				uses -> uses [[31, 6] .. [31, 6]]
				when -> when [[31, 6] .. [31, 6]]
			'''
		]));
	}

	@Test def void testStatement_15() {
		testCompletion(MODEL.createConfiguration('/*15*/', [
			'''
				anyxml -> anyxml [[33, 6] .. [33, 6]]
				choice -> choice [[33, 6] .. [33, 6]]
				config -> config [[33, 6] .. [33, 6]]
				container -> container [[33, 6] .. [33, 6]]
				description -> description [[33, 6] .. [33, 6]]
				grouping -> grouping [[33, 6] .. [33, 6]]
				if-feature -> if-feature [[33, 6] .. [33, 6]]
				leaf -> leaf [[33, 6] .. [33, 6]]
				leaf-list -> leaf-list [[33, 6] .. [33, 6]]
				list -> list [[33, 6] .. [33, 6]]
				must -> must [[33, 6] .. [33, 6]]
				presence -> presence [[33, 6] .. [33, 6]]
				reference -> reference [[33, 6] .. [33, 6]]
				status -> status [[33, 6] .. [33, 6]]
				typedef -> typedef [[33, 6] .. [33, 6]]
				uses -> uses [[33, 6] .. [33, 6]]
				when -> when [[33, 6] .. [33, 6]]
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

}
