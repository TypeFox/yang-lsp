# yang-lsp
[![Build Status](https://travis-ci.org/yang-tools/yang-lsp.svg?branch=master)](https://travis-ci.org/yang-tools/yang-lsp)
[![Build status](https://ci.appveyor.com/api/projects/status/96eo9k5yo0wtpj50/branch/master?svg=true)](https://ci.appveyor.com/project/kittaakos/yang-lsp/branch/master)

A Language Server for YANG

## Build

    git clone https://github.com/TypeFox/yang-lsp.git \
    && cd yang-lsp/yang-lsp \
    && ./gradlew build

### Troubleshooting

One has to make sure that the [`xtext-jflex`] library is available from the local Maven repository before building the LS.

    git clone https://github.com/TypeFox/xtext-jflex.git \
    && cd xtext-jflex/jflex-fragment \
    && mvn clean install

[`xtext-jflex`]: https://github.com/TypeFox/xtext-jflex
