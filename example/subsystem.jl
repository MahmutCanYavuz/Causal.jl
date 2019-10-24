# This file illustrates the simulation of a subsystem.

using Jusdl 
using Plots 

# Construct a subsystem
gain1 = Gain(Bus(), gain=2.)
gain2 = Gain(Bus(), gain=4)
mem = Memory(Bus(), 50, initial=rand(1))
connect(gain1.output, mem.input)
connect(mem.output, gain2.input)

sub = SubSystem([gain1, gain2, mem], gain1.input, gain2.output)

# Construct a source and a sink.
gen = FunctionGenerator(sin)
writer = Writer(Bus())

# Connect the source, subsystem and sink.
connect(gen.output, sub.input)
connect(sub.output, writer.input)

# # Construct the model 
model = Model(gen, sub, writer)

# Simulate the model 
sim = simulate(model, 0, 0.01, 10)

# Read and plot simulation data 
t, x = read(writer, flatten=true)
display(plot(t, x))

# Display the task status
display(model.taskmanager.pairs[sub])
