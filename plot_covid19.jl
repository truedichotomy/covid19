
l8out = @layout([a; b])
pCOVID19 = Plots.plot(t, totalconfirmed, label="USA Total")
for si = 1:length(ustate)
    confirmi = stateconfirmed[si];
    ind0 = findall(confirmi .== 0);
    confirmi[ind0] .= NaN;
    Plots.plot!(t, confirmi, label=ustate[si])
end
Plots.plot(pCOVID19, xrotation=20, size=(800,500), legend=:outertopright, yscale=:log10, framestyle=:box, title="US - Confirmed COVID-19 Cases")

pCOVID19state = Plots.plot(t, statetotalconfirmed, label=state[ind[1]] * " Total")
for i = 1:length(ind)
    confirmi = Float64.(deepcopy(covid19us[ind[i]].confirmed[tind]));
    ind0 = findall(confirmi .== 0);
    confirmi[ind0] .= NaN;
    Plots.plot!(covid19us[ind[i]].time[tind], confirmi, label=county[ind[i]])
end
Plots.plot(pCOVID19state, xrotation=20, size=(800,500), legend=:outertopright, yscale=:log10, framestyle=:box, title=state[ind[1]] * " - Confirmed COVID-19 Cases")

Plots.plot(pCOVID19, pCOVID19state, layout = l8out, size=(1000,1000))