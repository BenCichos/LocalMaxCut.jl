# define Pivot types

struct FirstPivot <: AbstractPivot end
struct RandomPivot <: AbstractPivot end
struct SecondPivot <: AbstractPivot end
struct BetterPivot <: AbstractPivot end
struct BestPivot <: AbstractPivot end
struct SecondBestPivot <: AbstractPivot end
struct WorstPivot <: AbstractPivot end

initialise(p::P, ::Graph) where {P<:AbstractPivot} = p

# define DegreePivot types
struct HighestDegreePivot <: AbstractDegreePivot end
struct LowestDegreePivot <: AbstractDegreePivot end

struct _InternalDegreePivot <: AbstractDegreePivot
    sort_perm::Vector{Int}
end
sort_perm(pivot::_InternalDegreePivot) = pivot.sort_perm

initialise(::HighestDegreePivot, graph::Graph) = _InternalDegreePivot(sortperm(degrees(graph), rev=true))
initialise(::LowestDegreePivot, graph::Graph) = _InternalDegreePivot(sortperm(degrees(graph)))

# define AnyPivot types

struct AnyPivot{N} <: AbstractAnyPivot{N} end
struct AnyBetterPivot{N} <: AbstractAnyPivot{N} end
struct AnyBestPivot{N} <: AbstractAnyPivot{N} end
struct AnyWorstPivot{N} <: AbstractAnyPivot{N} end

(anypivot::Type{A})(n::Int) where {A<:AbstractAnyPivot} = anypivot{n}()
export AnyPivot, AnyBetterPivot, AnyBestPivot, AnyWorstPivot

const PIVOT_FIRST = FirstPivot()
const PIVOT_SECOND = SecondPivot()
const PIVOT_RANDOM = RandomPivot()
const PIVOT_BETTER = BetterPivot()
const PIVOT_BEST = BestPivot()
const PIVOT_SECOND_BEST = SecondBestPivot()
const PIVOT_WORST = WorstPivot()
const PIVOT_DEGREE_HIGHEST = HighestDegreePivot()
const PIVOT_DEGREE_LOWEST = LowestDegreePivot()
export PIVOT_FIRST, PIVOT_SECOND, PIVOT_RANDOM, PIVOT_BETTER, PIVOT_BEST, PIVOT_SECOND_BEST, PIVOT_WORST, PIVOT_DEGREE_HIGHEST, PIVOT_DEGREE_LOWEST

string(pivot_rule::AbstractPivot) = replace("$pivot_rule", "Pivot()" => "") |> lowercase
string(pivot_rule::AbstractAnyPivot{N}) where {N} = replace("$pivot_rule", "Pivot()" => "$N") |> lowercase
