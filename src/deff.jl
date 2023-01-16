"Write a function to calculate the design effect of a SurveyDesign

The design effect (DEFF) is a measure of the inflation of the variance of an estimator due to the sampling design. Here's one way to write a function to calculate the design effect for a SurveyDesign:

The above function takes in a SurveyDesign object and calculates the design effect (DEFF) as the ratio of the variance of the estimator calculated using the sample weights to the variance of the estimator calculated using the population proportions.

    The variance of the estimator calculated using the sample weights is calculated by taking the variance of the weights column of the data. The variance of the estimator calculated using the population proportions is calculated by dividing the weights column of the data by the population size column of the data and then taking the variance of the resulting column.
    
    The DEFF value is a measure of the increase in variance caused by the sampling design relative to a simple random sample of the same size. A value greater than 1 indicates that the variance of the estimator is greater than would be expected from a simple random sample.
"

function design_effect(design::SurveyDesign)
    # calculate the variance of the estimator using the sample weights
    var_estimator = var(design.data[!, design.weights])
    # calculate the variance of the estimator using the population proportions
    var_pop_proportions = var(design.data[!, design.weights] / design.data[!, design.popsize])
    # calculate the design effect
    deff = var_estimator / var_pop_proportions
    return deff
end
