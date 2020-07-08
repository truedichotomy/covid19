
using Dates, Formatting, Plots, ColorSchemes, Plotly, WebIO, DataFrames
plotly()
using Makie

include("load_covid19_data.jl")

states_of_interest = ["Virginia","North Carolina","West Virginia","Delaware", "New York", "New Jersey", "Massachusetts", "Texas","Florida","California","Michigan", "Ohio", "Washington", "Oregon", "Illinois", "Oklahoma", "Maryland", "District of Columbia", "Alaska", "Arizona","Georgia","South Carolina", "Mississippi", "Maine", "Pennsylvania", "Puerto Rico", "Colorado", "New Hampshire", "Iowa", "Vermont","Hawaii"]

strnow = string(Dates.now())
strnow30 = strnow[1:4] * strnow[6:7] * strnow[9:10] * "T" * strnow[12:13] * strnow[15:16] * strnow[18:19]

# extracting county indices with land area and population
cind = findall((countyarea .> 0) .& (cpop .> 0));

reasonable_resolution() = (1000, 800)

tind = 1:length(covid19us[1].confirmed);
t = covid19us[1].time[tind];

#=
# plot a map of confirmed cases
#cval = cconfirmed[cind] ./ (countyarea[cind] .* cpop[cind]);
cval = cconfirmed[cind] ./ cpop[cind];
log10cval = log10.(cval);
#sval = countyarea[cind] .* cpop[cind];
sval = cpop[cind];
log10sval = log10.(sval);
dfconfirmed = DataFrame(LON = clon[cind], LAT = clat[cind], log10POPULATION = log10.(cpop[cind]), log10CONFIRMED = log10.(cconfirmed[cind] ./ cpop[cind]));
#Plotly.scattermapbox(dfconfirmed, lat="LAT", lon="LON", color="log10CONFIRMED", size="log10POPULATION", color_continuous_scale=ColorSchemes.matter.colors, mapbox_style="cart-positron");

scene = Makie.scatter(clon[cind],clat[cind], color = log10cval, markersize = log10sval/10, colormap = ColorSchemes.matter.colors, limits = FRect(-125, 25, 60, 27))
#text!(scene, "©Donglai Gong", textsize = 1, position = (-125, 26))
#cb = colorlegend!(scene, raw = true, camera=campixel!, width = (30,540))
axis = scene[Axis];
axis.names.axisnames = ("Longitude", "Latitude");
axis.names.title = (string(t[end])[1:10] * " Total Confirmed Cases per Capita (log)");
#scene_final = vbox(scene, cb)
Makie.save("/Volumes/GoogleDrive/My Drive/COVID19/" * "covid19_confirmed_map.png", scene)

# plot a map of change in confirmed cases
#cdval = dcconfirmed[cind] ./ (countyarea[cind] .* cpop[cind]);
cdval = dcconfirmed[cind] ./ cpop[cind];
bind = findall(cdval .< 0);
cdval[bind] .= 0;
log10cdval = log10.(cdval);
#sval = countyarea[cind] .* cpop[cind];
sval = cpop[cind];
log10sval = log10.(sval);

scene = Makie.scatter(clon[cind],clat[cind], color = log10cdval, markersize = log10sval/10, colormap = ColorSchemes.matter.colors, limits = FRect(-125, 25, 60, 27))
text!(scene, "©Donglai Gong", textsize = 1, position = (-125, 26))
axis = scene[Axis];
axis.names.axisnames = ("Longitude", "Latitude")
axis.names.title = string(t[end])[1:10] * " New Weekly Cases per Capita (log)"
Makie.save("/Volumes/GoogleDrive/My Drive/COVID19/" * "covid19_delta_confirmed_map.png", scene)

# plot a map of death cases
#cval = cconfirmed[cind] ./ (countyarea[cind] .* cpop[cind]);
cval = cdeath[cind] ./ cpop[cind];
log10cval = log10.(cval);
#sval = countyarea[cind] .* cpop[cind];
sval = cpop[cind];
log10sval = log10.(sval);

scene = Makie.scatter(clon[cind],clat[cind], color = log10cval, markersize = log10sval/10, colormap = ColorSchemes.matter.colors, limits = FRect(-125, 25, 60, 27))
text!(scene, "©Donglai Gong", textsize = 1, position = (-125, 26))
axis = scene[Axis];
axis.names.axisnames = ("Longitude", "Latitude");
axis.names.title = (string(t[end])[1:10] * " Total Death per Capita (log)");
Makie.save("/Volumes/GoogleDrive/My Drive/COVID19/" * "covid19_dealth_map.png", scene)

# plot a map of change in death cases
#cdval = dcconfirmed[cind] ./ (countyarea[cind] .* cpop[cind]);
cdval = dcdeath[cind] ./ cpop[cind];
bind = findall(cdval .< 0);
cdval[bind] .= 0;
log10cdval = log10.(cdval);
#sval = countyarea[cind] .* cpop[cind];
sval = cpop[cind];
log10sval = log10.(sval);
log10svalscl = (log10sval .- minimum(log10sval)) ./ (maximum(log10sval) - minimum(log10sval)) 

scene = Makie.scatter(clon[cind],clat[cind], color = log10cdval, markersize = log10sval/10, colormap = ColorSchemes.matter.colors, limits = FRect(-125, 25, 60, 27))
text!(scene, "©Donglai Gong", textsize = 1, position = (-125, 26))
axis = scene[Axis];
axis.names.axisnames = ("Longitude", "Latitude")
axis.names.title = string(t[end])[1:10] * " New Weekly Deaths per Capita (log)"
Makie.save("/Volumes/GoogleDrive/My Drive/COVID19/" * "covid19_delta_dealth_map.png", scene)
=#

for j = 1:length(states_of_interest)
    display(states_of_interest[j])
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

    state_of_interest = states_of_interest[j];

    ## calculate per county case counts for specific state
    ind = findall(state .== state_of_interest);
    #ind = findall((state .== state_of_interest) .& (county .!= "Unassigned"));
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

    totalconfirmed_strfmt = Formatting.format.(totalconfirmed[end], commas=true);
    pCOVID19usa = Plots.plot(t, totalconfirmed, label="USA Total")
    for si = 1:length(ustate)
        confirmi = stateconfirmed[si];
        ind0 = findall(confirmi .== 0);
        confirmi[ind0] .= NaN;
        Plots.plot!(t, confirmi, label=ustate[si])
    end
    Plots.plot(pCOVID19usa, yscale=:log, framestyle=:box, title="US - Confirmed COVID-19 Cases " * "on " * string(t[end])[1:10] * ":  " * totalconfirmed_strfmt, ylim=(1,exp(15)))

    dtotalconfirmed_strfmt = Formatting.format.(dtotalconfirmed[end], commas=true);
    dCOVID19usa = Plots.plot(t[2:end], dtotalconfirmed, label="USA Daily Cases")
    for si = 1:length(ustate)
        confirmi = dstateconfirmed[si];
        ind0 = findall(confirmi .== 0);
        confirmi[ind0] .= NaN;
        Plots.plot!(t[2:end], confirmi, label=ustate[si])
    end
    #Plots.plot(dCOVID19usa, xrotation=20, size=(800,500), legend=:outertopright, framestyle=:box, title="US - Daily Confirmed COVID-19 Cases", line = (:dot, 2), marker = ([:hex :d], 2, 0.8, Plots.stroke(0, :gray)),  markerstrokewidth = 0)
    Plots.plot(dCOVID19usa, framestyle=:box, title="US - Daily New COVID-19 Cases " * "on " * string(t[end])[1:10] * ":  " * dtotalconfirmed_strfmt, marker = (2, :circle, 2),  markerstrokewidth = 0)

    statetotalconfirmed_strfmt = Formatting.format.(statetotalconfirmed[end], commas=true);
    pCOVID19state = Plots.plot(t, statetotalconfirmed, label=state[ind[1]] * " Total")
    for i = 1:length(ind)
        confirmi = Float64.(deepcopy(covid19us[ind[i]].confirmed[tind]));
        ind0 = findall(confirmi .== 0);
        confirmi[ind0] .= NaN;
        Plots.plot!(covid19us[ind[i]].time[tind], confirmi, label=county[ind[i]])
    end
    Plots.plot(pCOVID19state, yscale=:log, framestyle=:box, title=state[ind[1]] * " - Confirmed COVID-19 Cases " * "on " * string(t[end])[1:10] * ":  " * statetotalconfirmed_strfmt)

    dstatetotalconfirmed_strfmt = Formatting.format.(dstatetotalconfirmed[end], commas=true);
    dCOVID19state = Plots.plot(tstate[2:end], dstatetotalconfirmed, label=state[ind[1]] * " Daily Cases")
    for i = 1:length(ind)
        confirmi = dcountyconfirmed[i];
        ind0 = findall(confirmi .== 0);
        confirmi[ind0] .= NaN;
        Plots.plot!(tstate[2:end], confirmi, label=county[ind[i]])
    end
    Plots.plot(dCOVID19state, framestyle=:box, title=state[ind[1]] * " - Daily New COVID-19 Cases " * "on " * string(t[end])[1:10] * ":  " * dstatetotalconfirmed_strfmt, marker = (2, :circle, 2),  markerstrokewidth = 0)

    covid19plot = Plots.plot(pCOVID19usa, dCOVID19usa, pCOVID19state, dCOVID19state, layout = l8out,  xrotation=30, size=(800,900), xticks = t[1:7:end], legend=:false);

    figoutdir = "/Users/gong/GitHub/covid19_public/timeseries/";
    #Plots.savefig(covid19plot, "/Volumes/GoogleDrive/My Drive/COVID19/" * "covid19_" * filter(x -> !isspace(x), state_of_interest) * "_" * strnow30[1:8] * ".html")
    #Plots.savefig(covid19plot, "~/Dropbox/COVID19/" * "covid19_" * filter(x -> !isspace(x), state_of_interest) * "_" * strnow30[1:8] * ".html")
    #Plots.savefig(covid19plot, "~/Box/Projects/COVID19/" * "covid19_" * filter(x -> !isspace(x), state_of_interest) * "_" * strnow30[1:8] * ".html")
    Plots.savefig(covid19plot, figoutdir * "covid19ts_" * filter(x -> !isspace(x), state_of_interest) * ".html")
    #gui(covid19plot)
    #sleep(1.0)
end