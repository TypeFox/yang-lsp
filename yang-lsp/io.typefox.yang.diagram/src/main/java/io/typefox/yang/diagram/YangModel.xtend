/*
 * Copyright (C) 2017-2020 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at http://www.apache.org/licenses/LICENSE-2.0
 */
package io.typefox.yang.diagram

import org.eclipse.sprotty.Layouting
import org.eclipse.sprotty.SNode
import org.eclipse.sprotty.SShapeElement
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class YangNode extends SNode {
	Boolean expanded
}

@Accessors 
class YangTag extends SShapeElement implements Layouting {
	String layout
	
	new() {}
	new((YangTag)=>void initializer) {
		initializer.apply(this)
	}
}