package io.typefox.yang.tests.formatter

import io.typefox.yang.tests.AbstractYangTest
import org.junit.Test

class YangFormatterTest extends AbstractYangTest {

	@Test
	def void test_version() {
		assertFormattedWithoutSerialization[
			expectation = '''
				module mytestid {
				
				  yang-version 1.1;
				}
			'''
			toBeFormatted = '''
				module  mytestid  {
				
				
				
				yang-version 1.1;
				}
			'''
		]
	}

    @Test
    def void test_new_lines() {
        assertFormattedWithoutSerialization[
            expectation = '''
                module mytestid {
                  yang-version 1.1;
                  module mytestid {
                    yang-version 1.1;
                    yang-version 1.1;
                
                    yang-version 1.1;
                  }
                }
            '''
            toBeFormatted = '''
                module  mytestid  { yang-version   1.1 ; module  mytestid  { yang-version   1.1 ; yang-version   1.1 ; 
                
                
                yang-version 1.1;
                } }
            '''
        ]
    }
    
    @Test
    def void test_description() {
        assertFormattedWithoutSerialization[
            expectation = '''
                module ietf-inet-types {
                
                  namespace "urn:ietf:params:xml:ns:yang:ietf-inet-types";
                
                  prefix "inet";
                
                  description
                    "This module contains a collection of generally useful derived...";
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                
                  namespace "urn:ietf:params:xml:ns:yang:ietf-inet-types";
                  
                  prefix "inet";
                
                  description
                "This module contains a collection of generally useful derived...";
                }
            '''
        ]
    }
    
    @Test
    def void test_organization() {
        assertFormattedWithoutSerialization[
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
    def void test_namespace_and_prefix() {
        assertFormattedWithoutSerialization[
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
    def void test_contact() {
        assertFormattedWithoutSerialization[
            expectation = '''
                module ietf-inet-types {
                  contact
                    "WG Web:   <http://tools.ietf.org/wg/netmod/>";
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                  contact
                   "WG Web:   <http://tools.ietf.org/wg/netmod/>";
                }
            '''
        ]
    }
    
    @Test
    def void test_reference() {
        assertFormattedWithoutSerialization[
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
    def void test_revision() {
        assertFormattedWithoutSerialization[
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
    def void test_typedef() {
        assertFormattedWithoutSerialization[
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
    def void test_pattern() {
        assertFormattedWithoutSerialization[
            expectation = '''
                module ietf-inet-types {
                
                  typedef ipv6-address {
                    type string {
                      pattern 
                        '(([^:]+:){6}(([^:]+:[^:]+)|(.*\..*)))';
                    }
                  }
                }
            '''
            toBeFormatted = '''
                module ietf-inet-types {
                
                  typedef ipv6-address {
                    type string {
                      pattern '(([^:]+:){6}(([^:]+:[^:]+)|(.*\..*)))';
                    }
                  }
                }
            '''
        ]
    }

    @Test
    def void test_uses_augment() {
        assertFormattedWithoutSerialization[
            useSerializer = false
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
    
    @Test
    def void test_augment_path() {
        assertFormattedWithoutSerialization[
            expectation = '''
                module augtest {
                  namespace "ns";
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
                        augment "outer/inner" {
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
                  namespace "ns";
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
                        augment      " outer / inner "     {
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
    
    @Test
    def void test_indentation() {
        assertFormattedWithoutSerialization[
            expectation = '''
            submodule augment-sub1 {
              belongs-to augment-super {
                prefix "as";
              }
            
              include augment-sub0;
            
              augment "/interfaces" {
                list ifEntry {
                  key "ifIndex";
            
                  leaf ifIndex {
                    type int32;
                  }
                }
                leaf llm1 {
                  type string;
                  mandatory true;
                }
              }
            }
            '''
            toBeFormatted = '''
            submodule augment-sub1 {
              belongs-to augment-super {
                prefix "as";
              }
            
              include augment-sub0;
            
              augment "/interfaces" {
                list ifEntry {
                key "ifIndex";
            
                leaf ifIndex {
                  type int32;
                }
              }
                leaf llm1 {
                type string;
                mandatory true;
              }
              }
            }
            '''
        ]
    }
    
    @Test
    def void test_refinable() {
        assertFormattedWithoutSerialization[
            expectation = '''
            module foo {
              yang-version 1.1;
              namespace "foo:bar";
              prefix x;
            
              typedef foo {
                type int32 {
                  range "1..40 | 60..100";
                }
              }
              typedef foo2 {
                type foo {
                  range "4..20";
                }
              }
              typedef bar {
                type bar {
                  range 4..20;
                }
              }
            }
            '''
            toBeFormatted = '''
            module foo {
              yang-version 1.1;
              namespace "foo:bar";
              prefix x;
              
              typedef foo {
                type int32 {
                  range  "1..40 | 60..100" ;
                }
              } 
              typedef foo2 {
                type foo {
                  range  "4..20 " ;
                }
              }
              typedef bar {
                type bar {
                  range  4..20 ;
                }
              }
            }
            '''
        ]
    }
    
    @Test
    def void test_xpath() {
        assertFormattedWithoutSerialization[
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
                    augment "outer/inner" {
                      when "foo!=42";
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
                    augment "outer/inner" {
                      when   "foo!=42"  ;
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
