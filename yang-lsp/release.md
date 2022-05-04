### Steps to follow

- Create local branch e.g. `release-0.5.0`
- Update the version to `version = '0.5.0'` in `yang-lsp/gradle/versions.gradle` and commit
- Create a tag named `v0.5.0` and push tags to remote
- Go to [Releases](https://github.com/theia-ide/yang-lsp/releases) GitHub page and initiate a new release by clicking __Draft a new release__
- Select `v0.5.0` tag from the __Choose a tag__ dropdown, fill out the form and click __Publish release__
- A [Release](https://github.com/theia-ide/yang-lsp/actions/workflows/release.yml) GH Action will start building and publishing the maven artifacts to the OSS staging repository
- After a successful build copy build artifacts `language-server_0.5.0.zip` and `yang-language-server_diagram-extension_0.5.0.zip` to the release assets. You can edit an existing release by clicking the __Edit__ icon and upload files using drag and drop.
- Finally go to [OSS Staging Repository](https://oss.sonatype.org/#stagingRepositories) and __Close__ -> __Release__ the staging yang repositories
- Check the released version inside the [maven repo](https://repo1.maven.org/maven2/io/typefox/yang/)