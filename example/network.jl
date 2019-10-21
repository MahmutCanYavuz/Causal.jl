# This file illustrates the simulation of a network consisting of dynamic systesm.

using Jusdl 
using Plots 

# Simulation settings 
t0 = 0
dt = 0.001
tf = 10.

# Define the network parameters 
numnodes = 2
nodes = [LorenzSystem(Bus(3), Bus(3)) for i = 1 : numnodes]
conmat = [-10 10; 10 -10]
cplmat = [1 0 0; 0 0 0; 0 0 0]
net = Network(nodes, conmat, cplmat)
writer = Writer(Bus(length(net.output)))

# Connect the blocks
connect(net.output, writer.input)

# Construct the model 
model = Model(net, writer)

initialize(model)
set!(model.clk, 0, 0.01, 100)
run(model)

disconnect(net.components[1].output, net.components[3].input[1:3])
disconnect(net.components[2].output, net.components[3].input[4:6])
disconnect(net.components[3].output[1:3], net.components[4].input)
disconnect(net.components[3].output[4:6], net.components[5].input)
disconnect(net.components[4].output, net.components[1].input)
disconnect(net.components[5].output, net.components[2].input)

# # Simulate the model 
# sim = simulate(model, t0, dt, tf)

# # Read and process the simulation data.
# t, x = read(writer, flatten=true)
# p1 = plot(t, x[:, 1])
#     plot!(t, x[:, 4])
# p2 = plot(t, abs.(x[:, 1] - x[:, 4]))
# display(plot(p1, p2, layout=(2,1)))
