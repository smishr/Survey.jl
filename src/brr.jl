"""
The Balanced Repeated Replication (BRR) method is a variance estimation technique that can be used with survey data to estimate sampling errors. In order to create a ReplicateDesign object using the BRR method, you would need to:

Create replicate weights for each observation in the survey data. The replicate weights are typically created by taking the inverse of the sampling probabilities raised to the power of the number of replicates.

Use the replicate weights to generate the replicate datasets. This can be done by drawing a random sample of observations from the original survey data, with replacement, and weighting the observations by the corresponding replicate weights.

Repeat step 2 a number of times to generate the desired number of replicate datasets.

Here is an example of how you might implement the BRR method to create a ReplicateDesign object from a SurveyDesign object:
"""

"""
    brr(design::SurveyDesign, replicates::Int, rng::Random.AbstractRNG=Random.GLOBAL_RNG)

Creates replicate datasets using the Balanced Repeated Replication method.

# Arguments:
- `design::SurveyDesign`: the survey design that you want to replicate.
- `replicates::Int`: the number of replicates you want to create.
- `rng::Random.AbstractRNG`: the random number generator to use (default is `Random.GLOBAL_RNG`).

# Returns:
- `ReplicateDesign`: the replicate design that includes the replicate datasets, replicate weights and other attributes of the original SurveyDesign.
# Example
```jldoctest
julia> using Random

julia> apiclus1 = load_data("apiclus1");

julia> design = SurveyDesign(apiclus1; clusters = :dnum, popsize=:fpc);

julia> design_rep = brr(design, 1000, rng = MersenneTwister(123))
ReplicateDesign:
data: 183×1000 DataFrame
strata: none
cluster: dnum
    [637, 637, 637  …  448]
popsize: [757, 757, 757  …  757]
sampsize: [15, 15, 15  …  15]
weights: [0.0013, 0.0013, 0.0013  …  0.0013]
allprobs: [0.0198, 0.0198, 0.0198  …  0.0198]
replicates: 1000
"""
using Random

function brr(design::SurveyDesign, replicates::Int, rng::Random.AbstractRNG=Random.GLOBAL_RNG)
    # Create replicate weights
    design.data[!, :replicate_weights] = (design.allprobs .^ (-replicates))

    # Generate replicate datasets
    replicate_data = DataFrame(replicate_weights = [], replicate_indices = [])
    for i in 1:replicates
        replicate_indices = rand(rng, 1:nrow(design.data), nrow(design.data), design.data[!, :replicate_weights])
        replicate_data = vcat(replicate_data, DataFrame(replicate_weights = design.data[replicate_indices, :replicate_weights], replicate_indices = replicate_indices))
    end

    # Create ReplicateDesign object
    return ReplicateDesign(design.data[replicate_data[:, :replicate_indices], :], design.cluster, design.popsize, design.sampsize, design.strata, :replicate_weights, design.allprobs, design.pps, replicates)
end

# Example usage
apiclus1 = load_data("apiclus1")
design = SurveyDesign(apiclus1; clusters = :dnum, popsize=:fpc)
design_rep = brr(design, 1000)
