# define Pivot types

struct FirstPivot <: AbstractPivot end
struct RandomPivot <: AbstractPivot end
struct SecondPivot <: AbstractPivot end
struct BetterPivot <: AbstractPivot end
struct BestPivot <: AbstractPivot end
struct SecondBestPivot <: AbstractPivot end
struct WorstPivot  <: AbstractPivot end
struct DegreeFirstPivot <: AbstractPivot end
struct DegreeLastPivot <: AbstractPivot end

# define AnyPivot types

struct AnyPivot{N} <: AbstractAnyPivot{N} end
struct AnyBetterPivot{N} <: AbstractAnyPivot{N} end
struct AnyBestPivot{N} <: AbstractAnyPivot{N} end
struct AnyWorstPivot{N} <: AbstractAnyPivot{N} end

(anypivot::Type{A})(n::Int) where {A <: AbstractAnyPivot} = anypivot{n}()

const PIVOT_FIRST = FirstPivot()
const PIVOT_SECOND = SecondPivot()
const PIVOT_RANDOM = RandomPivot()
const PIVOT_BETTER = BetterPivot()
const PIVOT_BEST = BestPivot()
const PIVOT_SECOND_BEST = SecondBestPivot()
const PIVOT_WORST = WorstPivot()
const PIVOT_DEGREE_FIRST = DegreeFirstPivot()
const PIVOT_DEGREE_LAST = DegreeLastPivot()

string(pivot_rule::AbstractPivot) = replace("$pivot_rule", "Pivot()" => "") |> lowercase
string(pivot_rule::AbstractAnyPivot{N}) where {N} = replace("$pivot_rule", "Pivot()" => "$N") |> lowercase
