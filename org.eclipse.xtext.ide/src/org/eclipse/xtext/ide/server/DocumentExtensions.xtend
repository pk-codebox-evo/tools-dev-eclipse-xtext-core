/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.ide.server

import com.google.inject.Inject
import com.google.inject.Singleton
import io.typefox.lsapi.impl.LocationImpl
import io.typefox.lsapi.impl.PositionImpl
import io.typefox.lsapi.impl.RangeImpl
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.ILocationInFileProvider
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.ITextRegion

import static extension org.eclipse.xtext.nodemodel.util.NodeModelUtils.*

/**
 * @author kosyakov - Initial contribution and API
 * @since 2.11
 */
@Singleton
class DocumentExtensions {

	@Inject
	extension UriExtensions

	@Inject
	ILocationInFileProvider locationInFileProvider

	def PositionImpl newPosition(Resource resource, int offset) {
		if (resource instanceof XtextResource) {
			val rootNode = resource.parseResult.rootNode
			val lineAndColumn = rootNode.getLineAndColumn(offset)
			return new PositionImpl(lineAndColumn.line - 1, lineAndColumn.column - 1)
		}
		return null
	}

	def RangeImpl newRange(Resource resource, int startOffset, int endOffset) {
		val startPosition = resource.newPosition(startOffset)
		val endPosition = resource.newPosition(endOffset)
		return new RangeImpl(startPosition, endPosition)
	}

	def RangeImpl newRange(Resource resource, ITextRegion region) {
		if (region === null) return null
		return resource.newRange(region.offset, region.offset + region.length)
	}

	def LocationImpl newLocation(Resource resource, ITextRegion textRegion) {
		val location = new LocationImpl
		location.uri = resource.URI.toPath
		location.range = resource.newRange(textRegion)
		return location
	}

	def LocationImpl newLocation(EObject object) {
		val resource = object.eResource
		val textRegion = locationInFileProvider.getSignificantTextRegion(object)
		return resource.newLocation(textRegion)
	}

	def LocationImpl newLocation(EObject owner, EStructuralFeature feature, int indexInList) {
		val resource = owner.eResource
		val textRegion = locationInFileProvider.getSignificantTextRegion(owner, feature, indexInList)
		return resource.newLocation(textRegion)
	}

}
