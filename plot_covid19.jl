
#include("load_covid19_data.jl")
state_of_interest = "Virginia"

## calculate per state and total confirmed for US
tind = 1:length(covid19us[1].confirmed);
t = covid19us[1].time[tind];
totalconfirmed = zeros(length(t));
stateconfirmed = Array{Any}(undef, length(ustate));
dstateconfirmed = Array{Any}(undef, length(ustate));
for si = 1:length(ustate)
    #display(ustate[si])
    ind = findall((country .== "US") .& (state .== ustate[si]));
    #confirmed = Array{Any}(undef,length(ind));
    confirmed = [Float64.(covid19us[ind[i]].confirmed) for i in 1:length(ind)];
    stateconfirmed[si] = Float64.(deepcopy(confirmed[1]));
    for i = 2:length(confirmed)
        stateconfirmed[si] .= stateconfirmed[si] .+ confirmed[i];
    end
    totalconfirmed .= totalconfirmed .+ stateconfirmed[si];
    #display(totalconfirmed)
end

## calculate the daily case count for the US and states
dtotalconfirmed = totalconfirmed[2:end] .- totalconfirmed[1:end-1];
for  si = 1:length(stateconfirmed)
    dstateconfirmed[si] = stateconfirmed[si][2:end] - stateconfirmed[si][1:end-1];
end

## turning 0 to NaN
ind0 = findall(totalconfirmed .== 0);
totalconfirmed[ind0] .= NaN
dind0 = findall(dtotalconfirmed .== 0);
dtotalconfirmed[dind0] .= NaN


## calculate per county case counts for specific state

ind = findall(state .== state_of_interest);
countyconfirmed = [Float64.(covid19us[ind[i]].confirmed) for i in 1:length(ind)];
dcountyconfirmed = Array{Any}(undef, length(countyconfirmed));
statetotalconfirmed = Float64.(deepcopy(countyconfirmed[1]));
dstatetotalconfirmed = Array{Any}(undef, length(statetotalconfirmed)-1);
for ci = 2:length(countyconfirmed)
    statetotalconfirmed .= statetotalconfirmed .+ countyconfirmed[ci];
end

## calculate the daily case count for specific state and the counties
dstatetotalconfirmed = statetotalconfirmed[2:end] - statetotalconfirmed[1:end-1];
for ci = 1:length(countyconfirmed)
    dcountyconfirmed[ci] = countyconfirmed[ci][2:end] - countyconfirmed[ci][1:end-1];
end

## turning 0 to NaN
ind0 = findall(statetotalconfirmed .== 0);
statetotalconfirmed[ind0] .= NaN;
dind0 = findall(dstatetotalconfirmed .== 0);
dstatetotalconfirmed[dind0] .= NaN;

tindstate = 1:length(covid19us[ind[1]].confirmed);
tstate = covid19us[ind[1]].time[tind];

# Plot COVID19 data!
l8out = @layout([a; b; c; d])

pCOVID19usa = Plots.plot(t, totalconfirmed, label="USA Total")
for si = 1:length(ustate)
    confirmi = stateconfirmed[si];
    ind0 = findall(confirmi .== 0);
    confirmi[ind0] .= NaN;
    Plots.plot!(t, confirmi, label=ustate[si])
end
Plots.plot(pCOVID19usa, xrotation=20, size=(800,500), legend=:outertopright, yscale=:log10, framestyle=:box, title="US - Confirmed COVID-19 Cases")

dCOVID19usa = Plots.plot(t[2:end], dtotalconfirmed, label="USA Daily Cases")
for si = 1:length(ustate)
    confirmi = dstateconfirmed[si];
    ind0 = findall(confirmi .== 0);
    confirmi[ind0] .= NaN;
    Plots.plot!(t[2:end], confirmi, label=ustate[si])
end
Plots.plot(dCOVID19usa, xrotation=20, size=(800,500), legend=:outertopright, framestyle=:box, line = (:dot, 2), marker = ([:hex :d], 2, 0.8, Plots.stroke(0, :gray)), markerstrokewidth = 0)

pCOVID19state = Plots.plot(t, statetotalconfirmed, label=state[ind[1]] * " Total")
for i = 1:length(ind)
    confirmi = Float64.(deepcopy(covid19us[ind[i]].confirmed[tind]));
    ind0 = findall(confirmi .== 0);
    confirmi[ind0] .= NaN;
    Plots.plot!(covid19us[ind[i]].time[tind], confirmi, label=county[ind[i]])
end
Plots.plot(pCOVID19state, xrotation=20, size=(800,500), legend=:outertopright, yscale=:log10, framestyle=:box, title=state[ind[1]] * " - Confirmed COVID-19 Cases")

dCOVID19state = Plots.plot(tstate[2:end], dstatetotalconfirmed, label=state[ind[1]] * " Total")
for i = 1:length(ind)
    confirmi = dcountyconfirmed[i];
    ind0 = findall(confirmi .== 0);
    confirmi[ind0] .= NaN;
    Plots.plot!(tstate[2:end], confirmi, label=county[ind[i]])
end
Plots.plot(dCOVID19state, xrotation=20, size=(800,500), legend=:outertopright, framestyle=:box, title=state[ind[1]] * " - Confirmed COVID-19 Cases")

Plots.plot(pCOVID19usa, dCOVID19usa, pCOVID19state, dCOVID19state, layout = l8out, size=(1000,1000))