package io.typefox.yang.processor

import io.typefox.yang.processor.ProcessedDataTree.AccessKind
import io.typefox.yang.processor.ProcessedDataTree.ElementData
import io.typefox.yang.processor.ProcessedDataTree.HasStatements
import io.typefox.yang.processor.ProcessedDataTree.ModuleData
import java.util.List
import io.typefox.yang.processor.ProcessedDataTree.ListData

class DataTreeSerializer {

	def CharSequence serialize(ModuleData moduleData) {
		'''
			module: «moduleData.name»
			  «FOR child : moduleData.children»
			  	«doSerialize(child, '', needsConnect(child, moduleData.children))»
			  «ENDFOR»
			
			  rpcs:
			    «FOR rpc : moduleData.rpcs»
			    	«doSerialize(rpc, '', needsConnect(rpc, moduleData.rpcs))»
			    «ENDFOR»
		'''
	}

	dispatch def CharSequence doSerialize(HasStatements ele, String indent, boolean needsConnect) {
		'''«indent» unsupported data type!'''
	}

	dispatch def CharSequence doSerialize(ElementData ele, String indent, boolean needsConnect) {
		var accessString = 'rw'
		val access = ele.getAccessKind
		if (access !== AccessKind.not_set) {
			accessString = access.name
		}
		val prefix = switch (ele.elementKind) {
			case Case:
				'--:'
			default: {
				'''«"----".substring(accessString.length)»«accessString» '''
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
				ele.keys.empty ? null : ''' [«ele.keys.join(', ')»]'''
			}

		val type = ele.getType
		
		'''
			«indent»+«prefix»«label»«ele.cardinality?.toString()»«keys»«IF type !== null»   «type»«ENDIF»«IF ele.featureConditions !== null» {«ele.featureConditions.join(',')»}?«ENDIF»
			«IF ele.children !== null»
				«FOR child : ele.children»
					«doSerialize(child, indent + (needsConnect?'|  ':'   '), needsConnect(child, ele.children))»
				«ENDFOR»
			«ENDIF»
		'''
	}

	private def boolean needsConnect(HasStatements ele, List<HasStatements> siblings) {
		if (siblings === null || siblings.last === ele) {
			return false
		}
		return true
	}
}
