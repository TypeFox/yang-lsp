package io.typefox.yang.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.formatter.FormatterTestHelper
import org.junit.Test

class YangFormatterTest extends AbstractYangTest {

	@Inject extension protected FormatterTestHelper

	@Test
	def void testFormatting_01() {
		assertFormatted[
			expectation = '''
				module mytestid {
				
				    yang-version 1.1;
				
				    yang-version 1.1;
				}
			'''
			toBeFormatted = '''
				module  mytestid  { yang-version   1.1 ; yang-version   1.1 ; }
			'''
		]
	}

    @Test
    def void testFormatting_02_multiline_string_replacement() {
        assertFormatted[
            expectation = '''
                module mytestid {
                
                    description
                        "35-columns------------------------ 35-columns------------------------
                         15-columns---- 35-columns------------------------
                         35-columns------------------------ 15-columns---- 15-columns----
                         35-columns------------------------
                        ";
                }
            '''
            toBeFormatted = '''
                module mytestid {
                    description "35-columns------------------------ 35-columns------------------------ 15-columns---- 35-columns------------------------ 35-columns------------------------ 15-columns---- 15-columns---- 35-columns------------------------";
                }
            '''
        ]
    }
    
    @Test
    def void testFormatting_03() {
        assertFormatted[
            expectation = '''
                module mytestid {
                
                    yang-version 1.1;
                
                    module mytestid {
                
                        yang-version 1.1;
                
                        yang-version 1.1;
                    }
                }
            '''
            toBeFormatted = '''
                module  mytestid  { yang-version   1.1 ; module  mytestid  { yang-version   1.1 ; yang-version   1.1 ; } }
            '''
        ]
    }
}
