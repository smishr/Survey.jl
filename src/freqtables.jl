using FreqTables

function generate_freq_table(design::SurveyDesign, var::Symbol)
    # Generate frequency table for variable in survey design
    ft = freqtable(design.data, var, design.weights)
    return ft
end

# Example usage
apiclus1 = load_data("apiclus1")
design = SurveyDesign(apiclus1; clusters = :dnum, popsize=:fpc)
ft = generate_freq_table(design, :x)
