a = collect(1:10)
b = Array{Float64}(undef,10)
b .= NaN
Plots.plot(a,b)
