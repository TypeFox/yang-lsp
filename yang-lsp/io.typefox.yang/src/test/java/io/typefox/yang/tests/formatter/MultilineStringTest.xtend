package io.typefox.yang.tests.formatter

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Ignore
import org.junit.Test
import io.typefox.yang.formatting2.YangFormatter

class MultilineStringTest extends AbstractYangTest {
    
    static def wrapInModule(CharSequence s) '''
    module m1 {
      module m2 {
        «s»
      }
    }
    '''
    
    @Test
    def void test_indentation_1() {
        assertFormattedWithoutSerialization[
            expectation = '''
              description
                "This revision adds the following new data types:
                 Foo
                ";
            '''.wrapInModule
            toBeFormatted = '''
                    description "This revision adds the following new data types:
               Foo
                            ";
            '''.wrapInModule
        ]
    }
    
    @Test
    def void test_indentation_2() {
        assertFormattedWithoutSerialization[
            expectation = '''
              description
                "This revision adds the following new data types:
                 - yang-identifier
                 - hex-string
                 - uuid
                 - dotted-quad
                ";
            '''.wrapInModule
            toBeFormatted = '''
                description "This revision adds the following new data types:
                         - yang-identifier
                      - hex-string
                         - uuid
                            - dotted-quad
                        ";
            '''.wrapInModule
        ]
    }
    
    @Test
    def void test_indentation_3() {
        assertFormattedWithoutSerialization[
            expectation = '''
              pattern
                '$0$.*'
                // comment
              + '|$1$[a-zA-Z0-9./]{1,8}$[a-zA-Z0-9./]{22}'
              + '|$5$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{43}'
              + /* comment */ '|$6$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{86}';
            '''.wrapInModule
            toBeFormatted = '''
                pattern '$0$.*'
                 // comment
                      + '|$1$[a-zA-Z0-9./]{1,8}$[a-zA-Z0-9./]{22}'
                   + '|$5$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{43}'
                 + /* comment */ '|$6$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{86}';
            '''.wrapInModule
        ]
    }

    @Test
    def void test_indentation_4() {
        assertFormattedWithoutSerialization[
            toBeFormatted = '''
              pattern
                '$0$.*'
              + '$0$.*'
                // comment
              + '|$1$[a-zA-Z0-9./]{1,8}$[a-zA-Z0-9./]{22}'
              + '|$5$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{43}'
              + /* comment */ '|$6$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{86}';
            '''.wrapInModule
        ]
    }

    @Test
    def void test_indentation_5() {
        assertFormattedWithoutSerialization[
            toBeFormatted = '''
                contact
                  "WG Web:   <http://tools.ietf.org/wg/netmod/>
                   WG List:  <mailto:netmod@ietf.org>
                
                   WG Chair: David Kessens
                             <mailto:david.kessens@nsn.com>
                
                   WG Chair: Juergen Schoenwaelder
                             <mailto:j.schoenwaelder@jacobs-university.de>
                
                   Editor:   Juergen Schoenwaelder
                             <mailto:j.schoenwaelder@jacobs-university.de>
                  ";
            '''.wrapInModule
        ]
    }
    
    @Test
    def void test_indentation_6() {
        assertFormattedWithoutSerialization[
            expectation = '''
            contact
              "WG Web:   <http://tools.ietf.org/wg/netmod/>
               WG List:  <mailto:netmod@ietf.org>
            
               WG Chair: David Kessens
                         <mailto:david.kessens@nsn.com>
            
               WG Chair: Juergen Schoenwaelder
                         <mailto:j.schoenwaelder@jacobs-university.de>
            
               Editor:   Juergen Schoenwaelder
                         <mailto:j.schoenwaelder@jacobs-university.de>
              ";
            '''.wrapInModule
            toBeFormatted = '''
            contact
                  "WG Web:   <http://tools.ietf.org/wg/netmod/>
                   WG List:  <mailto:netmod@ietf.org>
                
                   WG Chair: David Kessens
                             <mailto:david.kessens@nsn.com>
                
                   WG Chair: Juergen Schoenwaelder
                             <mailto:j.schoenwaelder@jacobs-university.de>
                
                   Editor:   Juergen Schoenwaelder
                             <mailto:j.schoenwaelder@jacobs-university.de>
                  ";
            '''.wrapInModule
        ]
    }
    
    @Test
    @Ignore
    def void test_line_break_indentation() {
        assertFormattedWithoutSerialization[
            preferences[
                put(YangFormatter.MAX_LINE_LENGTH, "73")
            ]
            expectation = '''
            contact
              "Foo:     bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar
                        bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar
                        xyz
              ";
            '''.wrapInModule
            toBeFormatted = '''
            contact
              "Foo:     bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar
                        xyz
              ";
            '''.wrapInModule
        ]
    }
    
    @Test
    def void test_option_forceNewLine_off() {
        assertFormattedWithoutSerialization[
            preferences[
                put(YangFormatter.FORCE_NEW_LINE, "false")
            ]
            expectation = '''
            contact "xyz";
            '''.wrapInModule
            toBeFormatted = '''
            contact "xyz";
            '''.wrapInModule
        ]
    }

    @Test
    def void test_option_forceNewLine_on() {
        assertFormattedWithoutSerialization[
            preferences[
                put(YangFormatter.FORCE_NEW_LINE, "true")
            ]
            expectation = '''
            contact
              "xyz";
            '''.wrapInModule
            toBeFormatted = '''
            contact "xyz";
            '''.wrapInModule
        ]
    }
    
}