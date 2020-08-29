# This file includes Scope type 

export Scope, update!

"""
    $(TYPEDEF)

Constructs a `Scope` with input bus `input`. `buflen` is the length of the internal buffer of `Scope`. `plugin` is the additional data processing tool. `args`,`kwargs` are passed into `plots(args...; kwargs...))`. See (https://github.com/JuliaPlots/Plots.jl) for more information.

# Fields 

    $(TYPEDFIELDS)

!!! warning 
    When initialized, the `plot` of `Scope` is closed. See [`open(sink::Scope)`](@ref) and [`close(sink::Scope)`](@ref).
"""
@def_sink mutable struct Scope{A, PA, PK, PLT} <: AbstractSink
    action::A = update!
    pltargs::PA = () 
    pltkwargs::PK = NamedTuple()
    plt::PLT = plot(pltargs...; pltkwargs...)
end

show(io::IO, scp::Scope) = print(io, "Scope(nin:$(length(scp.input)))")

"""
    $(SIGNATURES)

Updates the series of the plot windows of `s` with `x` and `yi`.
"""
function update!(s::Scope, x, yi)
    y = collect(hcat(yi...)')
    plt = s.plt
    subplots = plt.subplots
    clear.(subplots)
    plot!(plt, x, y, xlim=(x[1], x[end]), label="")  # Plot the new series
    gui()
end

clear(sp::Plots.Subplot) = popfirst!(sp.series_list)  # Delete the old series 

""" 
    $(SIGNATURES)

Closes the plot window of the plot of `sink`.
"""
close(sink::Scope) = closeall()

"""
    $(SIGNATURES)

Opens the plot window for the plots of `sink`.
"""
open(sink::Scope) = Plots.isplotnull() ? (@warn "No current plots") : gui()
