package io.typefox.yang.formatting2;

import org.eclipse.xtext.formatting2.ITextReplacer;
import org.eclipse.xtext.formatting2.ITextReplacerContext;
import org.eclipse.xtext.formatting2.regionaccess.ITextSegment;

public class QuoteStringReplacer implements ITextReplacer {

	private final ITextSegment region;
	private final boolean prepend;
	
	public QuoteStringReplacer(ITextSegment region, boolean prepend) {
		this.region = region;
		this.prepend = prepend;
	}

	@Override
	public ITextSegment getRegion() {
		return region;
	}

	@Override
	public ITextReplacerContext createReplacements(ITextReplacerContext context) {
		String replacement;
		if(prepend) {
			replacement = "\"" + region.getText();
		} else {
			replacement =  region.getText() + "\"";
		}
		context.addReplacement(region.replaceWith(replacement));
		return context;
	}

}
