package io.typefox.yang.tests.formatter

import io.typefox.yang.formatting2.YangFormatter
import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

class MultilineStringTest extends AbstractYangTest {
    
    static def String wrapUnformatted(CharSequence s) '''
    module m1 {
         module m2 {
            module m2 {
                «s»
              }
      }
    }
    '''
    
    static def String wrapFormatted(CharSequence s) '''
    module m1 {
      module m2 {
        module m2 {
          «s»
        }
      }
    }
    '''
    
    @Test
    def void test_SL_concatenation() {
        assertFormattedWithoutSerialization[
            preferences[put(YangFormatter.FORCE_NEW_LINE, false)]
            expectation = '''
            description "foo" /* a */ /* b */ + "bar";
            '''.wrapFormatted
            toBeFormatted = '''
            description "foo"/* a *//* b */    +      "bar";
            '''.wrapUnformatted
        ]
    }
    
    @Test
    def void test_indentation_1a() {
        assertFormattedWithoutSerialization[
            preferences[put(YangFormatter.FORCE_NEW_LINE, true)] // default
            expectation = '''
            description
              "foo"
            + "bar";
            '''.wrapFormatted
            toBeFormatted = '''
            description "foo"
                 + "bar";
            '''.wrapUnformatted
        ]
    }
    
    @Test
    def void test_indentation_1b() {
        assertFormattedWithoutSerialization[
            preferences[put(YangFormatter.FORCE_NEW_LINE, false)]
            expectation = '''
               description "foo"
                         + "bar";
            '''.wrapFormatted
            toBeFormatted = '''
                    description "foo"
               + "bar";
            '''.wrapUnformatted
        ]
    }
    
    @Test
    def void test_indentation_2() {
        assertFormattedWithoutSerialization[
            preferences[put(YangFormatter.FORCE_NEW_LINE, false)]
            toBeFormatted = '''
               description "foo"
                         + "bar";
            '''.wrapFormatted
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
            '''.wrapFormatted
            toBeFormatted = '''
                pattern '$0$.*'
                 // comment
                      + '|$1$[a-zA-Z0-9./]{1,8}$[a-zA-Z0-9./]{22}'
                   + '|$5$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{43}'
                 + /* comment */ '|$6$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{86}';
            '''.wrapUnformatted
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
            '''.wrapFormatted
        ]
    }
    
    @Test
    def void test_indentation_5() {
        assertFormattedWithoutSerialization[
            expectation = '''
              pattern
                '$0$.*'
                /* comment
                 * foo
                 */
              + '|$1$[a-zA-Z0-9./]{1,8}$[a-zA-Z0-9./]{22}'
              + '|$5$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{43}'
              + /* comment */ '|$6$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{86}';
            '''.wrapFormatted
            toBeFormatted = '''
                pattern '$0$.*'
                                 /* comment
                              * foo
                  */
                      + '|$1$[a-zA-Z0-9./]{1,8}$[a-zA-Z0-9./]{22}'
                   + '|$5$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{43}'
                 + /* comment */ '|$6$(rounds=\d+$)?[a-zA-Z0-9./]{1,16}$[a-zA-Z0-9./]{86}';
            '''.wrapUnformatted
        ]
    }
    
    @Test
    def void test_ML_indentation_1() {
        assertFormattedWithoutSerialization[
            expectation = '''
              description
                "This revision adds the following new data types:
                 Foo
                ";
            '''.wrapFormatted
            toBeFormatted = '''
                    description "This revision adds the following new data types:
               Foo
                            ";
            '''.wrapUnformatted
        ]
    }
    
    @Test
    def void test_ML_indentation_2() {
        assertFormattedWithoutSerialization[
            preferences[put(YangFormatter.FORCE_NEW_LINE, false)]
            expectation = '''
               description "This revision adds the following new data types: "
                         + "foo
                            bar";
            '''.wrapFormatted
            toBeFormatted = '''
                    description "This revision adds the following new data types: "
               + "foo
               bar";
            '''.wrapUnformatted
        ]
    }    
    
    @Test
    def void test_ML_indentation_3() {
        assertFormattedWithoutSerialization[
            expectation = '''
              description
                "This revision adds the following new data types:
                 - yang-identifier
                 - hex-string
                 - uuid
                 - dotted-quad
                ";
            '''.wrapFormatted
            toBeFormatted = '''
                description "This revision adds the following new data types:
                      - yang-identifier
                      - hex-string
                      - uuid
                      - dotted-quad
                        ";
            '''.wrapUnformatted
        ]
    }
    
    @Test
    def void test_ML_indentation_4() {
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
            '''.wrapFormatted
        ]
    }
    
    @Test
    def void test_ML_indentation_5() {
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
            '''.wrapFormatted
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
            '''.wrapUnformatted
        ]
    }
    
    @Test
    def void test_ML_indentation_6() {
        assertFormattedWithoutSerialization[
            expectation = '''
              description
                "Foo
                ";
            '''.wrapFormatted
            toBeFormatted = '''
                description "Foo
                    ";
            '''.wrapUnformatted
        ]
    }
    
    @Test
    def void test_ML_indentation_7() {
        assertFormattedWithoutSerialization[
            expectation = '''
              description
                'foo
                  bar
                ';
            '''.wrapFormatted
            toBeFormatted = '''
                description
                  'foo
                    bar
                    ';
            '''.wrapUnformatted
        ]
    }
    
    @Test
    def void test_ML_indentation_8() {
        assertFormattedWithoutSerialization[
            toBeFormatted = '''
            contact
              "WG Chair: David Kessens
                         <mailto:david.kessens@nsn.com>";
            '''.wrapFormatted
        ]
    }
    
    @Test
    def void test_ML_indentation_9() {
        assertFormattedWithoutSerialization[
            preferences[
                put(YangFormatter.FORCE_NEW_LINE, "false")
            ]
            toBeFormatted = '''
            contact "WG Chair: David Kessens
                               <mailto:david.kessens@nsn.com>";
            '''.wrapFormatted
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
            '''.wrapFormatted
            toBeFormatted = '''
            contact "xyz";
            '''.wrapUnformatted
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
            '''.wrapFormatted
            toBeFormatted = '''
            contact "xyz";
            '''.wrapUnformatted
        ]
    }
    
}