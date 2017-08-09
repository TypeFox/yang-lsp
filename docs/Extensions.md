# Adding a Validator Extension

The yang-lsp allows to have additional third party extensions, configured through the `yang.settings` file.
That file must be located in the root of an opened directory must conform to JSON syntax.

# Create a Validator

A validator extension is a Java class that implements the interface `io.typefox.yang.validation.IValidatorExtension`. 
Here is a small example:

```java
package my.pack;

// imports ...

public class MyExampleValidator implements IValidatorExtension {

	public static final String BAD_NAME = "bad_name";

	@Override
	public void validate(AbstractModule module, IAcceptor<Issue> issueAcceptor, CancelIndicator cancelIndicator) {
		if (module.getName().equals("foo")) {
			issueAcceptor.accept(IssueFactory.createIssue(module, YangPackage.Literals.ABSTRACT_MODULE__NAME, "'foo' is a bad name", BAD_NAME));
		}
	}

}
``` 

# Package an extension

The class needs to be packaged in a jar. So simply use the java build tool of your preference to create a jar from it. Put the jar somewhere relative to the project's root directory. 

# Add the plugin

Create (or open) the `yang.settings` file and add the plugin using the following configuration:

```json
	"extension" : {
		"classpath" : "extension.jar",
		"validators" : "my.pack.MyExampleValidator"
	}
```

The language server will automatically pick up the extension.
