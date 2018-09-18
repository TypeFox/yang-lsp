package io.typefox.yang.ide.symbols

import com.google.inject.Inject
import io.typefox.yang.utils.YangNameUtils
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Augment
import io.typefox.yang.yang.Case
import io.typefox.yang.yang.Choice
import io.typefox.yang.yang.Container
import io.typefox.yang.yang.Extension
import io.typefox.yang.yang.Feature
import io.typefox.yang.yang.Grouping
import io.typefox.yang.yang.Identity
import io.typefox.yang.yang.Input
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.LeafList
import io.typefox.yang.yang.List
import io.typefox.yang.yang.Notification
import io.typefox.yang.yang.Output
import io.typefox.yang.yang.Rpc
import io.typefox.yang.yang.SchemaNode
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Typedef
import java.util.ArrayList
import org.eclipse.emf.ecore.EObject
import org.eclipse.lsp4j.SymbolInformation
import org.eclipse.lsp4j.SymbolKind
import org.eclipse.lsp4j.jsonrpc.messages.Either
import org.eclipse.xtext.findReferences.IReferenceFinder.IResourceAccess
import org.eclipse.xtext.ide.server.DocumentExtensions
import org.eclipse.xtext.ide.server.symbol.DocumentSymbolService
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.eclipse.xtext.resource.ILocationInFileProvider
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.TextRegion

class YangDocumentSymbolService extends DocumentSymbolService {
	
	@Inject extension DocumentExtensions 
	@Inject EObjectAtOffsetHelper helper
	@Inject ILocationInFileProvider locationProvider
	
	override getDefinitions(XtextResource resource, int offset, IResourceAccess resourceAccess, CancelIndicator cancelIndicator) {
		val node = helper.getCrossReferenceNode(resource, new TextRegion(offset,0))
		if (node !== null) {
			val element = helper.getCrossReferencedElement(node)
			if (element !== null) {
				return #[element.symbolFullLocation]
			}
		}
		return emptyList
	}
	
	override getSymbols(XtextResource resource, CancelIndicator cancelIndicator) {
		val result = newArrayList
		val module = resource.contents.head
		if (module instanceof AbstractModule) {
			collectSymbols(module, null, result, cancelIndicator)
		}
		return result.map[Either.forLeft(it)]
	}
	
	def getKind(SchemaNode node) {
		switch node {
			Case : SymbolKind.String
			Choice : SymbolKind.Number
			Container : SymbolKind.Namespace
			Extension : SymbolKind.Module
			Feature : SymbolKind.Boolean
			Grouping : SymbolKind.Class
			Identity : SymbolKind.Constant
			Input : SymbolKind.Property
			Leaf: SymbolKind.Variable
			LeafList : SymbolKind.Array
			List : SymbolKind.Array
			Output : SymbolKind.Constructor
			Notification : SymbolKind.Function
			Rpc : SymbolKind.Method
			Typedef : SymbolKind.Enum
			
			default : SymbolKind.Field
		}
	}
	
	def dispatch String handleNode(EObject stmnt, String parent, ArrayList<SymbolInformation> symbols, CancelIndicator indicator) {
		// do nothing
	}
	
	def dispatch String handleNode(Augment stmnt, String parent, ArrayList<SymbolInformation> symbols, CancelIndicator indicator) {
		val s = new SymbolInformation
		s.containerName = parent
		s.kind = SymbolKind.Method
		s.name = NodeModelUtils.findActualNodeFor(stmnt.path).text.trim ?: YangNameUtils.getYangName(stmnt)
		s.location = stmnt.symbolFullLocation
		
		symbols.add(s)
		return s.name
	}
	
	def dispatch String handleNode(SchemaNode stmnt, String parent, ArrayList<SymbolInformation> symbols, CancelIndicator indicator) {
		val s = new SymbolInformation
		s.containerName = parent
		s.kind = stmnt.kind
		s.name = stmnt.name ?: YangNameUtils.getYangName(stmnt)
		s.location = stmnt.symbolFullLocation
		
		symbols.add(s)
		return s.name
	}
	
	def void collectSymbols(Statement stmnt, String parent, ArrayList<SymbolInformation> symbols, CancelIndicator indicator) {
		val name = handleNode(stmnt, parent, symbols, indicator)
		for (child : stmnt.substatements) {
			collectSymbols(child, name?:parent, symbols, indicator)
		}
	}
	
	protected def getSymbolFullLocation(EObject object) {
		val resource = object.eResource
		val fullRegion = locationProvider.getFullTextRegion(object)
		resource.newLocation(fullRegion)
	}
	
}