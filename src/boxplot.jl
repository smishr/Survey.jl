"""
	boxplot(design, x, y; kwargs...)

Box plot of survey design variable `y` grouped by column `x`.

Weights can be specified by a `Symbol` using the keyword argument `weights`.

The keyword arguments are all the arguments that can be passed to `mapping` in
[AlgebraOfGraphics](https://docs.juliahub.com/AlgebraOfGraphics/CHIaw/0.4.7/).

```julia
julia> using AlgebraOfGraphics

julia> apisrs = load_data("apisrs");

julia> srs = SurveyDesign(apisrs; weights=:pw);

julia> bp = boxplot(srs, :stype, :enroll; weights = :pw);

julia> save("boxplot.png", bp)
```

![](assets/boxplot.png)
"""
function boxplot(design::AbstractSurveyDesign, x::Symbol, y::Symbol; kwargs...)
	map = mapping(x, y; kwargs...)
	data = AlgebraOfGraphics.data(design.data)

	data * visual(BoxPlot) * map |> draw
end
