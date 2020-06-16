# This file includes RODESystems

import DifferentialEquations: RandomEM, RODEProblem
import UUIDs: uuid4


"""
    @def_rode_system ex 

where `ex` is the expression to define to define a new AbstractRODESystem component type. The usage is as follows:
```julia
@def_rode_system struct MyRODESystem{T1,T2,T3,...,TN,OP,RH,RO,ST,IP,OP} <: AbstractRODESystem
    param1::T1 = param1_default                 # optional field 
    param2::T2 = param2_default                 # optional field 
    param3::T3 = param3_default                 # optional field
        ⋮
    paramN::TN = paramN_default                 # optional field 
    righthandside::RH = righthandside_default   # mandatory field
    readout::RO = readout_default               # mandatory field
    state::ST = state_default                   # mandatory field
    input::IP = input_default                   # mandatory field
    output::OP = output_default                 # mandatory field
end
```
Here, `MyRODESystem` has `N` parameters. `MyRODESystem` is represented by the `righthandside` and `readout` function. `state`, `input` and `output` is the initial state, input port and output port of `MyRODESystem`.

!!! warning 
    `righthandside` must have the signature 
    ```julia
    function righthandside((dx, x, u, t, W, args...; kwargs...)
        dx .= .... # update dx
    end
    ```
    and `readout` must have the signature 
    ```julia
    function readout(x, u, t)
        y = ...
        return y
    end
    ```

!!! warning 
    New RODE system must be a subtype of `AbstractRODESystem` to function properly.

# Example 
```jldoctest 
julia> @def_rode_system struct MySystem{RH, RO, IP, OP} <: AbstractRODESystem
           A::Matrix{Float64} = [2. 0.; 0 -2]
           righthandside::RH = (dx, x, u, t, W) -> (dx .= A * x * W)
           readout::RO = (x, u, t) -> x 
           state::Vector{Float64} = rand(2) 
           input::IP = nothing 
           output::OP = Outport(2)
       end

julia> ds = MySystem();
```
"""
macro def_rode_system(ex) 
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
        solverkwargs::SK = (dt=0.01, ) 
        alg::AL = Jusdl.RandomEM()
        integrator::IT = Jusdl.construct_integrator(Jusdl.RODEProblem, input, righthandside, state, t, modelargs, 
            solverargs; alg=alg, modelkwargs=modelkwargs, solverkwargs=solverkwargs, numtaps=3)
    end, [:TR, :HS, :CB, :ID, :MA, :MK, :SA, :SK, :AL, :IT]
    _append_common_fields!(ex, fields...)
    deftype(ex)
end

##### Define RODE sytem library 

"""
    RODESystem(; righthandside, readout, state, input, output)

Constructs a generic RODE system 
"""
@def_rode_system mutable struct RODESystem{RH, RO, ST, IP, OP} <: AbstractRODESystem 
    righthandside::RH 
    readout::RO 
    state::ST 
    input::IP 
    output::OP
end

@doc raw"""
    MultiplicativeNoiseLinearSystem() 

Constructs a `MultiplicativeNoiseLinearSystem` with the dynamics 
```math 
\begin{array}{l}
    \dot{x} = A x W
\end{array}
where `W` is the noise process.
```
"""
@def_rode_system struct MultiplicativeNoiseLinearSystem{RH, RO, IP, OP} <: AbstractRODESystem
    A::Matrix{Float64} = [2. 0.; 0 -2]
    righthandside::RH = (dx, x, u, t, W) -> (dx .= A * x * W)
    readout::RO = (x, u, t) -> x 
    state::Vector{Float64} = rand(2) 
    input::IP = nothing 
    output::OP = Outport(2)
end

##### Pretty printing 
show(io::IO, ds::RODESystem) = print(io, 
    "RODESystem(righthandside:$(ds.righthandside), readout:$(ds.readout), state:$(ds.state), t:$(ds.t), input:$(ds.input), output:$(ds.output))")
show(io::IO, ds::MultiplicativeNoiseLinearSystem) = print(io, 
    "MultiplicativeNoiseLinearSystem(A:$(ds.A), state:$(ds.state), t:$(ds.t), input:$(ds.input), output:$(ds.output))")

