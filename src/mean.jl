"""
    mean(var, design)

Compute the estimated mean of one or more variables within a survey design.

```jldoctest
julia> apiclus1 = load_data("apiclus1");

julia> clus_one_stage = SurveyDesign(apiclus1; clusters = :dnum, weights = :pw) |> bootweights;

julia> mean(:api00, clus_one_stage)
1×2 DataFrame
 Row │ mean     SE
     │ Float64  Float64
─────┼──────────────────
   1 │ 644.169  23.2877

julia> mean([:api00, :enroll], clus_one_stage)
2×3 DataFrame
 Row │ names   mean     SE
     │ String  Float64  Float64
─────┼──────────────────────────
   1 │ api00   644.169  23.2877
   2 │ enroll  549.716  46.2597
```
"""
function mean(x::Symbol, design::ReplicateDesign; ci_type::Union{Nothing,String}=nothing, kwargs...)
    X = mean(design.data[!, x], weights(design.data[!,design.weights]))
    Xt = [mean(design.data[!, x], weights(design.data[! , "replicate_"*string(i)])) for i in 1:design.replicates]
    variance = sum((Xt .- X).^2) / design.replicates
    SE = sqrt(variance)
    if !isnothing(ci_type)
        ci_lower, ci_upper = _ci(X, SE, ci_type; kwargs...)
        return DataFrame(mean = X, SE = SE, ci_lower = ci_lower, ci_upper = ci_upper )
    else
        return DataFrame(mean = X, SE = SE)
    end
end

function mean(x::Vector{Symbol}, design::ReplicateDesign)
    df = reduce(vcat, [mean(i, design) for i in x])
    insertcols!(df, 1, :names => String.(x))
    return df
end

"""
    mean(var, domain, design)

Compute the estimated mean within a domain.

```jldoctest
julia> apiclus1 = load_data("apiclus1");

julia> clus_one_stage = SurveyDesign(apiclus1; clusters = :dnum, weights = :pw) |> bootweights;

julia> mean(:api00, :cname, clus_one_stage)
11×3 DataFrame
 Row │ cname        mean     SE
     │ String15     Float64  Any
─────┼───────────────────────────────────
   1 │ Santa Clara  732.077  59.6794
   2 │ San Diego    659.436  2.63657
   3 │ Merced       519.25   8.18989e-15
   4 │ Los Angeles  647.267  47.7685
   5 │ Orange       710.563  2.21461e-13
   6 │ Fresno       472.0    1.13687e-13
   7 │ Plumas       709.556  1.26823e-13
   8 │ Alameda      669.0    1.26888e-13
   9 │ San Joaquin  551.189  2.17297e-13
  10 │ Kern         452.5    0.0
  11 │ Mendocino    623.25   1.09409e-13
```
"""
function mean(x::Symbol, domain::Symbol, design::ReplicateDesign)
    weighted_mean(x, w) = mean(x, StatsBase.weights(w))
    df = bydomain(x, domain, design, weighted_mean)
    rename!(df, :statistic => :mean)
    return df
end
