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
    def void testFormatting_03_singleline_description() {
        assertFormatted[
            expectation = '''
                module mytestid {
                
                  description
                    "35-columns------------------------ 15-columns----";
                }
            '''
            toBeFormatted = '''
                module mytestid {
                    description        "35-columns------------------------ 15-columns----";
                }
            '''
        ]
    }
    
    @Test
    def void testFormatting_04_additional_newlines_description() {
        assertFormatted[
            expectation = '''
                module mytestid {
                
                  description
                    "35-columns------------------------
                     
                     15-columns----
                    ";
                }
            '''
            toBeFormatted = '''
                module mytestid {
                    description        "35-columns------------------------
                    
                    15-columns----";
                }
            '''
        ]
    }
    
    @Test
    def void testFormatting_05_extra_long_line_description() {
        assertFormatted[
            expectation = '''
                module mytestid {
                
                  description
                    "35-columns------------------------
                     100-columns----------------------------------------------------------------------------------------
                     15-columns----
                    ";
                }
            '''
            toBeFormatted = '''
                module mytestid {
                    description        "35-columns------------------------ 100-columns----------------------------------------------------------------------------------------
                    15-columns----";
                }
            '''
        ]
    }
    
    @Test
    def void testFormatting_06() {
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
    
    @Test
    def void testFormatting_07() {
        assertFormatted[
            expectation = '''
                module ietf-inet-types {
                
                  namespace "urn:ietf:params:xml:ns:yang:ietf-inet-types";
                
                  prefix "inet";
                
                  description
                    "This module contains a collection of generally useful derived
                     YANG data types for Internet addresses and related things.
                     
                     Copyright (c) 2013 IETF Trust and the persons identified as
                     authors of the code.  All rights reserved.
                     
                     Redistribution and use in source and binary forms, with or
                     without modification, is permitted pursuant to, and subject
                     to the license terms contained in, the Simplified BSD License
                     set forth in Section 4.c of the IETF Trust's Legal Provisions
                     Relating to IETF Documents
                     (http://trustee.ietf.org/license-info).
                     
                     This version of this YANG module is part of RFC 6991; see
                     the RFC itself for full legal notices.
                    ";
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                
                  namespace "urn:ietf:params:xml:ns:yang:ietf-inet-types";
                  
                  prefix "inet";
                
                  description
                   "This module contains a collection of generally useful derived
                    YANG data types for Internet addresses and related things.
                
                    Copyright (c) 2013 IETF Trust and the persons identified as
                    authors of the code.  All rights reserved.
                
                    Redistribution and use in source and binary forms, with or
                    without modification, is permitted pursuant to, and subject
                    to the license terms contained in, the Simplified BSD License
                    set forth in Section 4.c of the IETF Trust's Legal Provisions
                    Relating to IETF Documents
                    (http://trustee.ietf.org/license-info).
                
                    This version of this YANG module is part of RFC 6991; see
                    the RFC itself for full legal notices.";
                }
            '''
        ]
    }
    
    @Test
    def void testFormatting_08_organization() {
        assertFormatted[
            expectation = '''
                module ietf-inet-types {
                
                  organization
                    "IETF NETMOD (NETCONF Data Modeling Language) Working Group";
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                  organization
                  "IETF NETMOD (NETCONF Data Modeling Language) Working Group";
                }
            '''
        ]
    }
    
    @Test
    def void testFormatting_09_namespace_prefix() {
        assertFormatted[
            expectation = '''
                module ietf-inet-types {
                
                  namespace "urn:ietf:params:xml:ns:yang:ietf-inet-types";
                
                  prefix "inet";
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                namespace    
                "urn:ietf:params:xml:ns:yang:ietf-inet-types";
                prefix       
                "inet";
                }
            '''
        ]
    }
    
    @Test
    def void testFormatting_10_contact() {
        assertFormatted[
            expectation = '''
                module ietf-inet-types {
                
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
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                  contact
                   "WG Web:   <http://tools.ietf.org/wg/netmod/>
                    WG List:  <mailto:netmod@ietf.org>
                
                    WG Chair: David Kessens
                              <mailto:david.kessens@nsn.com>
                
                    WG Chair: Juergen Schoenwaelder
                              <mailto:j.schoenwaelder@jacobs-university.de>
                
                    Editor:   Juergen Schoenwaelder
                              <mailto:j.schoenwaelder@jacobs-university.de>";
                }
            '''
        ]
    }
    
    @Test
    def void testFormatting_11_reference() {
        assertFormatted[
            expectation = '''
                module ietf-inet-types {
                
                  reference
                    "RFC 6021: Common YANG Data Types";
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                  reference                    "RFC 6021: Common YANG Data Types";
                }
            '''
        ]
    }
    
    @Test
    def void testFormatting_12_revision() {
        assertFormatted[
            expectation = '''
                module ietf-inet-types {
                
                  revision 2013-07-15 {
                
                    description
                      "This revision adds the following new data types:
                       - ip-address-no-zone
                       - ipv4-address-no-zone
                       - ipv6-address-no-zone
                      ";
                
                    reference
                      "RFC 6991: Common YANG Data Types";
                  }
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                
                    revision 
                    2013-07-15 {
                      description
                       "This revision adds the following new data types:
                        - ip-address-no-zone
                        - ipv4-address-no-zone
                        - ipv6-address-no-zone";
                      reference
                       "RFC 6991: Common YANG Data Types";
                    }
                }
            '''
        ]
    }
    
    @Test
    def void testFormatting_13_typedef() {
        assertFormatted[
            expectation = '''
                module ietf-inet-types {
                
                  typedef ip-version {
                
                    type enumeration {
                
                      enum unknown {
                        value "0";
                        description
                          "An unknown or unspecified version of the Internet
                           protocol.
                          ";
                      }
                
                      enum ipv4 {
                        value "1";
                        description
                          "The IPv4 protocol as defined in RFC 791.";
                      }
                
                      enum ipv6 {
                        value "2";
                        description
                          "The IPv6 protocol as defined in RFC 2460.";
                      }
                    }
                
                    description
                      "This value represents the version of the IP protocol.
                       
                       In the value set and its semantics, this type is equivalent
                       to the InetVersion textual convention of the SMIv2.
                      ";
                
                    reference
                      "RFC  791: Internet Protocol
                       RFC 2460: Internet Protocol, Version 6 (IPv6) Specification
                       RFC 4001: Textual Conventions for Internet Network Addresses
                      ";
                  }
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                
                      typedef ip-version {
                        type enumeration {
                          enum unknown {
                            value "0";
                            description
                             "An unknown or unspecified version of the Internet
                              protocol.";
                          }
                          enum ipv4 {
                            value "1";
                            description
                             "The IPv4 protocol as defined in RFC 791.";
                          }
                          enum ipv6 {
                            value "2";
                            description
                             "The IPv6 protocol as defined in RFC 2460.";
                          }
                        }
                        description
                         "This value represents the version of the IP protocol.
                    
                          In the value set and its semantics, this type is equivalent
                          to the InetVersion textual convention of the SMIv2.";
                        reference
                         "RFC  791: Internet Protocol
                          RFC 2460: Internet Protocol, Version 6 (IPv6) Specification
                          RFC 4001: Textual Conventions for Internet Network Addresses";
                      }
                }
            '''
        ]
    }

    @Test
    def void testFormatting_14_pattern() {
        assertFormatted[
            expectation = '''
                module ietf-inet-types {
                
                  typedef ipv6-address {
                
                    type string {
                
                      pattern '((:|[0-9a-fA-F]{0,4}):)([0-9a-fA-F]{0,4}:){0,5}'
                            + '((([0-9a-fA-F]{0,4}:)?(:|[0-9a-fA-F]{0,4}))|'
                            + '(((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}'
                            + '(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])))'
                            + '(%[\p{N}\p{L}]+)?';
                
                      pattern '(([^:]+:){6}(([^:]+:[^:]+)|(.*\..*)))|'
                            + '((([^:]+:)*[^:]+)?::(([^:]+:)*[^:]+)?)'
                            + '(%.+)?';
                    }
                  }
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                
                  typedef ipv6-address {
                    type string {
                      pattern '((:|[0-9a-fA-F]{0,4}):)([0-9a-fA-F]{0,4}:){0,5}'
                            + '((([0-9a-fA-F]{0,4}:)?(:|[0-9a-fA-F]{0,4}))|'
                            + '(((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}'
                            + '(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])))'
                            + '(%[\p{N}\p{L}]+)?';
                      pattern '(([^:]+:){6}(([^:]+:[^:]+)|(.*\..*)))|'
                            + '((([^:]+:)*[^:]+)?::(([^:]+:)*[^:]+)?)'
                            + '(%.+)?';
                    }
                  }
                }
            '''
        ]
    }

    @Test
    def void testFormatting_15_uses_augment() {
        assertFormatted[
            expectation = '''
                module augtest {
                
                  namespace "http://example.com/augtest";
                
                  prefix "at";
                
                  grouping foobar {
                
                    container outer {
                
                      container inner {
                
                        leaf foo {
                
                          type uint8;
                        }
                      }
                    }
                  }
                
                  rpc agoj {
                
                    input {
                
                      uses foobar {
                
                        augment outer/inner {
                
                          leaf bar {
                
                            type string;
                          }
                        }
                      }
                    }
                  }
                }
            '''
            toBeFormatted = '''
                module augtest {
                  namespace "http://example.com/augtest";
                  prefix "at";
                  grouping foobar {
                    container outer {
                      container inner {
                        leaf foo {
                          type uint8;
                        }
                      }
                    }
                  }
                  rpc agoj {
                    input {
                      uses foobar {
                        augment   outer / inner  {
                          leaf bar {
                            type string;
                          }
                        }
                      }
                    }
                  }
                }
            '''
        ]
    }
}
