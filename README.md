# yang-lsp
A Language Server for YANG

## Build

    git clone https://github.com/TypeFox/yang-lsp.git \
    && cd yang-lsp/io.typefox.yang.parent \
    && ./gradlew build

### Troubleshooting

One has to make sure that the [`xtext-jflex`] library is available from the local Maven repository before building the LS.

    git clone https://github.com/TypeFox/xtext-jflex.git \
    && cd xtext-jflex/jflex-fragment \
    && mvn clean install

[`xtext-jflex`]: https://github.com/TypeFox/xtext-jflex
