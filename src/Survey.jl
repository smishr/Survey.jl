module Survey

using DataFrames
using Statistics
import Statistics: quantile
using StatsBase
<<<<<<< HEAD
import StatsBase: mean,quantile
using Distributions
=======
import StatsBase: mean, quantile
>>>>>>> main
using CSV
using LinearAlgebra
using CairoMakie
using AlgebraOfGraphics
using CategoricalArrays
using Random
using Missings

include("SurveyDesign.jl")
include("bootstrap.jl")
include("mean.jl")
include("quantile.jl")
include("total.jl")
include("load_data.jl")
include("hist.jl")
include("plot.jl")
include("boxplot.jl")
include("show.jl")
include("ratio.jl")
include("by.jl")
include("ci.jl")

export load_data
export AbstractSurveyDesign, SurveyDesign, ReplicateDesign
export dim, colnames, dimnames
export mean, total, quantile
export plot
export hist, sturges, freedman_diaconis
export boxplot
export bootweights
export ratio

end
