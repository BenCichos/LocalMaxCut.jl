function cutvalues(graph::Graph, cut::BitVector, node::Int)
    v0, v1 = sum(matrix(graph)[node, .~cut]), sum(matrix(graph)[node, cut])
    cut[node] ? (v0, v1) : (v1, v0)
end
