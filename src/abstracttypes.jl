####################
## Abstract Graph ##
####################

abstract type AbstractGraph{T <: Real, N} end
export AbstractGraph

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

(generator::AbstractGenerator)(number::Int) = map(_ -> generator(), 1:number)


########################
## Abstract Partition ##
########################

abstract type AbstractPartition end


####################
## Abstract Pivot ##
####################

abstract type AbstractPivot end
abstract type AbstractAnyPivot{N}  <: AbstractPivot end
abstract type AbstractDegreePivot <: AbstractPivot end
