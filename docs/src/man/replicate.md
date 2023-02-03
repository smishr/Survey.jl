# Replicate weights

Replicate weights are a method for estimating the standard errors of survey statistics in complex sample designs.

The basic idea behind replicate weights is to create multiple versions of the original sample weights, each with small, randomly generated perturbations. The multiple versions of the sample weights are then used to calculate the survey statistic of interest, such as the mean or total, on multiple replicate samples. The variance of the survey statistic is then estimated by computing the variance across the replicate samples.

Currently, the Rao-Wu bootstrap[^1] is the only method in the package for generating replicate weights. 

The `bootweights` function of the package can be used to generate a `ReplicateDesign` from a `SurveyDesign`
For example: 
```@repl bootstrap
using Survey
apistrat = load_data("apistrat")
dstrat = SurveyDesign(apistrat; strata=:stype, weights=:pw)
bstrat = bootweights(dstrat; replicates = 10)
```

For each replicate, the `DataFrame` of `ReplicateDesign` has an additional column. The of the column is `replicate_` followed by the replicate number.  

```@repl bootstrap
names(bstrat.data)
```
`replicate_1`, `replicate_2`, `replicate_3`, `replicate_4`, `replicate_5`, `replicate_6`, `replicate_7`, `replicate_8`, `replicate_9`, `replicate_10`, are the replicate weight columns. 

While a `SurveyDesign` can be used to estimate a statistics. For example: 

```@repl bootstrap
mean(:api00, dstrat)
```

The `ReplicateDesign` can be used to compute the standard error of the statistic. For example: 

```@repl bootstrap
mean(:api00, bstrat)
```

For each replicate weight, the statistic is calculated using it instead of the weight. The standard deviation of those statistics is the standard error of the estimate.  

## References

[^1]: [Rust, Keith F., and J. N. K. Rao. "Variance estimation for complex surveys using replication techniques." Statistical methods in medical research 5.3 (1996): 283-310.](https://journals.sagepub.com/doi/abs/10.1177/096228029600500305?journalCode=smma)