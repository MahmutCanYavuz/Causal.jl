# This file contains the generic fields of some types in Components module.

import ....Jusdl.Utilities: Callback
import ....Jusdl.Connections: Bus, Link


@def generic_source_fields begin
    outputfunc::OF 
    output::OB
    trigger::L
    callbacks::Vector{Callback}
    id::UUID
end

@def generic_static_system_fields begin
    outputfunc::OF 
    input::IB
    output::OB 
    trigger::L
    callbacks::Vector{Callback}
    id::UUID
end

@def generic_discrete_system_fields begin
    statefunc::SF 
    outputfunc::OF 
    state::ST
    t::T
    input::IB 
    output::OB 
    solver::S
    trigger::L
    callbacks::Vector{Callback}
    id::UUID
end

@def generic_ode_system_fields begin
    statefunc::SF 
    outputfunc::OF 
    state::ST
    t::T
    input::IB 
    output::OB 
    solver::S
    trigger::L
    callbacks::Vector{Callback}
    id::UUID
end

@def generic_dae_system_fields begin
    statefunc::SF 
    outputfunc::OF 
    state::ST
    stateder::ST
    t::T
    diffvars::D
    input::IB 
    output::OB 
    solver::S
    trigger::L
    callbacks::Vector{Callback}
    id::UUID
end

@def generic_rode_system_fields begin
    statefunc::SF 
    outputfunc::OF 
    state::ST
    t::T
    input::IB 
    output::OB
    noise::N
    solver::S
    trigger::L
    callbacks::Vector{Callback}
    id::UUID
end

@def generic_sde_system_fields begin
    statefunc::SF 
    outputfunc::OF 
    state::ST
    t::T
    input::IB 
    output::OB 
    noise::N
    solver::S
    trigger::L
    callbacks::Vector{Callback}
    id::UUID
end

@def generic_dde_system_fields begin
    statefunc::SF 
    outputfunc::OF 
    state::ST
    history::H 
    t::T
    input::IB 
    output::OB
    solver::S
    trigger::L
    callbacks::Vector{Callback}
    id::UUID
end

@def generic_sink_fields begin
    input::IB
    databuf::DB
    timebuf::TB
    plugin::P
    trigger::L
    callbacks::Vector{Callback}
    id::UUID
end
