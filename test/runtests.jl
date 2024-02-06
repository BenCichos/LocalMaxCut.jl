using LocalMaxCut
using Test

@testset "LocalMaxCut.jl" begin
    # Write your tests here.

    @test typeof(GNP(100, 0.5)) === GNP{100}
    @test typeof(GNP(100, 0.5)()) === Graph{Float64, 100}
end
