package io.typefox.yang.ide.symbols

import com.google.inject.Inject
import io.typefox.yang.scoping.ScopeContextProvider
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.LeafList
import io.typefox.yang.yang.List
import org.eclipse.lsp4j.SymbolInformation
import org.eclipse.lsp4j.SymbolKind
import org.eclipse.xtext.findReferences.IReferenceFinder.IResourceAccess
import org.eclipse.xtext.ide.server.DocumentExtensions
import org.eclipse.xtext.ide.server.symbol.DocumentSymbolService
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.TextRegion

class YangDocumentSymbolService extends DocumentSymbolService {
	
	@Inject extension DocumentExtensions 
	@Inject EObjectAtOffsetHelper helper
	@Inject ScopeContextProvider provider
	
	override getDefinitions(XtextResource resource, int offset, IResourceAccess resourceAccess, CancelIndicator cancelIndicator) {
		val node = helper.getCrossReferenceNode(resource, new TextRegion(offset,0))
		if (node !== null) {
			val element = helper.getCrossReferencedElement(node)
			if (element !== null) {
				return #[element.newLocation]
			}
		}
		return emptyList
	}
	
	
	override getSymbols(XtextResource resource, CancelIndicator cancelIndicator) {
		val result = newArrayList
		val module = resource.contents.head
		if (!(module instanceof AbstractModule)) {
			return result
		}
		val x = provider.getScopeContext(module as AbstractModule)
		for (g : x.groupingScope.localOnly.allElements) {
			result += new SymbolInformation => [
				name = g.qualifiedName.lastSegment
				location = g.EObjectOrProxy.symbolLocation
				kind = SymbolKind.Class
			]
		}
		
		for (g : x.identityScope.localOnly.allElements) {
			result += new SymbolInformation => [
				name = g.qualifiedName.lastSegment
				location = g.EObjectOrProxy.symbolLocation
				kind = SymbolKind.Constant
			]
		}
		
		for (g : x.featureScope.localOnly.allElements) {
			result += new SymbolInformation => [
				name = g.qualifiedName.lastSegment
				location = g.EObjectOrProxy.symbolLocation
				kind = SymbolKind.Constant
			]
		}
		
		for (g : x.extensionScope.localOnly.allElements) {
			result += new SymbolInformation => [
				name = g.qualifiedName.lastSegment
				location = g.EObjectOrProxy.symbolLocation
				kind = SymbolKind.Namespace
			]
		}
		
		for (g : x.typeScope.localOnly.allElements) {
			result += new SymbolInformation => [
				name = g.qualifiedName.lastSegment
				location = g.EObjectOrProxy.symbolLocation
				kind = SymbolKind.Interface
			]
		}
		
		for (g : x.nodeScope.localOnly.allElements) {
			val cleanName = g.qualifiedName.clean
			if (g.EObjectOrProxy.eResource === resource) {
				result += new SymbolInformation => [
					name = cleanName.lastSegment
					containerName = '/'+cleanName.skipLast(1).toString('/')
					location = g.EObjectOrProxy.symbolLocation
					kind = switch g.EObjectOrProxy {
						Leaf : SymbolKind.Property
						Container : SymbolKind.Interface 
						LeafList : SymbolKind.Array
						List : SymbolKind.Array
					}
				]
			}
		}
		
		return result
	}
	
	private def QualifiedName clean(QualifiedName name) {
		val segments = name.segments
		val newSegments = newArrayList
		segments.forEach[segment, idx|
			if (idx % 2 !== 0) {
				newSegments += segment
			}
		]
		return QualifiedName.create(newSegments)
	}
	
}