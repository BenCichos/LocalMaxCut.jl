struct GNP{N} <: AbstractGenerator{N}
    probability::Float64
    function GNP{N}(probability::Float64) where {N}
        @assert N > 0 "$N is not a valid graph order. It must be a positive integer."
        @assert 0 <= probability <= 1 "The probability must be between 0 and 1."
        new{N}(probability)
    end
end
export GNP

order(::GNP{N}) where {N} = N
probability(gnp::GNP) = gnp.probability

GNP(order::Int, probability::Float64) = GNP{order}(probability)

function GNP{N}(;degree::T) where {N, T <: Real}
    @assert degree < zero(T) "$degree is not a valid degree. The expected degree of the graph has to be positive"
    GNP{N}(Float64(degree / order))
end

GNP(order::Int; degree::T) where {T <: Real} = GNP{order}(degree=degree)

function getedges(gnp::GNP)
    iszero(probability(gnp)) && return CartesianIndex{2}[]
    edges = CartesianIndex{2}.(Tuple.(combinations(1:order(gnp), 2)))
    isone(probability(gnp)) && return edges
    edges[rand(length(edges)) .< probability(gnp)]
end

getweights(::GNP, n::Int; distribution::UnivariateDistribution{S}=Uniform(0.0,1.0)) where {S <: ValueSupport} = rand(distribution, n)
