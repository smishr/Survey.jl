using GLM

function fit_linear_model(design::SurveyDesign, formula::Symbol)
    # Fit linear model on survey design
    lm = glm(formula, design.data, Normal(), IdentityLink(), design.weights)
    return lm
end

# Example usage
apiclus1 = load_data("apiclus1")
design = SurveyDesign(apiclus1; clusters = :dnum, popsize=:fpc)
formula = :y ~ :x
lm = fit_linear_model(design, formula)

using GLM

function fit_linear_model_on_replicates(design::ReplicateDesign, formula::Symbol)
    models = Dict{Int, GLM.LinearModel}()
    for i in 1:design.replicates
        weight_col = Symbol("replicate_"*string(i))
        lm = glm(formula, design.data, Normal(), IdentityLink(), design.data[:,weight_col])
        models[i] = lm
    end
    return models
end

# Example usage
apiclus1 = load_data("apiclus1")
design = SurveyDesign(apiclus1; clusters = :dnum, popsize=:fpc)
design_rep = bootweights(design; replicates=1000)
formula = :y ~ :x
models = fit_linear_model_on_replicates(design_rep, formula)
