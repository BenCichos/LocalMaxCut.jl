###############
## GNP Model ##
###############

struct GNP{N} <: AbstractGenerator{N}
    probability::Float64
    distribution::UnivariateDistribution
    function GNP{N}(probability::Float64, distribution::UnivariateDistribution) where {N}
        @assert N > 0 "$N is not a valid graph order. It must be a positive integer."
        @assert 0 <= probability <= 1 "The probability must be between 0 and 1."
        new{N}(probability, distribution)
    end
end
export GNP

order(::GNP{N}) where {N} = N
probability(gnp::GNP) = gnp.probability
distribution(gnp::GNP) = gnp.distribution

GNP(order::Int, probability::Float64, distribution::UnivariateDistribution) = GNP{order}(probability, distribution)

function GNP{N}(distribution::UnivariateDistribution; degree::T) where {N,T<:Real}
    @assert degree >= zero(T) "$degree is not a valid degree. The expected degree of the graph has to be positive"
    probability = degree / N |> Float64
    GNP{N}(probability, distribution)
end

GNP(order::Int; degree::T) where {T<:Real} = GNP{order}(degree=degree)

function getedges(gnp::GNP)
    iszero(probability(gnp)) && return CartesianIndex{2}[]
    edges = CartesianIndex{2}.(Tuple.(combinations(1:order(gnp), 2)))
    isone(probability(gnp)) && return edges
    edges[rand(length(edges)).<probability(gnp)]
end

getweights(gnp::GNP, n::Int)= rand(distribution(gnp), n)

######################
## Smooth GNP Model ##
######################

struct SmoothGNP{N} <: AbstractGenerator{N}
    gnp::GNP{N}
    phi::Float64
    edges::Vector{CartesianIndex{2}}
    weights::Vector{Float64}

    function SmoothGNP{N}(gnp::GNP{N}, phi::Float64, edges::Vector{CartesianIndex{2}}, weights::Vector{Float64}) where {N}
        @assert N > 0 "$N is not a valid graph order. It must be a positive integer."
        @assert 0 <= phi "The smoothing parameter must be non-negative."
        @assert length(edges) == length(weights) "The number of edges and weights must be the same."
        new{N}(gnp, phi, edges, weights)
    end
end

function SmoothGNP{N}(probability::Float64, phi::Float64) where {N}
    @assert 0 <= probability <= 1 "The probability must be between 0 and 1."
    gnp = GNP{N}(probability)
    edges = getedges(gnp)
    SmoothGNP{N}(gnp, phi, edges, getweights(gnp, length(edges)))
end

SmoothGNP(order::Int, probability::Float64, phi::Float64) = SmoothGNP{order}(probability, phi)

function SmoothGNP{N}(; degree::T, phi::Float64) where {N,T<:Real}
    @assert degree >= zero(T) "$degree is not a valid degree. The expected degree of the graph has to be positive"
    SmoothGNP{N}(Float64(degree / N), phi)
end

SmoothGNP(order::Int; degree::T, phi::Float64) where {T<:Real} = SmoothGNP{order}(degree=degree, phi=phi)

SmoothGNP(graph::Graph{Float64}, phi::Float64) = SmoothGNP{order(graph)}(GNP(order(graph), 0.0), phi, edges(graph), weights(graph))

order(::SmoothGNP{N}) where {N} = N
probability(smoothgnp::SmoothGNP) = smoothgnp.gnp.probability
phi(smoothgnp::SmoothGNP) = smoothgnp.phi
gnp(smoothgnp::SmoothGNP) = smoothgnp.gnp
edges(smoothgnp::SmoothGNP) = smoothgnp.edges
weights(smoothgnp::SmoothGNP) = map(weight -> sample_distributions(weight, phi(smooth)), gnpweights(smooth))
gnpweights(smooth::SmoothGNP) = smooth.weights

getedges(smooth::SmoothGNP) = edges(smooth)
getweights(smooth::SmoothGNP, ::Int) = weights(smooth)

function sample_distributions(lower_bound::W, phi::T) where {W<:Real,T<:Real}
    upper_bound = lower_bound + 1 / phi
    upper_bound = upper_bound > one(W) ? one(W) : upper_bound
    rand(Uniform(lower_bound, upper_bound))
end

# Implement convenience generating functions

generate(gnp::GNP) = gnp()
generate(gnp::GNP, n::Int) = map(_ -> gnp(), 1:n)
generate(smooth::SmoothGNP) = smooth()
generate(smooth::SmoothGNP, n::Int) = map(_ -> smooth(), 1:n)

generategnp(smooth::SmoothGNP) = Graph(order(smooth), edges(smooth), gnpweights(smooth))

function (smooth::SmoothGNP)(type::Symbol)
    type == :smooth && return smooth()
    type == :gnp && return generategnp(smooth)
    type == :both && return (generategnp(smooth), smooth())
    error("The type $type is not supported.")
end

function (smooth::SmoothGNP)(n::Int, type::Symbol)
    type == :smooth && return map(_ -> smooth(), 1:n)
    type == :gnp && return generategnp(smooth)
    type == :both && return (generategnp(smooth), map(_ -> smooth(), 1:n))
    error("The type $type is not supported.")
end

#########################
## Configuration Model ##
#########################

struct ConfigurationModel{N} <: AbstractGenerator{N}
    degrees::Vector{Int}

    function ConfigurationModel(degrees::Vector{Int}; make_even::Bool=false)
        N = length(degrees)
        @assert minimum(degrees) >= 0 "All degrees need to be positive"
        @assert maximum(degrees) < N "Degrees need to be smaller than the number of nodes"
        degree_sum = sum(degrees)
        make_even || @assert iseven(degree_sum) "Degree sequence needs to sum to an even number. Set make_even to true to automatically adjust the sequence."
        isodd(degree_sum) && (degrees[N] == N - 1 ? degrees[N] -= 1 : degrees[N] += 1)

        new{N}(degrees)
    end
end

ConfigurationModel{N}(distribution::DiscreteUnivariateDistribution) where {N} = ConfigurationModel(rand(distribution, N), make_even=true)
ConfigurationModel(distribution::DiscreteUnivariateDistribution, N::Int) = ConfigurationModel{N}(distribution)
export ConfigurationModel

order(::ConfigurationModel{N}) where {N} = N
degrees(c::ConfigurationModel) = c.degrees

function getedges(c::ConfigurationModel)
    edge_stubs = collect(Iterators.flatmap(i -> fill(i, degrees(c)[i]), 1:order(c)))
    edges = Set{CartesianIndex{2}}()
    while !isempty(edge_stubs)
        source = popat!(edge_stubs, rand(eachindex(edge_stubs)))
        target = popat!(edge_stubs, rand(eachindex(edge_stubs)))
        source != target && push!(edges, CartesianIndex(source, target))
    end
    collect(edges)
end

getweights(::ConfigurationModel, n::Int) = rand(Uniform(0.0, 1.0), n)
export getedges, getweights
