package io.typefox.yang.diagram

import com.google.inject.Inject
import io.typefox.sprotty.api.SModelElement
import io.typefox.sprotty.api.SelectAction
import java.util.function.Consumer
import org.eclipse.xtext.ide.server.occurrences.DefaultDocumentHighlightService
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.eclipse.xtext.resource.XtextResource
import io.typefox.sprotty.api.FitToScreenAction

class YangHighlightService extends DefaultDocumentHighlightService {
	
	@Inject extension YangLanguageServerExtension
	
	@Inject extension EObjectAtOffsetHelper 
	
	override getDocumentHighlights(XtextResource resource, int offset) {
		val result = super.getDocumentHighlights(resource, offset)
		val element = resolveElementAt(resource, offset)
		if (element !== null) {
			findDiagramServersByUri(resource.URI.toString).forEach [ server |
				val traceables = <Traceable>newArrayList()
				server.model.findTraceablesAtOffset(offset, [
					traceables += it
				])
				if(!traceables.empty) {
					val smallest = traceables.minBy[ traceRegion.length ]
					server.dispatch(new SelectAction [
						selectedElementsIDs = #[(smallest as SModelElement).id] 
						deselectAll = true
					])					
					server.dispatch(new FitToScreenAction [
						maxZoom = 1.0
						elementIds = #[(smallest as SModelElement).id] 
					])					
				}
			]
		}
		return result
	}
	
	protected def void findTraceablesAtOffset(SModelElement root, int offset, Consumer<Traceable> consumer) {
		if (root instanceof Traceable) {
			val traceRegion = root.traceRegion
			if(traceRegion !== null && traceRegion.offset <= offset && traceRegion.offset + traceRegion.length > offset)
				consumer.accept(root)
		}
		root.children?.forEach[
			findTraceablesAtOffset(offset, consumer)
		]
	}
}