# This file contains SDESystem prototypes

import DifferentialEquations: LambaEM, SDEProblem
import UUIDs: uuid4

"""
    @def_sde_system

Used to construct SDE system 
"""
macro def_sde_system(ex) 
    fields = quote
        trigger::TR = Inpin()
        handshake::HS = Outpin{Bool}()
        callbacks::CB = nothing
        name::Symbol = Symbol()
        id::ID = Jusdl.uuid4()
        t::Float64 = 0.
        modelargs::MA = () 
        modelkwargs::MK = NamedTuple() 
        solverargs::SA = () 
        solverkwargs::SK = NamedTuple() 
        alg::AL = Jusdl.LambaEM{true}()
        integrator::IT = Jusdl.construct_integrator(Jusdl.SDEProblem, input, (drift, diffusion), state, t, modelargs, 
            solverargs; alg=alg, modelkwargs=modelkwargs, solverkwargs=solverkwargs, numtaps=3)
    end, [:TR, :HS, :CB, :ID, :MA, :MK, :SA, :SK, :AL, :IT]
    _append_common_fields!(ex, fields...)
    deftype(ex)
end


##### Define SDE system library

"""
    SDESystem(; drift, diffusion, readout, state, input, output) 

Constructs a SDE system.
"""
@def_sde_system mutable struct SDESystem{DR, DF, RO, ST, IP, OP} <: AbstractSDESystem 
    drift::DR 
    diffusion::DF 
    readout::RO 
    state::ST 
    input::IP 
    output::OP 
end

@doc raw"""
    NoisyLorenzSystem() 

Constructs a noisy Lorenz system 
"""
@def_sde_system mutable struct NoisyLorenzSystem{DR, DF, RO, IP, OP} <: AbstractSDESystem
    σ::Float64 = 10.
    β::Float64 = 8 / 3
    ρ::Float64 = 28.
    η::Float64 = 1.
    γ::Float64 = 1.
    drift::DR = function lorenzdrift(dx, x, u, t, σ=σ, β=β, ρ=ρ, γ=γ)
        dx[1] = σ * (x[2] - x[1])
        dx[2] = x[1] * (ρ - x[3]) - x[2]
        dx[3] = x[1] * x[2] - β * x[3]
        dx .*= γ
    end
    diffusion::DF = (dx, x, u, t, η=η) -> (dx .= η)
    readout::RO = (x, u, t) -> x
    state::Vector{Float64} = rand(3)
    input::IP = nothing 
    output::OP = Outport(3) 
end  

@doc raw"""
    NoisyLorenzSystem() 

Constructs a noisy Lorenz system 
"""
@def_sde_system mutable struct ForcedNoisyLorenzSystem{CM, DR, DF, RO, IP, OP} <: AbstractSDESystem
    σ::Float64 = 10.
    β::Float64 = 8 / 3
    ρ::Float64 = 28.
    η::Float64 = 1.
    cplmat::CM = I(3)
    γ::Float64 = 1.
    drift::DR = function forcedlorenzdrift(dx, x, u, t, σ=σ, β=β, ρ=ρ, γ=γ, cplmat=cplmat)
        dx[1] = σ * (x[2] - x[1])
        dx[2] = x[1] * (ρ - x[3]) - x[2]
        dx[3] = x[1] * x[2] - β * x[3]
        dx .*= γ
        dx .+= cplmat * map(ui -> ui(t), u.itp)   # Couple inputs
    end
    diffusion::DF = (dx, x, u, t, η=η) -> (dx .= η)
    readout::RO = (x, u, t) -> x
    state::Vector{Float64} = rand(3)
    input::IP = Inport(3) 
    output::OP = Outport(3) 
end  


##### Pretty printing 
show(io::IO, ds::SDESystem) = print(io, 
    "SDESystem(drift:$(ds.drift), diffusion:$(ds.diffusion), readout:$(ds.readout), state:$(ds.state), t:$(ds.t), ",
    "input:$(ds.input), output:$(ds.output))")
show(io::IO, ds::NoisyLorenzSystem) = print(io, 
    "NoisyLorenzSystem(σ:$(ds.σ), β:$(ds.β), ρ:$(ds.ρ), η:$(ds.η), γ:$(ds.γ), state:$(ds.state), t:$(ds.t), ",
    "input:$(ds.input), output:$(ds.output))")
show(io::IO, ds::ForcedNoisyLorenzSystem) = print(io, 
    "ForcedNoisyLorenzSystem(σ:$(ds.σ), β:$(ds.β), ρ:$(ds.ρ), η:$(ds.η), γ:$(ds.γ), cplmat:$(ds.cplmat), ", 
    "state:$(ds.state), t:$(ds.t), input:$(ds.input), output:$(ds.output))")
