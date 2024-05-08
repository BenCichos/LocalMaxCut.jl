function cutvalues(graph::Graph, cut::BitVector, node::Int)
    v0, v1 = sum(matrix(graph)[node, .~cut]), sum(matrix(graph)[node, cut])
    cut[node] ? (v0, v1) : (v1, v0)
end

function improvementvalue(graph::Graph{T, N}, cut::BitVector, vertex::Int) where {T <: Real, N}
    current, flipped = cutvalues(graph, cut, vertex)
    flipped - current
end

improvementvalues(graph::Graph{T, N}, cut::BitVector) where {T <: Real, N} = [improvementvalue(graph, cut, vertex) for vertex in 1:N]
