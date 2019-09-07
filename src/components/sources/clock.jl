# This file constains the Clock tools for time synchronization of DsSimulator.

import Base: iterate, take!

Generator(t0::T, dt::T, tf::T) where T <: Real = Channel(channel -> foreach(t -> put!(channel, t), t0:dt:tf), ctype=T)
Generator(t0::Real, dt::Real, tf::Real) = Generator(promote(t0, dt, tf)...)

mutable struct Clock{T<:Real}
    t::T
    dt::T
    tf::T
    generator::Channel{T}
    paused::Bool
    callbacks::Vector{Callback}
    id::UUID
end
Clock(t, dt, tf) = Clock(promote(t, dt, tf)..., Channel{promote_type(typeof(t),typeof(dt),typeof(tf))}(0), false, Callback[], uuid4())

##### Reading from clock
function take!(clk::Clock)
    if ispaused(clk)
        @warn "Clock is paused."
        return clk.t
    end
    if isoutoftime(clk)
        @warn "Clock is out of time."
        return clk.t
    end
    if !isrunning(clk)
        @warn "Clock is not running."
        return clk.t
    end
    clk.t = take!(clk.generator)
    clk.callbacks(clk)
    clk.t
end

##### Clock status check 
isrunning(clk::Clock) = isready(clk.generator)
ispaused(clk::Clock) = clk.paused
isoutoftime(clk::Clock) = clk.t >= clk.tf

##### Controlling clock.
set!(clk::Clock, generator::Channel=Generator(clk.t, clk.dt, clk.tf)) = (clk.generator = generator; clk.paused=false; clk)
set!(clk::Clock, t::Real, dt::Real, tf::Real) = (set!(clk, Generator(t, dt, tf)); clk)
unset!(clk::Clock) = (set!(clk, Channel{typeof(clk.t)}(0)); clk)

##### Iterating clock.
iterate(clk::Clock, t=clk.t) = isready(clk.generator) ? (take!(clk), clk.t) : nothing
