using Survey
using Test
using Statistics
using StatsBase
@testset "Survey.jl" begin
    load_sample_data(); 
    dclus1 = svydesign(id=:dnum, weights=:pw, data = apiclus1, fpc=:fpc);
    @test svyby(:api00, dclus1, mean) ≈ 644.1693989071047
    api00_by_cname = svyby(:api00, :cname, dclus1, mean).api00
    @test api00_by_cname ≈ [669.0000000000001, 472.00000000000006, 452.5, 647.2666666666668, 623.25, 519.25, 710.5625000000001, 709.5555555555557, 659.4363636363635, 551.1891891891892, 732.0769230769226]
end