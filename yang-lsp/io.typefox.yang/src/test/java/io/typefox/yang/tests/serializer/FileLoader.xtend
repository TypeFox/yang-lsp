package io.typefox.yang.tests.serializer

import io.typefox.yang.yang.AbstractModule
import java.io.File
import java.io.FileFilter
import java.util.Collections
import java.util.List
import org.eclipse.core.runtime.Assert
import org.eclipse.emf.common.CommonPlugin
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.impl.ResourceDescriptionsData

/**
 * ModuleLoader only focus on loading URI/File into ResourceSet,
 * and then return AbstractModule.
 * 
 */
class FileLoader {
	
	var XtextResourceSet xtextResourceSet

	new(XtextResourceSet resourceSet, List<String> moduleSearchDirs, IResourceDescription.Manager manager) {
		Assert.isNotNull(resourceSet)
		xtextResourceSet = resourceSet
		
		moduleSearchDirs.prepareXtextResources
		installIndex(manager)
	}
	
	def get(File file) {
		var Resource resource = xtextResourceSet.resources.findFirst[ r |
			var rURI = r.URI
			if (!rURI.isFile) {
				rURI = CommonPlugin.resolve(r.URI)
			}
			file.absolutePath.equals(rURI.toFileString)
		]
		if (resource !== null) {
			return resource.getContents().get(0) as AbstractModule
		}

		return null
	}
	
	private def void prepareXtextResources(List<String> moduleSearchDirs) {
		moduleSearchDirs.forEach[handleDependenciesPath]
	}
	
	private def void handleDependenciesPath(String pathString) {
        var File dependenciesPathFile = new File(pathString);
        if(dependenciesPathFile.isFile()) {
            getOrCreateResource(URI.createFileURI(pathString));
        }
        
        if(dependenciesPathFile.isDirectory()) {
            recursivelyIntoDirectory(dependenciesPathFile);
        }
    }

    private def void recursivelyIntoDirectory(File dependenciesPathFile) {
        var File[] yangFiles = dependenciesPathFile.listFiles(new FileFilter() {
            override boolean accept(File pathname) {
                return pathname.getName().endsWith(".yang");
            }
        })
        if(yangFiles === null) {
            return;
        }
        for(File yangFile : yangFiles) {
            handleDependenciesPath(yangFile.getAbsolutePath());
        }
    }
    
    private def void getOrCreateResource(URI uri) {
        var targetResource = xtextResourceSet.getResource(uri, true);
        if(targetResource === null) {
            xtextResourceSet.createResource(uri);
        }
    }

	private def void installIndex(IResourceDescription.Manager manager) {
		val descriptionData = new ResourceDescriptionsData(Collections.emptyList)
		
		for (resource : xtextResourceSet.resources) {
			descriptionData.addDescription(resource, manager)
		}
		ResourceDescriptionsData.ResourceSetAdapter.installResourceDescriptionsData(xtextResourceSet, descriptionData)
	}

	private def void addDescription(ResourceDescriptionsData data, Resource resource, IResourceDescription.Manager manager) {
		val resourceDescription = manager.getResourceDescription(resource)
		if (resourceDescription !== null) {
			data.addDescription(resource.URI, resourceDescription)
		}
	}

}
