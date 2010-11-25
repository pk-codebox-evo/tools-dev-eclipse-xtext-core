package org.eclipse.xtext.nodemodel.util;

import org.eclipse.xtext.nodemodel.BidiIterable;
import org.eclipse.xtext.nodemodel.BidiIterator;
import org.eclipse.xtext.nodemodel.INode;

/**
 * @author Sebastian Zarnekow - Initial contribution and API
 */
public class NodeIterable implements BidiIterable<INode> {
	
	private final INode startWith;

	public NodeIterable(INode startWith) {
		this.startWith = startWith;
	}

	public BidiIterator<INode> iterator() {
		return new NodeIterator(startWith);
	}
	
	public BidiIterable<INode> reverse() {
		return new BidiIterable<INode>() {

			public BidiIterator<INode> iterator() {
				BidiIterator<INode> delegate = NodeIterable.this.iterator(); 
				return new ReversedBidiIterator(delegate);
			}

			public BidiIterable<INode> reverse() {
				return NodeIterable.this;
			}
		};
	}
}