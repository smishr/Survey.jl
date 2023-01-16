"""Can you modify above structures so that multi stage sampling is done using complete information about finite population sizes, fpc, and cluster info for each stage"""

struct SurveyDesign <: AbstractSurveyDesign
    data::AbstractDataFrame
    strata::Symbol
    clusters::Vector{Symbol} # changed to Vector{Symbol} to support multi-stage sampling
    weights::Symbol
    fpc::Symbol # added field for finite population size
    stage_clusters::Vector{Symbol} # added field for cluster information for each stage
    function SurveyDesign(data::AbstractDataFrame;
        strata::Union{Nothing,Symbol}=nothing,
        clusters::Vector{Union{Nothing,Symbol}}=nothing,
        weights::Union{Nothing,Symbol}=nothing,
        fpc::Union{Nothing,Symbol}=nothing,
        stage_clusters::Vector{Union{Nothing,Symbol}}=nothing
    )
        # sampsize here is number of clusters completely sampled, popsize is total clusters in population
        if typeof(strata) <: Nothing
            data.false_strata = repeat(["FALSE_STRATA"], nrow(data))
            strata = :false_strata
        end
        if typeof(clusters) <: Nothing
            data.false_cluster = 1:nrow(data)
            cluster = :false_cluster
        end
        if typeof(fpc) <: Nothing
            data.false_fpc = repeat(1, nrow(data))
            fpc = :false_fpc
        end
        if typeof(stage_clusters) <: Nothing
            data.false_stage_clusters = repeat(1, nrow(data))
            stage_clusters = :false_stage_clusters
        end
        if isa(weights, Symbol)
            data[!, :weights] = data[!, weights]./data[!, fpc]
        end
        if isa(stage_clusters, Vector{Symbol})
            if length(clusters) != length(stage_clusters)
                error("Number of clusters and number of stage clusters must match")
            end
        end
        new(data, strata, clusters, weights, fpc, stage_clusters)
    end
end

"""
The above struct has clusters field of type Vector{Symbol} to support multi-stage sampling. A new field fpc is added to store the finite population size information and stage_clusters field added to store the cluster information for each stage of sampling.

It also checks if the number of clusters and number of stage clusters match. If not, it will throw an error. The weights field is calculated by dividing the sampling weights by fpc. Note that this is only an example, you may need to adjust the implementation based on your specific use case.
"""