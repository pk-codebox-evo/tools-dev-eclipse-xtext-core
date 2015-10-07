/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.xtext.generator.ui.quickfix

import javax.inject.Inject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.Grammar
import org.eclipse.xtext.xtext.generator.AbstractGeneratorFragment2
import org.eclipse.xtext.xtext.generator.CodeConfig
import org.eclipse.xtext.xtext.generator.XtextGeneratorNaming
import org.eclipse.xtext.xtext.generator.model.FileAccessFactory
import org.eclipse.xtext.xtext.generator.model.GuiceModuleAccess
import org.eclipse.xtext.xtext.generator.model.TypeReference
import org.eclipse.xtext.xtext.generator.validation.ValidatorFragment2

import static extension org.eclipse.xtext.xtext.generator.util.GrammarUtil2.*

/**
 * Contributes the Quickfix provider stub, either in Xtend or Java language.
 * 
 * @author Christian Schneider - Initial contribution and API
 */
class QuickfixProviderFragment2 extends AbstractGeneratorFragment2 {

	@Inject
	extension XtextGeneratorNaming

	@Inject
	extension CodeConfig
	
	@Inject
	extension ValidatorFragment2

	@Inject
	FileAccessFactory fileAccessFactory

	@Accessors
	private boolean generateStub = true;

	@Accessors	
	private boolean inheritImplementation;

	def protected TypeReference getQuickfixProviderClass(Grammar g) {
		return new TypeReference(
			grammar.eclipsePluginBasePackage + ".quickfix." + grammar.simpleName + "QuickfixProvider"
		)
	}

	def protected TypeReference getQuickfixProviderSuperClass(Grammar g) {
		val superGrammar = g.getNonTerminalsSuperGrammar;
		if (inheritImplementation && superGrammar != null) 
			superGrammar.quickfixProviderClass
		else
			defaultQuickfixProviderSuperClass
	}

	/**
	 * Extra getter facilitates customization by overriding. 
	 */
	protected def getDefaultQuickfixProviderSuperClass() {
		return new TypeReference("org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider")
	} 

	override generate() {
		val instanceClass = 
			if (generateStub) grammar.quickfixProviderClass else grammar.quickfixProviderSuperClass;

		new GuiceModuleAccess.BindingFactory()
				.addTypeToType(
					new TypeReference("org.eclipse.xtext.ui.editor.quickfix.IssueResolutionProvider"),
					instanceClass
				).contributeTo(language.eclipsePluginGenModule);

		if (!generateStub) {
			return;
		}

		if (projectConfig.eclipsePluginSrc !== null) {
			if (preferXtendStubs) {
				generateXtendQuickfixProvider
			} else {
				generateJavaQuickfixProvider
			}

			projectConfig.eclipsePluginManifest.exportedPackages += grammar.quickfixProviderClass.packageName

			addRegistrationToPluginXml
		}
	}

	protected def generateXtendQuickfixProvider() {
		fileAccessFactory.createXtendFile(grammar.quickfixProviderClass, '''
			/**
			 * Custom quickfixes.
			 *
			 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#quick-fixes
			 */
			class «grammar.quickfixProviderClass.simpleName» extends «grammar.quickfixProviderSuperClass» {
			
			//	@Fix(«grammar.validatorClass».INVALID_NAME)
			//	def capitalizeName(Issue issue, IssueResolutionAcceptor acceptor) {
			//		acceptor.accept(issue, 'Capitalize name', 'Capitalize the name.', 'upcase.png') [
			//			context |
			//			val xtextDocument = context.xtextDocument
			//			val firstLetter = xtextDocument.get(issue.offset, 1)
			//			xtextDocument.replace(issue.offset, 1, firstLetter.toUpperCase)
			//		]
			//	}
			}
		''').writeTo(projectConfig.eclipsePluginSrc)
	}
	
	protected def generateJavaQuickfixProvider() {
		fileAccessFactory.createJavaFile(grammar.quickfixProviderClass, '''
			/**
			 * Custom quickfixes.
			 *
			 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#quick-fixes
			 */
			public class «grammar.quickfixProviderClass.simpleName» extends «grammar.quickfixProviderSuperClass» {
			
			//	@Fix(«grammar.validatorClass».INVALID_NAME)
			//	public void capitalizeName(final Issue issue, IssueResolutionAcceptor acceptor) {
			//		acceptor.accept(issue, "Capitalize name", "Capitalize the name.", "upcase.png", new IModification() {
			//			public void apply(IModificationContext context) throws BadLocationException {
			//				IXtextDocument xtextDocument = context.getXtextDocument();
			//				String firstLetter = xtextDocument.get(issue.getOffset(), 1);
			//				xtextDocument.replace(issue.getOffset(), 1, firstLetter.toUpperCase());
			//			}
			//		});
			//	}
			
			}
		''').writeTo(projectConfig.eclipsePluginSrc)		
	}
	
	protected def addRegistrationToPluginXml() {
		val markerTypePrefix = grammar.eclipsePluginBasePackage + "." + grammar.simpleName.toLowerCase
		val executableExtensionFactory = grammar.eclipsePluginExecutableExtensionFactory

		projectConfig.eclipsePluginPluginXml.entries += '''
		    <!-- quickfix marker resolution generator for «grammar.name» -->
		    <extension
		            point="org.eclipse.ui.ide.markerResolution">
		        <markerResolutionGenerator
		            class="«executableExtensionFactory»:org.eclipse.xtext.ui.editor.quickfix.MarkerResolutionGenerator"
		            markerType="«markerTypePrefix».check.fast">
		            <attribute
		                name="FIXABLE_KEY"
		                value="true">
		            </attribute>
		        </markerResolutionGenerator>
		        <markerResolutionGenerator
		            class="«executableExtensionFactory»:org.eclipse.xtext.ui.editor.quickfix.MarkerResolutionGenerator"
		            markerType="«markerTypePrefix».check.normal">
		            <attribute
		                name="FIXABLE_KEY"
		                value="true">
		            </attribute>
		        </markerResolutionGenerator>
		        <markerResolutionGenerator
		            class="«executableExtensionFactory»:org.eclipse.xtext.ui.editor.quickfix.MarkerResolutionGenerator"
		            markerType="«markerTypePrefix».check.expensive">
		            <attribute
		                name="FIXABLE_KEY"
		                value="true">
		            </attribute>
		        </markerResolutionGenerator>
		    </extension>
		'''		
	}
}