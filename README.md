# yang-lsp
[![GH Build Status](https://github.com/theia-ide/yang-lsp/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/theia-ide/yang-lsp/actions/workflows/main.yml)
[![Build status](https://ci.appveyor.com/api/projects/status/96eo9k5yo0wtpj50/branch/master?svg=true)](https://ci.appveyor.com/project/kittaakos/yang-lsp/branch/master)

A language server for YANG (see [Language Server Protocol](https://github.com/Microsoft/language-server-protocol)).

## Usage

The language server application is available in two distributions:

 - `yang-language-server_<version>.zip` (plain language server)
 - `yang-language-server_diagram-extension_<version>.zip` (language server with diagram extension for [sprotty](https://github.com/theia-ide/sprotty))

Both variants include start scripts to launch the background process. Connect its input/output streams to your host application in order to communicate with the language server.

The YANG Language Server is currently being used in
 - [YANGSTER](https://github.com/theia-ide/yangster) based on [Theia](https://github.com/theia-ide/theia) (incl. diagram extension)
 - [Yang VS Code](https://github.com/theia-ide/yang-vscode) available on the [VS Marketplace](https://marketplace.visualstudio.com/items?itemName=typefox.yang-vscode)
 - [Yang Eclipse](https://github.com/theia-ide/yang-eclipse)

## Build

    git clone https://github.com/theia-ide/yang-lsp.git \
    && cd yang-lsp/yang-lsp \
    && ./gradlew build


# Release Engineering

The yang-lsp is the base of multiple binaries 


| Repository | Client | Binary | Bin Repo | CI  | Trigger |
| ---------- | ------ | ------ | -------- | --- | ---------- |
| [yang-lsp](https://github.com/theia-ide/yangs-lsp) | LSP           | JAR + script | GH Action Artifacts | [GH Action](https://github.com/theia-ide/yang-lsp/actions/workflows/main.yml) | GH Commit / PR | 
| [yangster](https://github.com/theia-ide/yangster)  | Theia Browser | Docker image | Docker Hub | [Docker Hub](https://hub.docker.com/r/typefox/yangster/builds) | GitHub hook / Jenkins pipeline| 
|                                                    | Theia          | Theia extension| npm |  [Jenkins](http://services.typefox.io/open-source/jenkins/job/yangster/) | `yarn run publish` | 
| [yangster-electron](https://github.com/theia-ide/yangster-electron) | Theia Electron | executables | ? | ? | ? |
| [yang-eclipse](https://github.com/theia-ide/yang-eclipse) | Eclipse | p2 update site | Eclipse Marketplace | [Jenkins](http://services.typefox.io/open-source/jenkins/job/yang-eclipse/) | GitHub hook / Jenkins pipeline |
| [yang-vscode](https://github.com/theia-ide/yang-vscode) | VSCode | VSCode extension | VSCode Marketplace | - | `vsce` |

