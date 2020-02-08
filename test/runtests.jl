# This file includes the main test set of Jusdl. 
# To include new tests, write your tests in files and save them in directories under `test` directory.

using Test
using Jusdl

using DifferentialEquations
using Random

# Construct the file tree in `test` directory.
filetree = walkdir(@__DIR__)
take!(filetree) # Pop the root directory `test` in which `runtests.jl` is.

# Include all test files under `test`
@time @testset "JusdlTestSet" begin
    for (root, dirs, files) in filetree
        foreach(file -> include(joinpath(root, file)), files)
    end
end
