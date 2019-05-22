module WellProductivity

using RecipesBase
using Dates
using DataFrames
using Colors
using Plots
using Statistics
using Distributions

export Reg, DeclinationForecast, Declination

include("OilRateRecipe.jl")
include("OilCumRecipe.jl")
include("GasRateRecipe.jl")
include("GasCumRecipe.jl")
include("BswRecipe.jl")
include("Reg.jl")
include("Types.jl")
include("Declination.jl")



end # module
