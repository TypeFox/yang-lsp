# Settings

The yang-lsp allos the user to configure various settings, though setting files.
A setting file has the name `yang.settings` and can be located
 - at the root of a project
 - in the user's directory under `~/.yang/yang.settings`.

The file syntax is a JSONC and its schema can be found [here](../schema/yang-lsp-settings-schema.json).

## Disable Code Lens

If you don't want to see the code lenses you can turn it of with the following property:

```json
{
  "code-lens-enabled" : "off"
}
```

## Excluded Paths

Many IDEs and tools copy YANG files into another folder within the same project. As the YANG LSP treats all files within a project the same, this usually infers issues about duplicate elements. To avoid that, you can exclude several directories in the project setting `excludePath`, e.g.

```json
{
   "excludePath": "build:bin"
}
```

exludes the default output folder of Maven/Gradle and Eclipse JDT. The path elements are project relative directory names. You can specify multiple elements separated with a colon. The file separator is always `/` independent from the OS.

## YANG Libraries

Often you don't specify a self contained set of YANG models but rely on existing standard libs instead, e.g. from the IETF. Thes don't necessarily reside in your workspace. To specify such libraries, use `yangPath`

```json
{
  "yangPath": "/my/home/yang/libs/rift.zip"
}
```

You can specify individual files, directories (contents will be added recursively) or ZIP files. The file name format is OS specific, and so is the path separator (`;` on Windows, `:` elsewhere).

## Extensions

The settings is used to register an extension. Please find the details [here](Extensions.md).

## Diagnostics

The user can change the severity of diagnostics, by setting the value of a diagnostic preference key to either
 - `"error"`
 - `"warning"`
 - `"ignore"`

The settings contains a `diagnostics` section in which the serverioties for the below diagnostics can be adjusted.
An example :
```json
{
  "diagnostic" : {
    "xpath-linking-error" : "error"
  }
}
```

#### `substatement-cardinality`

Issue code that are entangled with cardinality problems of container statement's sub-statements.

 (default severity: error)

#### `unexpected-statement`

Issue code indicating an invalid sub-statement inside its parent statement container.

 (default severity: error)

#### `substatement-ordering`

Issue code for cases when a sub-statement incorrectly precedes another sub-statement.

 (default severity: error)

#### `incorrect-version`

Issues code that is used when a module has anything but {@code '1.1'} version.

 (default severity: error)

#### `type-error`

Errors for types. Such as invalid type restriction, range error, fraction-digits issue.

 (default severity: error)

#### `duplicate-name`

A duplicate local name.

 (default severity: error)

#### `missing-prefix`


 (default severity: error)

#### `missing-revision`

Diagnostic that indicates a module is available in multiple revisions when no revision is provided on an import.

 (default severity: warning)

#### `import-not-a-module`

Diagnostic indicating that an `import` statement is not pointing to a module.

 (default severity: error)

#### `include-not-a-submodule`

Diagnostic indicating that an `include` statement is not pointing to a submodule.

 (default severity: error)

#### `included-submodule-belongs-to-different-module`

Indicating that an included module belongs to a different module.

 (default severity: error)

#### `invalid-revision-format`

Issue code when the revision date does not conform the "YYYY-MM-DD" format.

 (default severity: warning)

#### `revision-order`

Issue code that applies on a revision if that is not in a reverse chronological order.

 (default severity: warning)

#### `bad-type-name`

Issue code when the name of a type does not conform with the existing constraints.
For instance; the name contains any invalid characters, or equals to any YANG built-in type name.

 (default severity: error)

#### `bad-include-yang-version`

Issues code when there is an inconsistency between a module's version and the version of the included modules.

 (default severity: error)

#### `bad-import-yang-version`

Issues code when there is an inconsistency between a module's version and the version of the included modules.

 (default severity: error)

#### `duplicate-enumerable-name`

Issue code indicating that all assigned names in an enumerable must be unique.

 (default severity: error)

#### `duplicate-enumerable-value`

Issue code indicating that all assigned values in an enumerable must be unique.

 (default severity: error)

#### `enumerable-restriction-name`

Issue code indicating that an enumerable introduces a new name that is not declared among the parent restriction.

 (default severity: error)

#### `enumerable-restriction-value`

Issue code indicating that an enumerable introduces a new value that is not declared among the parent restriction.

 (default severity: error)

#### `key-duplicate-leaf-name`

Issues code for indicating a duplicate leaf node name in a key.

 (default severity: error)

#### `ordinal-value`

Issue code when an ordinal value exceeds its limits.

 (default severity: error)

#### `indentation`

Controls the indentation string when formatting or serializing yang files.

 (default: four spaces)

#### `invalid-config`

Issue code when a `config=true` is a child of a `config=false` (see https://tools.ietf.org/html/rfc7950#section-7.21.1)

 (default severity: error)

#### `invalid-augmentation`

Issue code when an augmented node declares invalid sub-statements. For instance when an augmented leaf node has leaf nodes.

 (default severity: error)

#### `invalid-default`

Issue code for cases when the a choice has default value and the mandatory sub-statement is "true".

 (default severity: error)

#### `mandatory-after-default-case`

Issue code when any mandatory nodes are declared after the default case in a "choice".

 (default severity: error)

#### `invalid-action-ancestor`

Issue code when an action (or notification) has a "list" ancestor node without a "key" statement.
Also applies, when an action (or notification) is declared within another action, rpc or notification.

 (default severity: error)

#### `identity-cycle`

Issue code when an identity references itself, either directly or indirectly through a chain of other identities.

 (default severity: error)

#### `leaf-key-with-if-feature`

This issue code is used when a leaf node is declared as a list key and have any "if-feature" statements.

 (default severity: error)

#### `xpath-invalid-type`

Invalid type in Xpath expression

 (default severity: error)

#### `xpath-unknown-variable`

Xpath expressions in YANG don't have variables in context

 (default severity: error)

#### `xpath-unknown-function`

An unknown function is called

 (default severity: warning)

#### `xpath-function-arity`

Wrong argument arity for an Xpath function call.

 (default severity: error)

#### `xpath-linking-error`

Diagnostic for unresolvable Xpath expressions.

 (default severity: ignore)

