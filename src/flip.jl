# Implement Flip Function for each Pivot Rule

flip(::FirstPivot, graph::Graph, cut::BitVector) = findimprovement(graph, cut)

function findimprovement(graph::Graph{T, N}, cut::BitVector) where {N, T <: Real}
    for vertex in 1:N
        current, flipped = cutvalues(graph, cut, vertex)
        improvement = flipped - current
        (improvement > zero(T)) && return vertex, improvement
    end
    return 0, zero(T)
end
