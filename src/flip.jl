# Implement Flip Function for each Pivot Rule

function flip(::FirstPivot, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N}
    for vertex in 1:N
        current, flipped = cutvalues(graph, cut, vertex)
        improvement = flipped - current
        (improvement > zero(T)) && return vertex, improvement
    end
    return 0, zero(T)
end

function flip(::SecondPivot, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N}
    pivots_found = 0
    current_pivot, current_improvement = 0, zero(T)
    for vertex in 1:N
        current, flipped = cutvalues(graph, cut, vertex)
        improvement = flipped - current
        (improvement <= zero(T)) && continue
        pivots_found += 1
        (pivots_found == 2) && return vertex, improvement
        current_pivot, current_improvement = vertex, improvement
    end
    return current_pivot, current_improvement
end

function flip(::BetterPivot, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N}
    pivots_found = 0
    current_pivot, current_improvement = 0, zero(T)
    for vertex in 1:N
        current, flipped = cutvalues(graph, cut, vertex)
        improvement = flipped - current
        (improvement <= current_improvement) && continue
        pivots_found += 1
        (pivots_found == 2) && return vertex, improvement
        current_pivot, current_improvement = vertex, improvement
    end
    return current_pivot, current_improvement
end

function flip(::RandomPivot, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N}
    for vertex in shuffle(1:N)
        current, flipped = cutvalues(graph, cut, vertex)
        improvement = flipped - current
        (improvement > zero(T)) && return vertex, improvement
    end
    return 0, zero(T)
end

function flip(::BestPivot, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N}
    current_pivot, current_improvement = 0, zero(T)
    for vertex in 1:N
        current, flipped = cutvalues(graph, cut, vertex)
        improvement = flipped - current
        (improvement <= current_improvement) && continue
        current_pivot, current_improvement = vertex, improvement
    end
    return current_pivot, current_improvement
end

function flip(::SecondBestPivot, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N}
    previous_pivot, previous_improvement = 0, zero(T)
    current_pivot, current_improvement = 0, zero(T)
    for vertex in 1:N
        current, flipped = cutvalues(graph, cut, vertex)
        improvement = flipped - current
        (improvement <= current_improvement) && continue
        previous_pivot, previous_improvement = current_pivot, current_improvement
        current_pivot, current_improvement = vertex, improvement
    end
    return previous_pivot, previous_improvement
end

function flip(::WorstPivot, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N}
    current_pivot, current_improvement = 0, typemax(T)
    for vertex in 1:N
        current, flipped = cutvalues(graph, cut, vertex)
        improvement = flipped - current
        (improvement <= zero(T)) && continue
        (improvement >= current_improvement) && continue
        current_pivot, current_improvement = vertex, improvement
    end
    current_improvement = (current_improvement == typemax(T)) ? zero(T) : current_improvement
    return current_pivot, current_improvement
end

#########################
## AbstractDegreePivot ##
#########################

function flip(pivot::_InternalDegreePivot, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N}
    for vertex in sort_perm(pivot)
        current, flipped = cutvalues(graph, cut, vertex)
        improvement = flipped - current
        (improvement >= zero(T)) && return vertex, improvement
    end
    return 0, zero(T)
end

######################
## AbstractAnyPivot ##
######################

function flip(::AnyBetterPivot{M}, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N, M}
    pivots_found = 0
    current_pivot, current_improvement = 0, zero(T)
    for vertex in 1:N
        current, flipped = cutvalues(graph, cut, vertex)
        improvement = flipped - current
        (improvement <= current_improvement) && continue
        pivots_found += 1
        (pivots_found == M) && return vertex, improvement
        current_pivot, current_improvement = vertex, improvement
    end
    return current_pivot, current_improvement
end

function flip(::AnyBestPivot{M}, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N, M}
    improvements = improvementvalues(graph, cut)
    sorted = sortperm(improvements, rev=true)
    current_pivot, current_improvement = 0, zero(T)
    first(improvements[sorted]) <= zero(T) && return 0, zero(T)
    pivots_found = 0
    for vertex in sorted
        improvement = improvements[vertex]
        (improvement <= zero(T)) && return current_pivot, current_improvement
        (improvement == current_improvement) && continue
        pivots_found += 1
        (pivots_found == M) && return vertex, improvement
        current_pivot, current_improvement = vertex, improvement
    end
    return current_pivot, current_improvement
end

function flip(::AnyWorstPivot{M}, graph::Graph{T, N}, cut::BitVector) where {T <: Real, N, M}
    improvements = improvementvalues(graph, cut)
    sorted = sortperm(improvements)
    current_pivot, current_improvement = 0, zero(T)
    last(improvements[sorted]) <= zero(T) && return current_pivot, current_improvement
    pivots_found = 0
    for vertex in sorted
        improvement = improvements[vertex]
        (improvement <= zero(T)) && continue
        (improvement == current_improvement) && continue
        pivots_found += 1
        (pivots_found == M) && return vertex, improvement
        current_pivot, current_improvement = vertex, improvement
    end
    return current_pivot, current_improvement
end
