# 
# Julia System Desciption Language
# 
module Jusdl

using UUIDs
using DifferentialEquations
using Sundials
using LightGraphs
using DataStructures
using JLD2
using Plots
using ProgressMeter 
using Logging
using LinearAlgebra
using Dates
using NLsolve
using Interpolations
using LibGit2
using DocStringExtensions
import GraphPlot.gplot
import FileIO: load
import Base: show, display, write, read, close, setproperty!, mv, cp, open,  istaskdone, istaskfailed, 
    getindex, setindex!, size, isempty

include("utilities/constants.jl")
include("utilities/utils.jl")

include("utilities/callback.jl")            
export Callback, enable!, disable!, isenabled, applycallbacks

include("utilities/buffer.jl")
export BufferMode, LinearMode, CyclicMode, Buffer, Normal, Cyclic, Fifo, Lifo, write!, isfull, ishit, content, mode, snapshot, datalength, inbuf, outbuf

include("connections/link.jl")
export Link, launch

include("connections/pin.jl")
export AbstractPin, Outpin, Inpin, connect!, disconnect!, isconnected, isbound

include("connections/port.jl")
export AbstractPort, Inport, Outport, datatype

include("components/interpolant.jl")
export Interpolant

include("components/hierarchy.jl")
export AbstractComponent, AbstractSource, AbstractSystem, AbstractSink, AbstractStaticSystem, 
AbstractDynamicSystem, AbstractSubSystem, AbstractMemory, AbstractDiscreteSystem, AbstractODESystem, 
AbstractRODESystem, AbstractDAESystem, AbstractSDESystem, AbstractDDESystem

include("components/macros.jl")

include("components/takestep.jl")
export readtime!, readstate, readinput!, writeoutput!, computeoutput, evolve!, takestep!, drive!, approve!

include("components/clock.jl")
export Clock, isrunning, ispaused, isoutoftime, set!, stop!, pause!

include("components/generators.jl")
export @def_source,
    SinewaveGenerator,
    DampedSinewaveGenerator,
    SquarewaveGenerator,
    TriangularwaveGenerator, 
    ConstantGenerator, 
    RampGenerator, 
    StepGenerator,
    ExponentialGenerator,
    DampedExponentialGenerator


include("components/systems/staticsystems.jl")
export @def_static_system,
    Adder,
    Multiplier, 
    Gain,
    Terminator, 
    Memory, 
    Coupler, 
    Differentiator

include("components/systems/dynamicalsystems/init.jl")

include("components/systems/dynamicalsystems/odesystems.jl")
export @def_ode_system,
    ContinuousLinearSystem,
    LorenzSystem, ForcedLorenzSystem, 
    ChenSystem, ForcedChenSystem,
    ChuaSystem, ForcedChuaSystem,
    RosslerSystem, ForcedRosslerSystem,
    VanderpolSystem, ForcedVanderpolSystem,
    Integrator

include("components/systems/dynamicalsystems/discretesystems.jl")
export @def_discrete_system,
    DiscreteLinearSystem,
    HenonSystem, 
    LoziSystem,
    BogdanovSystem, 
    GingerbreadmanSystem,
    LogisticSystem

include("components/systems/dynamicalsystems/sdesystems.jl")
export @def_sde_system,
    NoisyLorenzSystem, ForcedNoisyLorenzSystem

include("components/systems/dynamicalsystems/daesystems.jl")
export @def_dae_system, 
    RobertsonSystem,
    PendulumSystem, 
    RLCSystem

include("components/systems/dynamicalsystems/rodesystems.jl")
export @def_rode_system,
    MultiplicativeNoiseLinearSystem

include("components/systems/dynamicalsystems/ddesystems.jl")
export @def_dde_system, 
    DelayFeedbackSystem

include("components/sinks.jl")
export @def_sink,
    Writer, 
    Printer,
    Scope, 
    write!, 
    fwrite! 
    fread
    update!


include("models/taskmanager.jl")
export TaskManager, 
    checktaskmanager

include("models/simulation.jl")
export Simulation, SimulationError, setlogger, closelogger, report

include("models/model.jl")
export Model, getloops, breakloop, inspect!, initialize!, run!, terminate!, simulate!
export Node, Branch, addnode!, getnode, addbranch!, getbranch, deletebranch!, signalflow

include("plugins/loadplugins.jl")
export AbstractPlugin, process, add, remove, enable, disable, check

end  # module
