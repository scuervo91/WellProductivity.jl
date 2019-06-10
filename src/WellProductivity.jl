module WellProductivity

using RecipesBase
using Dates
using DataFrames
using Colors
using Plots
using Statistics
using Distributions

export Reg, DeclinationForecast, Declination, OilInflow, OilOutflow

include("OilRateRecipe.jl")
include("OilCumRecipe.jl")
include("GasRateRecipe.jl")
include("GasCumRecipe.jl")
include("BswRecipe.jl")
include("Reg.jl")
include("Types.jl")
include("Declination.jl")
include("OilInflow.jl")
include("IPRRecipe")
include("OilOutflow.jl")





end # module
