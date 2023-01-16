"""
    quantile(var, design, p; kwargs...)
Estimate quantiles for a complex survey.

Hyndman and Fan compiled a taxonomy of nine algorithms to estimate quantiles. These are implemented in Statistics.quantile, which this function calls.
The Julia, R and Python-numpy use the same defaults

# References:
- Hyndman, R.J and Fan, Y. (1996) ["Sample Quantiles in Statistical Packages"](https://www.amherst.edu/media/view/129116/original/Sample+Quantiles.pdf), The American Statistician, Vol. 50, No. 4, pp. 361-365.
- [Quantiles](https://en.m.wikipedia.org/wiki/Quantile) on wikipedia
- [Complex Surveys: a guide to analysis using R](https://r-survey.r-forge.r-project.org/svybook/), Section 2.4.1 and Appendix C.4.

```jldoctest
julia> apisrs = load_data("apisrs");

julia> srs = SurveyDesign(apisrs; weights=:pw);

julia> quantile(:api00,srs,0.5)
1×2 DataFrame
 Row │ probability  quantile 
     │ Float64      Float64  
─────┼───────────────────────
   1 │         0.5     659.0

julia> quantile(:enroll,srs,[0.1,0.2,0.5,0.75,0.95])
5×2 DataFrame
 Row │ probability  quantile 
     │ Float64      Float64  
─────┼───────────────────────
   1 │        0.1      245.5
   2 │        0.2      317.6
   3 │        0.5      453.0
   4 │        0.75     668.5
   5 │        0.95    1473.1
```
"""
function quantile(var::Symbol, design::SurveyDesign, p::Union{<:Real,Vector{<:Real}}; 
    alpha::Float64=0.05, ci::Bool=false, se::Bool=false, qrule="hf7",kwargs...)
    v = design.data[!, var]
    probs = design.data[!, design.allprobs]
    df = DataFrame(probability=p, quantile=Statistics.quantile(v, ProbabilityWeights(probs), p))
    # TODO: Add CI and SE of the quantile
    return df
end

using Statistics: quantile

function weighted_quantile(x::AbstractVector, w::AbstractVector, q::Real, type=7)
    n = length(x)
    xw = x .* w
    sw = sum(w)
    xw_sorted, w_sorted = sort(xw, w)
    cdf = cumsum(w_sorted) / sw
    p = q * n
    if type == 7
        # Hyndman and Fan (1996) type 7 quantile
        h = n * q + p
        j = floor(h)
        g = h - j
        if j == 0
            quant = xw_sorted[1]
        elseif j == n
            quant = xw_sorted[n]
        else
            quant = (1 - g) * xw_sorted[j] + g * xw_sorted[j + 1]
        end
    else
        # Other types of quantiles as defined by Hyndman and Fan (1996)
        j = floor(p + type)
        g = p + type - j
        if j == 0
            quant = xw_sorted[1]
        elseif j == n
            quant = xw_sorted[n]
        else
            quant = (1 - g) * xw_sorted[j] + g * xw_sorted[j + 1]
        end
    end
    return quant / sum(w)
end

function quantile(design::ReplicateDesign, q::Real, type=7)
    n = nrow(design.data)
    x = design.data[:, :x]
end