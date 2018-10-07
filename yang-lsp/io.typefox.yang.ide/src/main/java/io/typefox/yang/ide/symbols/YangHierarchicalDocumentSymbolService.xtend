package io.typefox.yang.ide.symbols

import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.Statement
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.ide.server.symbol.HierarchicalDocumentSymbolService

import static extension com.google.common.collect.Iterators.*

class YangHierarchicalDocumentSymbolService extends HierarchicalDocumentSymbolService {

	override protected getAllContents(Resource resource) {
		val module = resource.contents.head;
		if (module instanceof AbstractModule) {
			val allStatements = EcoreUtil.getAllProperContents(module, true).filter(Statement);
			return allStatements.filter(Object);
		}
		return emptyList.iterator;
	}

}
