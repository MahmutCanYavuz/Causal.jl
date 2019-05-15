# This file illustrates the simulation of Chua system.

using JuSDL
import JuSDL.Plugins.Fft
using Plots

# Construct the components
gamma(x, a=-1.143, b=-0.714) = b*x + 1 / 2 * (a - b) * (abs(x + 1) - abs(x - 1)) 
function f(dx, x, u, t, alpha=15.6, beta=28, gamma=gamma)
    dx[1] = alpha * (x[2] - x[1] - gamma(x[1]))
    dx[2] = x[1] - x[2] + x[3]
    dx[3] = -beta * x[2]
end
function h(dx, x, u, t, eta=0.1)
    dx[1] = -eta
    dx[2] = eta
    dx[3] = 0
end
g(x, u, t) = [x[1], x[2], x[3]]
x0 = rand(3)*1e-3
t = 0.
sdeds = SDESystem((f, h), g, x0, t)
writer = Writer(Bus(3), buflen=2000, plugin=nothing)
clk = Clock(0., 0.01, 100.)

# Connect the components
connect(sdeds.output, writer.input)

# Construct the model 
model = Model(sdeds, writer, clk=clk)

# Simulate the model 
@time sim = simulate(model);

# Read back the simulation data.
content = read(writer)

# PLot the simulation data.
t = vcat(collect(keys(content))...)
x = vcat(collect(values(content))...)
theme(:default)
plt1 = plot(t, x[:, 1], size=(500, 300), lw=1.5, label="",
    xtickfont=font(15), ytickfont=font(15), grid=false)
plt2 = plot(x[:, 1], x[:, 2], size=(500, 300), lw=1.5, label="",
    xtickfont=font(15), ytickfont=font(15), grid=false)
savefig(plt1, "/tmp/noisy_chua1.svg")
savefig(plt2, "/tmp/noisy_chua2.svg")