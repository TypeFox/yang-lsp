# yang-lsp

[![GH Build Status](https://github.com/TypeFox/yang-lsp/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/TypeFox/yang-lsp/actions/workflows/main.yml)
[![Build status](https://ci.appveyor.com/api/projects/status/96eo9k5yo0wtpj50/branch/master?svg=true)](https://ci.appveyor.com/project/kittaakos/yang-lsp/branch/master)

A language server for YANG (see [Language Server Protocol][lsp]).

## Usage

The language server application is available in two distributions:

- `yang-language-server_<version>.zip` (plain language server)
- `yang-language-server_diagram-extension_<version>.zip` (language server with
  diagram extension for [sprotty][sprotty])

Both variants include start scripts to launch the background process. Connect
its input/output streams to your host application in order to communicate with
the language server.

The YANG Language Server is currently being used in

- [YANGSTER][yangster] based on [Theia][theia] (incl. diagram extension)
- [YANG VS Code][yang-vscode] available on the [VS Marketplace][yang-vscode-vsm]
- [YANG Eclipse][yang-eclipse]

## Build

```shell
  git clone https://github.com/TypeFox/yang-lsp.git
  cd yang-lsp/yang-lsp
  ./gradlew build
```

## Release Engineering

The yang-lsp is the base of multiple binaries

| Repository                             | Client         | Binary           | Bin Repo            | CI                         | Trigger |
| -------------------------------------- | -------------- | ---------------- | ------------------- | -------------------------- | ------- |
| [yang-lsp][yang-lsp]                   | LSP            | JAR + script     | GH Action Artifacts | [GH Action][yang-lsp-ci]   | GH Commit / PR |
| [yangster][yangster]                   | Theia Browser  | Docker image     | Docker Hub          | [Docker Hub][yangster-ci]  | GitHub hook / Jenkins pipeline|
|                                        | Theia          | Theia extension  | npm                 | [Jenkins][yangster-ci2]    | `yarn run publish` |
| [yangster-electron][yangster-electron] | Theia Electron | executables      | ?                   | ?                          | ? |
| [yang-eclipse][yang-eclipse]           | Eclipse        | p2 update site   | Eclipse Marketplace | [Jenkins][yang-eclipse-ci] | GitHub hook / Jenkins pipeline |
| [yang-vscode][yang-vscode]             | VSCode         | VSCode extension | VSCode Marketplace  | -                          | `vsce`  |

[lsp]: https://github.com/Microsoft/language-server-protocol
[sprotty]: https://github.com/theia-ide/sprotty
[yang-lsp]: https://github.com/TypeFox/yang-lsp
[yang-lsp-ci]: https://github.com/TypeFox/yang-lsp/actions/workflows/main.yml
[theia]: https://github.com/theia-ide/theia
[yangster]: https://github.com/theia-ide/yangster
[yangster-ci]: https://hub.docker.com/r/typefox/yangster/builds
[yangster-ci2]: http://services.typefox.io/open-source/jenkins/job/yangster/
[yangster-electron]: https://github.com/theia-ide/yangster-electron
[yang-vscode]: https://github.com/TypeFox/yang-vscode
[yang-vscode-vsm]: https://marketplace.visualstudio.com/items?itemName=typefox.yang-vscode
[yang-eclipse]: https://github.com/theia-ide/yang-eclipse
[yang-eclipse-ci]: http://services.typefox.io/open-source/jenkins/job/yang-eclipse/
