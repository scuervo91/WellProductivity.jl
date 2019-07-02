module WellProductivity

using RecipesBase
using Dates
using DataFrames
using Colors
using Plots
using Statistics
using Distributions
using Interpolations
using Polinomials

export Reg, DeclinationForecast, Declination, OilInflow, OilOutflow, OilOutflowSen, GasInflow, GasOutflow, EspPerformance, EspTornado

include("OilRateRecipe.jl")
include("OilCumRecipe.jl")
include("GasRateRecipe.jl")
include("GasCumRecipe.jl")
include("BswRecipe.jl")
include("Reg.jl")
include("Types.jl")
include("Declination.jl")
include("OilInflow.jl")
include("IPRRecipe.jl")
include("OilOutflow.jl")
include("OilOutflowSen.jl")
include("GasInflow.jl")
include("VFPRecipe.jl")
include("GasOutflow.jl")
include("NodalRecipe.jl")
include("EspPerformance.jl")
include("EspTornado.jl")
include("EspRecipes.jl")







end # module
