package io.typefox.yang.processor

import java.util.List
import io.typefox.yang.processor.ProcessedDataModel.ElementKind
import io.typefox.yang.processor.ProcessedDataModel.AccessKind
import io.typefox.yang.processor.ProcessedDataModel.ModuleData
import io.typefox.yang.processor.ProcessedDataModel.ListData
import io.typefox.yang.processor.ProcessedDataModel.ElementData
import io.typefox.yang.processor.ProcessedDataModel.HasStatements

class DataTreeSerializer {

	def CharSequence serialize(ModuleData moduleData) {
		'''
			module: «moduleData.simpleName»
			  «FOR child : moduleData.getChildren?:#[]»
			  	«doSerialize(child, '', needsConnect(child, moduleData.getChildren))»
			  «ENDFOR»
			
			  rpcs:
			    «FOR rpc : moduleData.getRpcs?:#[]»
			    	«doSerialize(rpc, '', needsConnect(rpc, moduleData.getRpcs))»
			    «ENDFOR»
		'''
	}

	dispatch def CharSequence doSerialize(HasStatements ele, String indent, boolean needsConnect) {
		'''«indent» unsupported data type!'''
	}

	dispatch def CharSequence doSerialize(ElementData ele, String indent, boolean needsConnect) {
		var accessString = "  "
		if(ele.getAccessKind() != AccessKind.not_set) {
			accessString = ele.getAccessKind().name
		}
		val prefix = switch (ele.elementKind) {
			case Case:
				'--:'
			default: {
				'''«"----".substring(accessString.length)»«!accessString.trim.empty?accessString» '''
			}
		}
		val label = switch (ele.elementKind) {
			case Choice,
			case Case: '''(«ele.name»)'''
			default: {
				ele.name
			}
		}
		val keys = if (ele instanceof ListData) {
				ele.getKeys.empty ? null : ''' [«ele.getKeys.join(', ')»]'''
			}

		val type = ele.getType
		// no idea why this indentation is needed in pyang
		val additionalIdent = if(ele.elementKind === ElementKind.Choice && prevSibling(ele)?.elementKind === ElementKind.Container) ' ' else ''
		'''
			«indent»«additionalIdent»+«prefix»«label»«ele.cardinality?.toString()»«keys»«IF type !== null»   «type»«ENDIF»«IF ele.getFeatureConditions !== null» {«ele.getFeatureConditions.join(',')»}?«ENDIF»
			«IF ele.getChildren !== null»
				«FOR child : ele.getChildren»
					«doSerialize(child, indent + (needsConnect?'|  ':'   '), needsConnect(child, ele.getChildren))»
				«ENDFOR»
			«ENDIF»
		'''
	}
	
	private def ElementData prevSibling(ElementData ele) {
		val siblings = ele.getParent?.getChildren
		if(siblings === null) {
			return null
		}
		val eleIdx = siblings.indexOf(ele)
		if(eleIdx > 0) {
			val prevChild = siblings.get(eleIdx - 1)
			if(prevChild instanceof ElementData) {
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
