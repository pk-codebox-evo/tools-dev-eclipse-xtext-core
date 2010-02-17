/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.parser.antlr;

/**
 * @author Sebastian Zarnekow - Initial contribution and API
 */
public class SyntaxErrorMessageProvider implements ISyntaxErrorMessageProvider {

	public SyntaxErrorMessage getSyntaxErrorMessage(IParserErrorContext context) {
		return new SyntaxErrorMessage(context.getDefaultMessage(), null);
	}
	
	public SyntaxErrorMessage getSyntaxErrorMessage(IValueConverterErrorContext context) {
		return new SyntaxErrorMessage(context.getDefaultMessage(), null);
	}
}