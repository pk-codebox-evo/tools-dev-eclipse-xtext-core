/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.xtext.generator.ui.outline

import com.google.inject.Inject
import org.eclipse.xtext.xtext.generator.AbstractGeneratorFragment2
import org.eclipse.xtext.xtext.generator.XtextGeneratorNaming

/**
 * Contributes the 'Quick Outline' entry to the language editor's context menu. 
 * 
 * @author Christian Schneider - Initial contribution and API
 */
class QuickOutlineFragment2 extends AbstractGeneratorFragment2 {

	@Inject
	extension XtextGeneratorNaming
	
	override generate() {
		if (projectConfig.eclipsePluginManifest != null) {
			projectConfig.eclipsePluginManifest.requiredBundles += "org.eclipse.xtext.ui"
		}
		
		if (projectConfig.eclipsePluginPluginXml != null) {
			projectConfig.eclipsePluginPluginXml.entries += '''
				<!-- Quick Outline -->
				<extension
					point="org.eclipse.ui.handlers">
					<handler 
						class="�grammar.getEclipsePluginExecutableExtensionFactory
							�:org.eclipse.xtext.ui.editor.outline.quickoutline.ShowQuickOutlineActionHandler"
						commandId="org.eclipse.xtext.ui.editor.outline.QuickOutline">
						<activeWhen>
							<reference
								definitionId="�grammar.name�.Editor.opened">
							</reference>
						</activeWhen>
					</handler>
				</extension>
				<extension
					point="org.eclipse.ui.commands">
					<command
						description="Open the quick outline."
						id="org.eclipse.xtext.ui.editor.outline.QuickOutline"
						name="Quick Outline">
					</command>
				</extension>
				<extension point="org.eclipse.ui.menus">
					<menuContribution
						locationURI="popup:#TextEditorContext?after=group.open">
						<command commandId="org.eclipse.xtext.ui.editor.outline.QuickOutline"
							style="push"
							tooltip="Open Quick Outline">
							<visibleWhen checkEnabled="false">
								<reference definitionId="�grammar.name�.Editor.opened"/>
							</visibleWhen>
						</command>
					</menuContribution>
				</extension>
			'''
		}
	}
}