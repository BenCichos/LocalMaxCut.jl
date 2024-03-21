using LocalMaxCut
using Test

@testset verbose=true "LocalMaxCut.jl" begin
    # Write your tests here.

    @testset "Graph" begin
        graph = Graph{Float64, 100}()
        @test typeof(graph) === Graph{Float64, 100}
        @test order(graph) == 100
        @test size(graph) == (100, 100)
        @test matrix(graph) == zeros(Float64, 100, 100)
        @test edges(graph) == CartesianIndex{2}[]
        @test degrees(graph) == zeros(Int, 100)
    end

    @testset "Generator" begin
        gnp = GNP(100, 0.5)
        @test typeof(gnp) === GNP{100}
        graph = gnp()
        graphs = gnp(5)
        @test typeof(graph) === Graph{Float64, 100}
        @test typeof(graphs) === Vector{Graph{Float64, 100}}
        @test order(graph) == 100
        @test size(graph) == (100, 100)
        @test !isempty(edges(graph))
        @test ~all(iszero, degrees(graph))
    end 
end;
