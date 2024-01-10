package io.typefox.yang.processor

import java.util.List
import io.typefox.yang.processor.ProcessedDataModel.ElementKind
import io.typefox.yang.processor.ProcessedDataModel.AccessKind
import io.typefox.yang.processor.ProcessedDataModel.ModuleData
import io.typefox.yang.processor.ProcessedDataModel.ListData
import io.typefox.yang.processor.ProcessedDataModel.ElementData
import io.typefox.yang.processor.ProcessedDataModel.HasStatements
import io.typefox.yang.processor.ProcessedDataModel.Status

/**
 * Each node is printed as:

 * <status>--<flags> <name><opts> <type> <if-features>

 *   <status> is one of:
 *     +  for current
 *     x  for deprecated
 *     o  for obsolete

 *   <flags> is one of:
 *     rw  for configuration data
 *     ro  for non-configuration data, output parameters to rpcs
 *         and actions, and notification parameters
 *     -w  for input parameters to rpcs and actions
 *     -u  for uses of a grouping
 *     -x  for rpcs and actions
 *     -n  for notifications

 *   <name> is the name of the node
 *     (<name>) means that the node is a choice node
 *    :(<name>) means that the node is a case node

 *    If the node is augmented into the tree from another module, its
 *    name is printed as <prefix>:<name>.

 *   <opts> is one of:
 *     ?  for an optional leaf, choice, anydata or anyxml
 *     !  for a presence container
 *  for a leaf-list or list
 *     [<keys>] for a list's keys

 *     <type> is the name of the type for leafs and leaf-lists, or
 *            "<anydata>" or "<anyxml>" for anydata and anyxml, respectively

 *     If the type is a leafref, the type is printed as "-> TARGET", where
 *     TARGET is the leafref path, with prefixes removed if possible.

 *   <if-features> is the list of features this node depends on, printed
 *     within curly brackets and a question mark "{...}?"
 */
class DataTreeSerializer {

	def CharSequence serialize(ModuleData moduleData) {
		'''
			module: «moduleData.simpleName»
			  «FOR child : moduleData.getChildren?:#[]»
			  	«doSerialize(child, '', needsConnect(child, moduleData.getChildren))»
			  «ENDFOR»
			«IF moduleData.getRpcs !== null»
				
				  rpcs:
				    «FOR rpc : moduleData.getRpcs»
				    	«doSerialize(rpc, '', needsConnect(rpc, moduleData.getRpcs))»
				    «ENDFOR»
			«ENDIF»
		'''
	}

	dispatch def CharSequence doSerialize(HasStatements ele, String indent, boolean needsConnect) {
		'''«indent» unsupported data type!'''
	}

	dispatch def CharSequence doSerialize(ElementData ele, String indent, boolean needsConnect) {
		var accessString = "  "
		if (ele.getAccessKind() != AccessKind.not_set) {
			accessString = ele.getAccessKind().name
		}
		val prefix = switch (ele.elementKind) {
			case Case:
				'--:'
			default: {
				'''«"----".substring(accessString.length)»«!accessString.trim.empty?accessString» '''
			}
		}

		// no idea why this indentation is needed in pyang
		val additionalIdent = if(ele.elementKind === ElementKind.Choice &&
				prevSibling(ele)?.elementKind === ElementKind.Container) ' ' else ''
		val status = ele.status?:Status.current
		val flags = ele.cardinality?.toString()
		val name = switch (ele.elementKind) {
			case Choice,
			case Case: '''(«ele.name»)'''
			default: {
				ele.name
			}
		}

		val keys = if (ele instanceof ListData) {
				ele.getKeys.empty ? ' []' : ''' [«ele.getKeys.join(' ')»]'''
			}

		val type = ele.getType
		'''
			«indent»«additionalIdent»«status»«prefix»«name»«flags»«keys»«IF type !== null»   «type»«ENDIF»«IF ele.getFeatureConditions !== null» {«ele.getFeatureConditions.join(',')»}?«ENDIF»
			«IF ele.getChildren !== null»
				«FOR child : ele.getChildren»
					«doSerialize(child, indent + (needsConnect?'|  ':'   '), needsConnect(child, ele.getChildren))»
				«ENDFOR»
			«ENDIF»
		'''
	}

	private def ElementData prevSibling(ElementData ele) {
		val siblings = ele.getParent?.getChildren
		if (siblings === null) {
			return null
		}
		val eleIdx = siblings.indexOf(ele)
		if (eleIdx > 0) {
			val prevChild = siblings.get(eleIdx - 1)
			if (prevChild instanceof ElementData) {
				return prevChild
			}
		}
	}

	private def boolean needsConnect(HasStatements ele, List<HasStatements> siblings) {
		if (siblings === null || siblings.last === ele) {
			return false
		}
		return true
	}

}
