/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.parsetree.reconstr.impl;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.AbstractRule;
import org.eclipse.xtext.Assignment;
import org.eclipse.xtext.GrammarUtil;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.conversion.IValueConverterService;
import org.eclipse.xtext.parsetree.AbstractNode;
import org.eclipse.xtext.parsetree.LeafNode;
import org.eclipse.xtext.parsetree.reconstr.ITokenSerializer;

import com.google.inject.Inject;

/**
 * @author meysholdt - Initial contribution and API
 */
public class DefaultValueSerializer extends AbstractValueSerializer {

	@Inject
	private IValueConverterService converter;

	@Override
	public boolean equalsOrReplacesNode(EObject context, RuleCall ruleCall, AbstractNode node) {
		return ruleCall == node.getGrammarElement();
	}

	@Override
	public boolean equalsOrReplacesNode(EObject context, RuleCall ruleCall, Object value, AbstractNode node) {
		if (ruleCall != node.getGrammarElement())
			return false;
		Assignment ass = GrammarUtil.containingAssignment(ruleCall);
		if (GrammarUtil.isSingleAssignment(ass))
			return true;
		Object converted = converter.toValue(serialize(node), ruleCall.getRule().getName(), node);
		return converted != null && converted.equals(value);
	}

	protected String serialize(AbstractNode node) {
		if (node instanceof LeafNode)
			return ((LeafNode) node).getText();
		else {
			StringBuilder builder = new StringBuilder(node.getLength());
			boolean hiddenSeen = false;
			for (LeafNode leaf : node.getLeafNodes()) {
				if (!leaf.isHidden()) {
					if (hiddenSeen && builder.length() > 0)
						builder.append(' ');
					builder.append(leaf.getText());
					hiddenSeen = false;
				} else {
					hiddenSeen = true;
				}
			}
			return builder.toString();
		}
	}

	@Override
	public String serializeAssignedValue(EObject context, RuleCall ruleCall, Object value, AbstractNode node) {
		if (node != null) {
			Object converted = converter.toValue(serialize(node), ruleCall.getRule().getName(), node);
			if (converted != null && converted.equals(value))
				return ITokenSerializer.KEEP_VALUE_FROM_NODE_MODEL;
		}
		return converter.toString(value, ruleCall.getRule().getName());
	}

	@Override
	public String serializeUnassignedValue(EObject context, RuleCall ruleCall, AbstractNode node) {
		String r = serializeUnassignedValueByRuleCall(ruleCall, context, node);
		if (r != null)
			return r;
		r = serializeUnassignedValueByRule(ruleCall.getRule(), context, node);
		if (r != null)
			return r;
		if (node != null)
			return ITokenSerializer.KEEP_VALUE_FROM_NODE_MODEL;
		throw new IllegalArgumentException("Could not determine the value for the unassigned rulecall of rule "
				+ ruleCall.getRule().getName() + " from within rule " + GrammarUtil.containingRule(ruleCall).getName()
				+ ". You might want to implement " + IValueSerializer.class.getName()
				+ ".serializeUnassignedValue() or modify your implementation to handle this rulecall.");
	}

	protected String serializeUnassignedValueByRule(AbstractRule rule, EObject current, AbstractNode node) {
		// Sorry, but there is no generic default implementation for this yet.
		// A valid implementation would be to automatically derive a valid value
		// for the called rule.
		return null;
	}

	protected String serializeUnassignedValueByRuleCall(RuleCall ruleCall, EObject current, AbstractNode node) {
		// Sorry, but there is no generic default implementation for this yet.
		return null;
	}

}