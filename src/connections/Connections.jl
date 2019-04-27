# This file includes the Connections module

@reexport module Connections 

using UUIDs
import ..JuSDL.Utilities: Callback, Buffer, write!

# Data transfer types
abstract type AbstractLink end
abstract type AbstractBus end

include("link.jl")
include("bus.jl")

end