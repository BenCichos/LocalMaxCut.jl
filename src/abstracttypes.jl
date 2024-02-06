#################### 
## Abstract Graph ##
####################

abstract type AbstractGraph{T <: Real, N} end

######################## 
## Abstract Generator ##
########################

abstract type AbstractGenerator{N} end

function (generator::AbstractGenerator{N})() where {N}
    @assert N > 0 "$N is not a valid graph order. It must be a positive integer."
    edges = getedges(generator)
    weights = getweights(generator, length(edges))
    Graph(N, edges, weights)
end

(generator::AbstractGenerator)(number::Int) = [generator() for _ in 1:number]