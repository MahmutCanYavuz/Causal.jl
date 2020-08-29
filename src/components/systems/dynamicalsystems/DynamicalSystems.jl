"""
Includes dynamic system components that are represented by ordinary, random ordinary, stochastic, delay differential equations,  differential algebraic equations and discrete difference equations. 

# Imports 

    $(IMPORTS) 

# Exports 

    $(EXPORTS)
"""
module DynamicalSystems 

using DocStringExtensions
using UUIDs, LinearAlgebra
using Causal.Utilities
using Causal.Connections 
using Causal.Components.ComponentsBase
import Base: show 
using DifferentialEquations
using Sundials
import DifferentialEquations: FunctionMap, DiscreteProblem
import DifferentialEquations: Tsit5, ODEProblem
import DifferentialEquations: LambaEM, SDEProblem
import DifferentialEquations: DAEProblem
import Sundials: IDA 
import DifferentialEquations: RandomEM, RODEProblem
import DifferentialEquations: MethodOfSteps

include("init.jl")
include("discretesystems.jl")
include("odesystems.jl")
include("daesystems.jl")
include("rodesystems.jl")
include("sdesystems.jl")
include("ddesystems.jl")

end # module 
