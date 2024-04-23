# Extensions

The yang-lsp allows to have additional third party extensions, configured
through `yang.settings`. For details on file format and schema see
[Settings.md](./Settings.md).

So far two different kinds of extensions are supported :

- Validators (`IValidatorExtension`)
- Commands (`ICommandExtension`)

## Create a Validator

A validator extension is a Java class that implements the interface
`io.typefox.yang.validation.IValidatorExtension`.

Here is a small example:

```java
package my.pack;

// imports ...

public class MyExampleValidator implements IValidatorExtension {

    public static final String BAD_NAME = "bad_name";

    @Override
    public void validate(AbstractModule module, IAcceptor<Issue> issueAcceptor, CancelIndicator cancelIndicator) {
        if (module.getName().equals("foo")) {
            issue = IssueFactory.createIssue(module, YangPackage.Literals.ABSTRACT_MODULE__NAME,
                                             "'foo' is a bad name", BAD_NAME)
            issueAcceptor.accept();
        }
    }

}
```

## Create a Command Extension

A command extension contributes actions, that will be shown in the context menu
of a supporting client (currently only Yangster supports it).

Here is an example:

```java
class MyCommand implements ICommandExtension {

    static val COMMAND = "Create a file name 'foo.txt'."

    /**
     * return a list of commands. A command string is used as ID internally and as a label in the UI.
     */
    override getCommands() {
        #[COMMAND]
    }

    /**
     * Called when the user asked to execute a certain command.
     */
    override executeCommand(String command, Resource resource, LanguageClient client) {
        if (COMMAND == command) {
            // get the project directory
            val uri = ProjectConfigAdapter.findInEmfObject(resource.resourceSet)?.projectConfig?.path.toFileString
            val f = new File(uri, 'foo.txt')
            if (f.exists) {
                client.showMessage(new MessageParams => [
                    message = 'Such a file already exists.'
                ])
            } else {
                f.createNewFile
            }
        }
    }

}
```

## Package an extension

The class needs to be packaged in a jar. So simply use the java build tool of
your preference to create a jar from it. Put the jar somewhere relative to the
project's root directory.

## Add the plugin

Create (or open) the `yang.settings` file and add the plugin using the following
configuration. Other classpaths, validator and commands classes can be provided
as well.

```json
  "extension" : {
    "classpath" : "extension.jar:./second-extension.jar:./local-classdir/.",
    "validators" : "my.pack.MyExampleValidator:my.pack.MyYetAnotherExampleValidator",
    "commands" : "my.pack.MyCommand:my.pack.MyOtherCommand"
  }
```

The language server will automatically pick up the extension.
