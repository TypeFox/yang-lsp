//package io.typefox.yang.scoping
//
//import com.google.inject.Inject
//import io.typefox.yang.utils.YangExtensions
//import io.typefox.yang.validation.IssueCodes
//import io.typefox.yang.yang.AbsoluteSchemaNodeIdentifier
//import io.typefox.yang.yang.AbstractModule
//import io.typefox.yang.yang.Augment
//import io.typefox.yang.yang.DataSchemaNode
//import io.typefox.yang.yang.Grouping
//import io.typefox.yang.yang.IdentifierRef
//import io.typefox.yang.yang.Import
//import io.typefox.yang.yang.SchemaNodeIdentifier
//import io.typefox.yang.yang.Statement
//import io.typefox.yang.yang.Uses
//import io.typefox.yang.yang.YangPackage
//import java.util.Map
//import org.eclipse.emf.ecore.EObject
//import org.eclipse.xtend.lib.annotations.Data
//import org.eclipse.xtext.naming.QualifiedName
//
//class DataSchemaScopeComputer {
//
//	@Inject extension YangExtensions
//	@Inject Validator validator
//	@Inject Linker linker
//	
//	@Data static class Ctx {
//		String moduleName
//		Map<String,String> prefixMap
//		ScopeContext scopes
//	}	
//
//	def void buildDataSchemaScope(AbstractModule module, ScopeContext scopes) {
//		val ctx = createContext(module, scopes)
//		module.substatements.handle(QualifiedName.EMPTY, ctx)
//	}
//	
//	private def Ctx createContext(AbstractModule m, ScopeContext scopes) {
//		val moduleName = m.mainModule?.name ?: m.name
//		val prefixMap = newHashMap
//		prefixMap.put(m.prefix, moduleName)
//		for (imp : m.substatements.filter(Import)) {
//			val pref = imp.prefix
//			val name = imp.module.name
//			if (pref !== null && name !== null) {
//				prefixMap.put(pref, name)
//			}
//		}
//		return new Ctx(moduleName, prefixMap, scopes)
//	}
//	
//	def dispatch void buildDataSchemaScope(Statement statement, QualifiedName prefix, Ctx ctx) {
//		val name = statement.getQualifiedName(prefix, ctx)
//		if (name != prefix && !ctx.scopes.localNodeScope.tryAddLocal(name, statement)) {
//			validator.addIssue(statement, YangPackage.Literals.SCHEMA_NODE__NAME, '''A data schema node with the name '«name.lastSegment»' already exists.''', IssueCodes.DUPLICATE_NAME)	
//		}
//		statement.substatements.handle(name, ctx)
//	}
//	
//	def dispatch void buildDataSchemaScope(Uses uses, QualifiedName prefix, Ctx ctx) {
//		val grouping = uses.grouping.node
//		if (grouping.eIsProxy) {
//			return;
//		}
//		grouping.substatements.handle(prefix, ctx)
//		uses.substatements.handle(prefix,ctx)
//	}
//	
//	def dispatch void buildDataSchemaScope(Augment augment, QualifiedName prefix, Ctx ctx) {
//		val newPrefix = augment.path.getQualifiedName(prefix, ctx)
//		augment.substatements.handle(newPrefix, ctx)
//	}
//	
////	def dispatch QualifiedName getQualifiedName(EObject node, QualifiedName p, Ctx ctx) {
////		return p
////	}
////	
////	def dispatch QualifiedName getQualifiedName(Grouping node, QualifiedName p, Ctx ctx) {
////		// add a synthetic non-referenceable segment for groupings in the node namespace
////		return p.append("%groupings").append(node.name)
////	}
////	
////	def dispatch QualifiedName getQualifiedName(DataSchemaNode node, QualifiedName p, Ctx ctx) {
////		return p.append(ctx.moduleName).append(node.name)
////	}
////	
////	def dispatch QualifiedName getQualifiedName(SchemaNodeIdentifier identifier, QualifiedName p, Ctx ctx) {
////		var prefix = if (identifier instanceof AbsoluteSchemaNodeIdentifier) {
////			QualifiedName.EMPTY
////		} else {
////			p
////		}
////		for (element : identifier.elements) {
////			prefix = element.getQualifiedName(prefix, ctx)
////		}
////		return prefix
////	}
////	
////	def dispatch QualifiedName getQualifiedName(IdentifierRef ref, QualifiedName prefix, Ctx ctx) {
////		val qn = linker.getLinkingName(ref, YangPackage.Literals.IDENTIFIER_REF__NODE)
////		if (qn !== null) {
////			var firstSeg = ctx.moduleName
////			if (qn.segmentCount === 2) {
////				firstSeg = ctx.prefixMap.get(qn.firstSegment) ?: ctx.moduleName
////			}
////			var secondSeg = qn.lastSegment
////			return prefix.append(firstSeg).append(secondSeg)
////		}
////		return prefix
////	}
//	
//	def void handle(Iterable<Statement> children, QualifiedName prefix, Ctx ctx) {
//		for (c : children) {
//			this.buildDataSchemaScope(c, prefix, ctx)
//		}
//	}
//	
////	def void resolvePathes(AbstractModule module, ScopeContext scopes) {
////		val ctx = createContext(module, scopes)
////		module.resolvePathes(QualifiedName.EMPTY, ctx)
////	}
////	
////	protected def dispatch void resolvePathes(Statement statement, QualifiedName prefix, Ctx context) {
////		val newPrefix = statement.getQualifiedName(prefix, context)
////		statement.substatements.forEach[resolvePathes(newPrefix, context)]
////	}
////	
////	protected def dispatch void resolvePathes(Augment statement, QualifiedName prefix, Ctx context) {
////		val newPrefix = statement.getQualifiedName(prefix, context)
////		statement.path.doLink(prefix, context)
////		statement.substatements.forEach[resolvePathes(newPrefix, context)]
////	}
//	
//	
//}
//		