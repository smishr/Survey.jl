function jkknife(variable:: Symbol, design::SurveyDesign ,func:: Function;  params =[])
    statistic = func(design.data[!,variable],params...)
    nh = length(unique(design.data[!,design.cluster]))
    newv = []
    gdf = groupby(design.data, design.cluster)
    replicates = [filter(n -> n != i, 1:nh) for i in 1:nh] 
    for i in replicates
        push!(newv,func(DataFrame(gdf[i])[!,variable]))
    end
    c = 0
    for i in 1:nh
        c = c+(newv[i]-statistic)^2
    end
    var = c*(nh-1)/nh
    return DataFrame(Statistic = statistic, SE = sqrt(var))
end

"""
    Creating replicate desing using Jackknife algorithm.

"""
function jackknife(design::SurveyDesign; replicates=4000)
    H = length(unique(design.data[!, design.strata]))
    stratified = groupby(design.data, design.strata)
    function replicate(stratified, H)
        for h in 1:H
            substrata = DataFrame(stratified[h])
            psus = unique(substrata[!, design.cluster])
            if length(psus) <= 1
                stratified[h].whij .= 0 # hasn't been tested yet. 
            end
            nh = length(psus)
            gdf = groupby(substrata, design.cluster)
            for i in 1:nh
                gdf[i].whij = repeat([nh - 1], nrow(gdf[i])) .* gdf[i][!,design.weights]
            end            
            stratified[h].whij = transform(gdf).whij
        end
        return transform(stratified, :whij)
    end
    df = replicate(stratified, H)
    rename!(df, :whij => :replicate_1)
    df.replicate_1 = disallowmissing(df.replicate_1)
    for i in 2:(replicates)
        df[!, "replicate_" * string(i)] = disallowmissing(replicate(stratified, H).whij)
    end 
    return ReplicateDesign(df, design.cluster, design.popsize, design.sampsize, design.strata, design.weights, design.allprobs, design.pps, replicates) 
end