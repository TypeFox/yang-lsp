# yang-lsp
[![Build Status](https://travis-ci.org/yang-tools/yang-lsp.svg?branch=master)](https://travis-ci.org/yang-tools/yang-lsp)
[![Build status](https://ci.appveyor.com/api/projects/status/96eo9k5yo0wtpj50/branch/master?svg=true)](https://ci.appveyor.com/project/kittaakos/yang-lsp/branch/master)

A language server for YANG (see [Language Server Protocol](https://github.com/Microsoft/language-server-protocol)).

## Usage

The language server application is available in two distributions:

 - `yang-language-server_<version>.zip` (plain language server)
 - `yang-language-server_diagram-extension_<version>.zip` (language server with diagram extension for [sprotty](https://github.com/theia-ide/sprotty))

Both variants include start scripts to launch the background process. Connect its input/output streams to your host application in order to communicate with the language server.

The YANG Language Server is currently being used in
 - [YANGSTER](https://github.com/yang-tools/yangster) based on [Theia](https://github.com/theia-ide/theia) (incl. diagram extension)
 - [Yang VS Code](https://github.com/yang-tools/yang-vscode) available on the [VS Marketplace](https://marketplace.visualstudio.com/items?itemName=typefox.yang-vscode)
 - [Yang Eclipse](https://github.com/yang-tools/yang-eclipse)

## Build

    git clone https://github.com/yang-tools/yang-lsp.git \
    && cd yang-lsp/yang-lsp \
    && ./gradlew build
