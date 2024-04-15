# Processing YANG files

As yang-lsp contains all the tools to parse, link and validate YANG models. If
you want to further process the YANG files you authored with yang-lsp it makes
sense to make reuse of the existing functionality.

Here is some example code in Xtend for an application that reads in all YANG
files from a given directory. The files are parsed into our YANG EMF model, all
cross-references are resolved and all files are validated. If there are no
errors, the method `generate()` is called for all resources:

```xtend
package io.typefox.yang.example

import com.google.inject.Inject
import io.typefox.yang.YangStandaloneSetup
import io.typefox.yang.yang.Module
import java.io.File
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator

class StandaloneExample {

    def static void main(String... args) {
        val injector = new YangStandaloneSetup().createInjectorAndDoEMFRegistration
        injector.getInstance(StandaloneExample).run(args)
    }

    @Inject XtextResourceSet resourceSet
    @Inject IResourceValidator validator
    boolean hasErrors = false

    def void run(String... args) {
        addFile(new File(args.head))
        resourceSet.resources.forEach [ resource |
            EcoreUtil.resolveAll(resource)
            val issues = validator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl)
            issues.forEach [ issue |
                hasErrors = hasErrors || issue.severity === Severity.ERROR
                System.err.println(issue)
            ]
        ]
        if(!hasErrors) {
            resourceSet.resources.forEach [
                generate
            ]
        }
    }

    def void addFile(File file) {
        if(file.isDirectory)
            file.listFiles.forEach[ addFile ]
        else if(file.name.endsWith('.yang'))
            resourceSet.getResource(URI.createURI(file.toURI.toString), true)
    }

    def generate(Resource resource) {
        // do your own processing here
        resource.allContents.filter(Module).forEach [ module |
            println('''
                Found module «module.name»
            ''')
        ]
    }
}
```

A number of useful helper methods can be found in the [utils package][1]

Here is sample `build.gradle` to build the above class:

```groovy
buildscript {
    repositories.jcenter()
    dependencies {
        classpath 'org.xtext:xtext-gradle-plugin:1.0.19'
    }
}

repositories {
    jcenter()
    maven { url 'https://oss.sonatype.org/content/repositories/snapshots' }
}

apply plugin: 'org.xtext.xtend'
apply plugin: 'eclipse'
apply plugin: 'idea'
apply plugin: 'maven'

group = 'io.typefox.yang'
version = '0.1.0-SNAPSHOT'

dependencies {
    compile 'io.typefox.yang:io.typefox.yang:0.1.0-SNAPSHOT'
    compile 'org.eclipse.xtext:org.eclipse.xtext:2.13.0'
    compile 'org.eclipse.xtend:org.eclipse.xtend.lib:2.13.0'
    compile 'com.google.inject:guice:3.0'
}
```

[1]: https://github.com/TypeFox/yang-lsp/tree/master/yang-lsp/io.typefox.yang/src/main/java/io/typefox/yang/utils
