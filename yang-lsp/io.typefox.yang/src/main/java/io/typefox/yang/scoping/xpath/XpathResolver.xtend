package io.typefox.yang.scoping.xpath

import com.google.inject.Inject
import io.typefox.yang.scoping.IScopeContext
import io.typefox.yang.scoping.Linker
import io.typefox.yang.scoping.ScopeContext.MapScope
import io.typefox.yang.scoping.ScopeContextProvider
import io.typefox.yang.scoping.Validator
import io.typefox.yang.utils.YangExtensions
import io.typefox.yang.validation.IssueCodes
import io.typefox.yang.validation.LinkingErrorMessageProvider
import io.typefox.yang.yang.AbbrevAttributeStep
import io.typefox.yang.yang.AbsolutePath
import io.typefox.yang.yang.Case
import io.typefox.yang.yang.Choice
import io.typefox.yang.yang.CurrentRef
import io.typefox.yang.yang.Input
import io.typefox.yang.yang.Leaf
import io.typefox.yang.yang.Output
import io.typefox.yang.yang.ParentRef
import io.typefox.yang.yang.Path
import io.typefox.yang.yang.ProcessingInstruction
import io.typefox.yang.yang.RelativePath
import io.typefox.yang.yang.Type
import io.typefox.yang.yang.XpathAdditiveOperation
import io.typefox.yang.yang.XpathAndOperation
import io.typefox.yang.yang.XpathEqualityOperation
import io.typefox.yang.yang.XpathExpression
import io.typefox.yang.yang.XpathFilter
import io.typefox.yang.yang.XpathFunctionCall
import io.typefox.yang.yang.XpathLocation
import io.typefox.yang.yang.XpathMultiplicativeOperation
import io.typefox.yang.yang.XpathNodeType
import io.typefox.yang.yang.XpathNumberLiteral
import io.typefox.yang.yang.XpathOrOperation
import io.typefox.yang.yang.XpathRelationalOperation
import io.typefox.yang.yang.XpathStep
import io.typefox.yang.yang.XpathStringLiteral
import io.typefox.yang.yang.XpathUnaryOperation
import io.typefox.yang.yang.XpathUnionOperation
import io.typefox.yang.yang.XpathVariableReference
import io.typefox.yang.yang.YangPackage
import java.util.List
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.util.internal.EmfAdaptable
import org.eclipse.xtext.util.internal.Log

@Log
class XpathResolver {
	
	@Inject Validator validator
	@Inject Linker linker
	@Inject ScopeContextProvider scopeContextProvider
	@Inject extension YangExtensions 
	
	static val ASTERISK = QualifiedName.create('*')
	
	@Data static class Context {
		MapScope nodeScope
		String moduleName
		XpathType initial
	}
	
	@EmfAdaptable @Data static class TypeAdapter {
		XpathType type
	}
	

	def XpathType getType(XpathExpression expr) {
		return TypeAdapter.findInEmfObject(expr)?.type
	}
	
	private def install(XpathType type, EObject obj) {
		if (TypeAdapter.findInEmfObject(obj) !== null) {
			return type
		}
		new TypeAdapter(type).attachToEmfObject(obj)
		return type	
	}
	
	def XpathType doResolve(XpathExpression expression, QualifiedName contextNode, IScopeContext context) {
		val element = context.schemaNodeScope.getSingleElement(contextNode)
		val initialContext =
			if (element === null) {
				Types.nodeSet(emptyList)
			} else {
				val allDescriptions = context.schemaNodeScope.getElements(element.EObjectOrProxy).toList
				if (allDescriptions.empty)
					Types.nodeSet(element)
				else
					Types.nodeSet(allDescriptions)
			}
		internalResolve(expression, initialContext, new Context(context.schemaNodeScope, context.moduleName, initialContext))
	}
	
	protected def dispatch XpathType internalResolve(Void e, XpathType contextType, Context ctx) {
		contextType
	}
	
	protected def dispatch XpathType internalResolve(XpathExpression e, XpathType contextType, Context ctx) {
		throw new IllegalStateException()
	}
	
	protected def dispatch XpathType internalResolve(XpathOrOperation e, XpathType contextType, Context ctx) {
		internalResolve(e.left, contextType, ctx)
		internalResolve(e.right, contextType, ctx)
		return Types.BOOLEAN.install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathAndOperation e, XpathType contextType, Context ctx) {
		internalResolve(e.left, contextType, ctx)
		internalResolve(e.right, contextType, ctx)
		return Types.BOOLEAN.install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathEqualityOperation e, XpathType contextType, Context ctx) {
		internalResolve(e.left, contextType, ctx)
		internalResolve(e.right, contextType, ctx)
		return Types.BOOLEAN.install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathRelationalOperation e, XpathType contextType, Context ctx) {
		internalResolve(e.left, contextType, ctx)
		internalResolve(e.right, contextType, ctx)
		return Types.BOOLEAN.install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathAdditiveOperation e, XpathType contextType, Context ctx) {
		internalResolve(e.left, contextType, ctx)
		internalResolve(e.right, contextType, ctx)
		return Types.NUMBER.install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathMultiplicativeOperation e, XpathType contextType, Context ctx) {
		internalResolve(e.left, contextType, ctx)
		internalResolve(e.right, contextType, ctx)
		return Types.NUMBER.install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathUnaryOperation e, XpathType contextType, Context ctx) {
		internalResolve(e.target, contextType, ctx)
		return Types.NUMBER.install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathUnionOperation e, XpathType contextType, Context ctx) {
		var left = internalResolve(e.left, contextType, ctx)
		var right = internalResolve(e.right, contextType, ctx)
		if (!(left instanceof NodeSetType) && left !== Types.ANY) {
			validator.addIssue(e.left, null, "The operands of a union operation must return a node set.", IssueCodes.INVALID_TYPE)
		}
		if (!(right instanceof NodeSetType) && left !== Types.ANY) {
			validator.addIssue(e.right, null, "The operands of a union operation must return a node set.", IssueCodes.INVALID_TYPE)
		}
		return Types.union(left, right).install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathLocation e, XpathType contextType, Context ctx) {
		var newContext = internalResolve(e.target, contextType, ctx)
		return internalResolveStep(e.step, newContext, ctx).install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathFilter e, XpathType contextType, Context ctx) {
		var newContext = internalResolve(e.target, contextType, ctx)
		if (e.predicate !== null) {
			internalResolve(e.predicate, newContext, ctx)
		}
		return newContext.install(e)
	}
	protected def dispatch XpathType internalResolve(XpathVariableReference e, XpathType contextType, Context ctx) {
		validator.addIssue(e, YangPackage.Literals.XPATH_VARIABLE_REFERENCE__NAME, "Unknown variable '"+e.name+"'.", IssueCodes.UNKNOWN_VARIABLE)
		return Types.ANY.install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathStringLiteral e, XpathType contextType, Context ctx) {
		return Types.STRING.install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathNumberLiteral e, XpathType contextType, Context ctx) {
		return Types.NUMBER.install(e)
	}
	
	protected def dispatch XpathType internalResolve(XpathFunctionCall e, XpathType contextType, Context ctx) {
		val f = XpathFunctionLibrary.FUNCTIONS.get(e.name)
		if (f === null) {
			validator.addIssue(e, YangPackage.Literals.XPATH_FUNCTION_CALL__NAME, "Unkown function '"+e.name+"()'.", IssueCodes.UNKNOWN_FUNCTION)
			for (arg : e.args) {
				internalResolve(arg, contextType, ctx)
			}
			return Types.ANY.install(e)
		}
		if (f.name == 'current') {
			return ctx.initial.install(e)
		}
		if (f.name == 'deref') {
			val type = internalResolve(e.args.head, contextType, ctx)
			if (type instanceof NodeSetType) {
				val desc = type.nodes.head
				if (desc !== null) {
					if (desc.EObjectOrProxy instanceof Leaf) {
						val l = desc.EObjectOrProxy as Leaf
						val leafType = l.substatements.filter(Type).head
						if (leafType.typeRef.builtin == 'leafref') {
							val reference = leafType.substatements.filter(Path).head.reference
							return this.internalResolve(reference, Types.nodeSet(desc), ctx).install(e)
						}
					}
				}
			}
			return Types.nodeSet(#[Linker.ROOT]).install(e)
		}
		for (arg : e.args) {
			internalResolve(arg, contextType, ctx)
		}
		return (switch (f.returnType) {
			case XpathFunctionLibrary.Type.BOOLEAN : Types.BOOLEAN
			case XpathFunctionLibrary.Type.NUMBER : Types.NUMBER
			case XpathFunctionLibrary.Type.STRING : Types.STRING
			default: Types.ANY
		}).install(e)
	}
	
	protected def void checkArity(XpathFunctionCall e, int min, int max) {
		val fun = ['''«IF it===0»no arguments«ELSEIF it===1»one argument«ELSE»«it» arguements«ENDIF»''']
		if (e.args.size < min)
			validator.addIssue(e, null, "The function '"+e.name+"' needs at least "+fun.apply(min)+".", IssueCodes.FUNCTION_ARITY)
		if (e.args.size > max)
			validator.addIssue(e, null, "The function '"+e.name+"' can at most have "+fun.apply(min)+".", IssueCodes.FUNCTION_ARITY)
	}
	
	protected def dispatch XpathType internalResolve(RelativePath e, XpathType contextType, Context ctx) {
		internalResolveStep(e.step, contextType, ctx).install(e)
	}
	
	protected def dispatch XpathType internalResolve(AbsolutePath e, XpathType contextType, Context ctx) {
		if (e.step === null) {
			return Types.nodeSet(#[Linker.ROOT]).install(e)
		}
		return internalResolveStep(e.step, Types.nodeSet(#[Linker.ROOT]), ctx).install(e)
	}

	// step resolution	
	protected def dispatch XpathType internalResolveStep(Void e, XpathType contextType, Context ctx) {
		contextType
	}
	
	protected def dispatch XpathType internalResolveStep(CurrentRef e, XpathType contextType, Context ctx) {
		linker.link(e, YangPackage.Literals.CURRENT_REF__REF) [
			contextType.EObjectDescription	
		]
		return contextType
	}
	
	protected def dispatch XpathType internalResolveStep(ParentRef e, XpathType contextType, Context ctx) {
		if (contextType == Types.ANY) {
			// don't report follow up linking problems
			LinkingErrorMessageProvider.markOK(e);
			return contextType
		}
		val type = computeType(contextType, null, Axis.PARENT, ctx)
		linker.link(e, YangPackage.Literals.PARENT_REF__REF) [
			type.EObjectDescription
		]
		return type
	}
	
	protected def dispatch XpathType internalResolveStep(AbbrevAttributeStep e, XpathType contextType, Context ctx) {
		return Types.STRING
	}
	
	protected def dispatch XpathType internalResolveStep(XpathStep e, XpathType contextType, Context ctx) {
		if (e.axis == 'attribute') {
			LinkingErrorMessageProvider.markOK(e.node)
			return Types.STRING
		}
		if (e.axis == 'namespace') {
			LinkingErrorMessageProvider.markOK(e.node)
			return Types.STRING
		}
		if (e.node instanceof XpathNodeType && (e.node as XpathNodeType).name != 'node' || e.node instanceof ProcessingInstruction) {
			return Types.BOOLEAN	
		}
		if (e.axis == 'self') {
			if (contextType === Types.ANY) {
				LinkingErrorMessageProvider.markOK(e.node)
				return contextType
			}
			if (contextType instanceof NodeSetType) {
				if (!(e.node instanceof XpathNodeType)) {
					val ref = new AtomicReference<XpathType>()
					linker.link(e.node, YangPackage.Literals.XPATH_NAME_TEST__REF) [
						if (it.lastSegment == '*') {
							ref.set(contextType)
							return contextType.EObjectDescription
						} else {
							val descs = contextType.nodes.filter[qualifiedName.lastSegment == qualifiedName.lastSegment].toList
							if (!descs.isEmpty) {
								val newType = Types.nodeSet(descs)
								ref.set(newType)
								return newType.EObjectDescription
							} else {
								return null
							}
						}
					]
					return ref.get
				}
			}
			return contextType
		}
		
		var tempMode = switch e.axis {
			case 'ancestor' : Axis.ANCESTOR
			case 'ancestor-or-self' : Axis.ANCESTOR_OR_SELF
			case 'child' : Axis.CHILDREN
			case 'descendant' : Axis.DESCENDANTS
			case 'descendant-or-self' : Axis.DESCENDANTS_OR_SELF
			case 'following' : Axis.ANCESTOR_OR_SELF
			case 'preceding' : Axis.DESCENDANTS_OR_SELF
			case 'following-sibling' : Axis.SIBLINGS
			case 'preceding-sibling' : Axis.SIBLINGS
			case 'parent' : Axis.PARENT
			default : Axis.CHILDREN
		}
		val mode = switch c : e.eContainer {
			AbsolutePath case c.isDescendants : Axis.DESCENDANTS_OR_SELF
			XpathLocation case c.isDescendants : Axis.DESCENDANTS_OR_SELF
			default : tempMode
		}
		if (e.node instanceof XpathNodeType) {
			// it must be axis::node()
			return computeType(contextType, ASTERISK, mode, ctx)
		}
		if (contextType === Types.ANY) {
			if (e.node !== null)
				LinkingErrorMessageProvider.markOK(e.node)
			return contextType
		}
		if (e.node === null) {
			return Types.ANY
		}
		val ref = new AtomicReference<XpathType>() 
		linker.link(e.node, YangPackage.Literals.XPATH_NAME_TEST__REF) [
			val type = computeType(contextType, resolveModulePrefix(e), mode, ctx)
			ref.set(type)
			return type.EObjectDescription
		]
		return ref.get ?: Types.ANY 
	}
	
	private def QualifiedName resolveModulePrefix(QualifiedName linkName, EObject element) {
		if (linkName.segmentCount > 1) {
			val scopeContext = scopeContextProvider.findScopeContext(element)
			if (scopeContext !== null) {
				val moduleName = scopeContext.importedModules.get(linkName.firstSegment)?.moduleName
					?: if (linkName.firstSegment == element?.mainModule?.prefix) {
						scopeContext.moduleName
					}
				if (moduleName !== null)
					return QualifiedName.create(moduleName).append(linkName.skipFirst(1))	
			}
		}
		return linkName
	}
	
	static enum Axis {
		CHILDREN,
		PARENT,
		SIBLINGS,
		ANCESTOR,
		ANCESTOR_OR_SELF,
		DESCENDANTS,
		DESCENDANTS_OR_SELF
	}
	
	protected def XpathType computeType(XpathType type, QualifiedName name, Axis mode, Context ctx) {
		if (type instanceof NodeSetType) {
			// handle root
			if (type.nodes.empty) {
				val nodes = findNodes(QualifiedName.EMPTY, name, mode, ctx.nodeScope)
				if ( nodes.empty) {
					return Types.ANY
				}
				return Types.nodeSet(nodes)
			}
			val result = newLinkedHashSet()
			for (n : type.nodes) {
				val nodes = findNodes(n.qualifiedName, name, mode, ctx.nodeScope)
				result.addAll(nodes)
			}
			if (!result.empty) {
				return Types.nodeSet(result.toList)
			}
		}
		return Types.ANY
	}
	
	private def QualifiedName skipLast(QualifiedName it) {
		if (segmentCount < 2) {
			return QualifiedName.EMPTY
		} else {
			return skipLast(2)
		}
	}
	
	def List<IEObjectDescription> findNodes(QualifiedName prefix, QualifiedName name, Axis mode, MapScope nodeScope) {
		if (mode === Axis.SIBLINGS) {
			return findNodes(prefix.skipLast, name, Axis.CHILDREN, nodeScope)
		} else if (mode === Axis.DESCENDANTS_OR_SELF) {
			return findNodes(prefix.skipLast, name, Axis.DESCENDANTS, nodeScope)
		} else if (mode == Axis.ANCESTOR) {
			return findNodes(prefix.skipLast, name, Axis.ANCESTOR_OR_SELF, nodeScope)
		} else if (mode == Axis.ANCESTOR_OR_SELF) {
			val result = newArrayList()
			var parent = prefix
			while (parent.segmentCount >= 2) {
				if (name === null || name == ASTERISK || parent.endsWith(name)) {
					val p = nodeScope.getSingleElement(parent)
					if (p !== null && isInstanceNode(p)) {
						result.add(p)
					}
				}
				parent = parent.skipLast
			}
			return result
		} else if (mode == Axis.PARENT) {
			var parent = prefix
			while (parent.segmentCount >= 2) {
				parent = parent.skipLast
				val p = nodeScope.getSingleElement(parent)
				if (p !== null) {
					if (isInstanceNode(p)) {						
						return #[p]
					}
				} else {	
					return #[Linker.ROOT]
				}
			}
			return #[Linker.ROOT]
		} else {
			val elements = nodeScope.allElements.filter [
				if (qualifiedName.startsWith(prefix) && qualifiedName.segmentCount > prefix.segmentCount) {
					if (name === null || name == ASTERISK || qualifiedName.endsWith(name)) {
						if (mode === Axis.DESCENDANTS) {
							return true
						} else {
							// check all intermediate nodes, whether they are schema only nodes
							var parent = qualifiedName.skipLast
							while (parent.segmentCount > prefix.segmentCount) {
								val p = nodeScope.getSingleElement(parent)
								if (p !== null && isInstanceNode(p)) {
									return false
								}
								parent = parent.skipLast
							}
							return true
						}
					}
				}
				return false
			].toSet.toList
			return elements
		}
	}
	
	private def endsWith(QualifiedName parent, QualifiedName child) {
		val offset = parent.segmentCount - child.segmentCount
		if(offset >= 0) 
			return parent.skipFirst(offset) == child
		else
			return false
	}
	
	protected def boolean isInstanceNode(IEObjectDescription description) {
		switch (description.EObjectOrProxy) {
			Choice, Case, Input, Output : false
			default : true 
		}
	}
	
	protected def getEObjectDescription(XpathType type) {
		if (type instanceof NodeSetType) {
			return type.nodes.head				
		}
		return null
	}
}