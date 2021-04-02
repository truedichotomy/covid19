
using Dates, Formatting, Plots, ColorSchemes, Plotly, WebIO, DataFrames, BenchmarkTools
plotly()
#using Makie

include("load_covid19_data.jl")

states_of_interest = ["Virginia","North Carolina","West Virginia","Delaware", "Wisconsin", "Minnesota", "Idaho", "Tennessee", "Alabama", "New York", "New Jersey", "Massachusetts", "Texas","Florida","California","Michigan", "Ohio", "Washington", "Oregon", "Illinois", "Oklahoma", "Maryland", "District of Columbia", "Alaska", "Arizona","Georgia","South Carolina", "Mississippi", "Maine", "Pennsylvania", "Colorado", "New Hampshire", "Iowa", "Vermont","Hawaii", "Montana", "North Dakota", "South Dakota", "Arkansas", "Connecticut", "Indiana", "Kansas", "Kentucky", "Louisiana", "Missouri", "Nebraska", "Nevada", "New Mexico", "Utah", "Wyoming", "Rhode Island",  "Puerto Rico"]
#states_of_interest = ["Rhode Island",  "Puerto Rico"]
#states_of_interest = ["Puerto Rico",]

strnow = string(Dates.now())
strnow30 = strnow[1:4] * strnow[6:7] * strnow[9:10] * "T" * strnow[12:13] * strnow[15:16] * strnow[18:19]

# extracting county indices with land area and population
cind = findall((countyarea .> 0) .& (cpop .> 0));

reasonable_resolution() = (1440, 900)

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

#Threads.@threads 
for j = 1:length(states_of_interest)
#for j = 1:1
        #display(Threads.threadid())

    display(string(j) * " " * states_of_interest[j])
    ## calculate per state and total confirmed for US
    local tind = 1:length(covid19us[1].confirmed);
    local t = covid19us[1].time[tind];
    local totalconfirmed = zeros(length(t));
    local stateconfirmed = Array{Any}(undef, length(ustate));
    local dstateconfirmed = Array{Any}(undef, length(ustate));
    local totaldeath = zeros(length(t));
    local statedeath = Array{Any}(undef, length(ustate));
    local dstatedeath = Array{Any}(undef, length(ustate));

    for si = 1:length(ustate)
        #display(ustate[si])
        ind = findall((country .== "US") .& (state .== ustate[si]));

        #confirmed = Array{Any}(undef,length(ind));
        confirmed = [Float64.(covid19us[ind[i]].confirmed) for i in 1:length(ind)];
        death = [Float64.(covid19us[ind[i]].death) for i in 1:length(ind)];

        stateconfirmed[si] = Float64.(deepcopy(confirmed[1]));
        statedeath[si] = Float64.(deepcopy(death[1]));

        for i = 2:length(confirmed)
            stateconfirmed[si] .= stateconfirmed[si] .+ confirmed[i];
        end
        totalconfirmed .= totalconfirmed .+ stateconfirmed[si];

        for i = 2:length(death)
            statedeath[si] .= statedeath[si] .+ death[i];
        end
        totaldeath .= totaldeath .+ statedeath[si];
        #display(totalconfirmed)
    end

    ## calculate the daily case count for the US and states
    local dtotalconfirmed = totalconfirmed[2:end] .- totalconfirmed[1:end-1];
    for  si = 1:length(stateconfirmed)
        dstateconfirmed[si] = stateconfirmed[si][2:end] - stateconfirmed[si][1:end-1];
    end

    ## calculate the daily case count for the US and states
    local dtotaldeath = totaldeath[2:end] .- totaldeath[1:end-1];
    for  si = 1:length(statedeath)
        dstatedeath[si] = statedeath[si][2:end] - statedeath[si][1:end-1];
    end

    ## turning 0 to NaN for total counts, this will allow for the use of log10 in y-axis for Plots.jl
    local ind0 = findall(totalconfirmed .== 0.0);
    totalconfirmed[ind0] .= NaN
    local dind0 = findall(dtotalconfirmed .== 0.0);
    #dtotalconfirmed[dind0] .= NaN

    ind0 = findall(totaldeath .== 0.0);
    totaldeath[ind0] .= NaN
    dind0 = findall(dtotaldeath .== 0.0);
    #dtotaldeath[dind0] .= NaN


    local state_of_interest = states_of_interest[j];

    ## calculate per county case counts for specific state
    local ind = findall(state .== state_of_interest);
    #ind = findall((state .== state_of_interest) .& (county .!= "Unassigned"));
    local population = [Float64.(covid19us[ind[i]].population) for i in 1:length(ind)];

    local countyconfirmed = [Float64.(covid19us[ind[i]].confirmed) for i in 1:length(ind)];
    local dcountyconfirmed = Array{Any}(undef, length(countyconfirmed));
    local dcountyconfirmedpc = Array{Any}(undef, length(countyconfirmed));

    local statetotalconfirmed = Float64.(deepcopy(countyconfirmed[1]));
    for ci = 2:length(countyconfirmed)
        statetotalconfirmed .= statetotalconfirmed .+ countyconfirmed[ci];
    end

    ## calculate the daily case count for specific state and the counties
    local dstatetotalconfirmed = Array{Any}(undef, length(statetotalconfirmed)-1);
    local dstatetotalconfirmed = statetotalconfirmed[2:end] - statetotalconfirmed[1:end-1];
    for ci = 1:length(countyconfirmed)
        dcountyconfirmed[ci] = countyconfirmed[ci][2:end] - countyconfirmed[ci][1:end-1];
        dcountyconfirmedpc[ci] = (countyconfirmed[ci][2:end] - countyconfirmed[ci][1:end-1]) ./ population[ci] .* 1.0e5;
        if population[ci] == 0.0
            dcountyconfirmedpc[ci][1] = 0.0;
        end
    end

    ## turning 0 to NaN for total counts, this will allow for the use of log10 in y-axis for Plots.jl
    ind0 = findall(statetotalconfirmed .== 0);
    statetotalconfirmed[ind0] .= NaN;
    dind0 = findall(dstatetotalconfirmed .== 0);
    #dstatetotalconfirmed[dind0] .= NaN;

    
    local countydeath = [Float64.(covid19us[ind[i]].death) for i in 1:length(ind)];
    local dcountydeath = Array{Any}(undef, length(countydeath));
    local dcountydeathpc = Array{Any}(undef, length(countydeath));

    local statetotaldeath = Float64.(deepcopy(countydeath[1]));
    for ci = 2:length(countydeath)
        statetotaldeath .= statetotaldeath .+ countydeath[ci];
    end

    ## calculate the daily case count for specific state and the counties
    local dstatetotaldeath = Array{Any}(undef, length(statetotaldeath)-1);
    local dstatetotaldeath = statetotaldeath[2:end] - statetotaldeath[1:end-1];
    for ci = 1:length(countydeath)
        dcountydeath[ci] = countydeath[ci][2:end] - countydeath[ci][1:end-1];
        dcountydeathpc[ci] = (countydeath[ci][2:end] - countydeath[ci][1:end-1]) ./ population[ci] .* 1.0e5;
        if population[ci] == 0.0
            dcountydeathpc[ci][1] = 0.0;
        end
    end

    ## turning 0 to NaN, this will allow for the use of log10 in y-axis for Plots.jl
    ind0 = findall(statetotaldeath .== 0);
    statetotaldeath[ind0] .= NaN;
    dind0 = findall(dstatetotaldeath .== 0);
    #dstatetotaldeath[dind0] .= NaN;

    tindstate = 1:length(covid19us[ind[1]].confirmed);
    tstate = covid19us[ind[1]].time[tindstate];

    #display(statetotaldeath)

    # Plot COVID19 data!
    #l8out = @layout([a; b; c; d; e])
    l8out = @layout([a b; c d; e f; g h; i j])
    #l8out = @layout [grid(5,2)]

    local totalconfirmed_strfmt = Formatting.format.(totalconfirmed[end], commas=true);
    local pCOVID19usa = Plots.plot(t, totalconfirmed, label="USA Total")
    for si = 1:length(ustate)
        confirmi = stateconfirmed[si];
        ind0 = findall(confirmi .== 0);
        confirmi[ind0] .= NaN;
        if length(ind0) != length(confirmi) # if everything is NaN, don't try to plot        
            Plots.plot!(t, confirmi, label=ustate[si])
        end
    end
    Plots.plot(pCOVID19usa, yscale=:log10, ylim=(1,10^7.6) ,framestyle=:box, title="US - Confirmed COVID-19 Cases " * "as of " * string(t[end])[1:10] * ":  " * totalconfirmed_strfmt)

    local dtotalconfirmed_strfmt = Formatting.format.(dtotalconfirmed[end], commas=true);
    #dCOVID19usa = Plots.plot(t[2:end], dtotalconfirmed, m = (2, :auto), label="USA Daily Cases")
    local dCOVID19usa = Plots.plot(t[2:end], dtotalconfirmed, label="USA Daily Cases")
    for si = 1:length(ustate)
        confirmi = dstateconfirmed[si];
        #ind0 = findall(confirmi .== 0);
        #confirmi[ind0] .= NaN;
        #Plots.plot!(t[2:end], confirmi, m = (1, :auto), label=ustate[si])
        Plots.plot!(t[2:end], confirmi, label=ustate[si])
    end
    #Plots.plot(dCOVID19usa, xrotation=20, size=(800,500), legend=:outertopright, framestyle=:box, title="US - Daily Confirmed COVID-19 Cases", line = (:dot, 2), marker = ([:hex :d], 2, 0.8, Plots.stroke(0, :gray)),  markerstrokewidth = 0)
    #Plots.plot(dCOVID19usa, framestyle=:box, title="US - Daily New COVID-19 Cases " * "on " * string(t[end])[1:10] * ":  " * dtotalconfirmed_strfmt, markershape = :circle, markersize = 1, markerstrokestyle = :dot,  markerstrokewidth = 0)
    Plots.plot(dCOVID19usa, framestyle=:box, title="US - Daily New COVID-19 Cases " * "on " * string(t[end])[1:10] * ":  " * dtotalconfirmed_strfmt)

    local statetotalconfirmed_strfmt = Formatting.format.(statetotalconfirmed[end], commas=true);
    local pCOVID19state = Plots.plot(t, statetotalconfirmed, label=state[ind[1]] * " Total")
    for i = 1:length(ind)
        #display(i)
        confirmi = Float64.(deepcopy(covid19us[ind[i]].confirmed[tindstate]));
        ind0 = findall(confirmi .== 0.0);
        confirmi[ind0] .= NaN;
        if length(ind0) != length(confirmi) # if everything is NaN, don't try to plot
            Plots.plot!(covid19us[ind[i]].time[tind], confirmi, label=county[ind[i]])
        end
    end
    Plots.plot(pCOVID19state, yscale=:log10, framestyle=:box, title=state[ind[1]] * " - Confirmed COVID-19 Cases " * "as of " * string(t[end])[1:10] * ":  " * statetotalconfirmed_strfmt)

    local dstatetotalconfirmed_strfmt = Formatting.format.(dstatetotalconfirmed[end], commas=true);
    local dCOVID19state = Plots.plot(tstate[2:end], dstatetotalconfirmed, label=state[ind[1]] * " Daily Cases")
    for i = 1:length(ind)
        confirmi = dcountyconfirmed[i];
        #ind0 = findall(confirmi .== 0);
        #ind0 = isnan.(confirmi);
        #confirmi[ind0] .= NaN;
        Plots.plot!(tstate[2:end], confirmi, label=county[ind[i]])
    end
    #Plots.plot(dCOVID19state, framestyle=:box, title=state[ind[1]] * " - Daily New COVID-19 Cases " * "on " * string(t[end])[1:10] * ":  " * dstatetotalconfirmed_strfmt, marker = (2, :circle, 2),  markerstrokewidth = 0)
    Plots.plot(dCOVID19state, framestyle=:box, title=state[ind[1]] * " - Daily New COVID-19 Cases " * "on " * string(t[end])[1:10] * ":  " * dstatetotalconfirmed_strfmt)

    local dstatetotalconfirmedpc_strfmt = Formatting.format.(dstatetotalconfirmed[end] / sum(population) * 1.0e5, commas=true, precision = 3);
    local dCOVID19statepc = Plots.plot(tstate[2:end], dstatetotalconfirmed / sum(population) * 1.0e5, label=state[ind[1]] * " Daily Cases")
    for i = 1:length(ind)
        # 92, 125
        confirmi = dcountyconfirmedpc[i];
        #ind0 = findall(confirmi .== NaN);
        #ind0 = isnan.(confirmi);
        #confirmi[ind0] .= NaN;
        Plots.plot!(tstate[2:end], confirmi, label=county[ind[i]])
    end
    #Plots.plot(dCOVID19statepc, framestyle=:box, title=state[ind[1]] * " - Daily New COVID-19 Cases per 100k " * "on " * string(t[end])[1:10] * ":  " * dstatetotalconfirmedpc_strfmt, marker = (2, :circle, 2),  markerstrokewidth = 0)
    Plots.plot(dCOVID19statepc, framestyle=:box, title=state[ind[1]] * " - Daily New COVID-19 Cases / 100k " * "on " * string(t[end])[1:10] * ":  " * dstatetotalconfirmedpc_strfmt)

    #for i = 1:length(ind)
    #    display(i)
    #    a = findall(isnan.(dcountyconfirmedpc[i]) .== 1)
    #    display(a)
    #end


    local totaldeath_strfmt = Formatting.format.(totaldeath[end], commas=true);
    local pCOVID19usaD = Plots.plot(t, totaldeath, label="USA Total Deaths")
    for si = 1:length(ustate)
        deathi = statedeath[si];
        ind0 = findall(deathi .== 0.0);
        deathi[ind0] .= NaN;
        if length(ind0) != length(deathi) # if everything is NaN, don't try to plot
            Plots.plot!(t, deathi, label=ustate[si])
        end
    end
    Plots.plot(pCOVID19usaD, yscale=:log10, ylim=(1,10^5.9), framestyle=:box, title="US - COVID-19 Death " * "as of " * string(t[end])[1:10] * ":  " * totaldeath_strfmt)

    local dtotaldeath_strfmt = Formatting.format.(dtotaldeath[end], commas=true);
    local dCOVID19usaD = Plots.plot(t[2:end], dtotaldeath, label="USA Daily Deaths")
    for si = 1:length(ustate)
        deathi = dstatedeath[si];
        #ind0 = findall(deathi .== 0);
        #deathi[ind0] .= NaN;
        Plots.plot!(t[2:end], deathi, label=ustate[si])
    end
    #Plots.plot(dCOVID19usa, xrotation=20, size=(800,500), legend=:outertopright, framestyle=:box, title="US - Daily Confirmed COVID-19 Cases", line = (:dot, 2), marker = ([:hex :d], 2, 0.8, Plots.stroke(0, :gray)),  markerstrokewidth = 0)
    #Plots.plot(dCOVID19usaD, framestyle=:box, title="US - Daily COVID-19 Deaths " * "on " * string(t[end])[1:10] * ":  " * dtotaldeath_strfmt, marker = (2, :circle, 2),  markerstrokewidth = 0)
    Plots.plot(dCOVID19usaD, framestyle=:box, title="US - Daily COVID-19 Deaths " * "on " * string(t[end])[1:10] * ":  " * dtotaldeath_strfmt)

    local statetotaldeath_strfmt = Formatting.format.(statetotaldeath[end], commas=true);
    local pCOVID19stateD = Plots.plot(t, statetotaldeath, label=state[ind[1]] * " Total")
    for i = 1:length(ind)
        deathi = Float64.(deepcopy(covid19us[ind[i]].death[tind]));
        ind0 = findall(deathi .== 0.0);
        deathi[ind0] .= NaN;
        if length(ind0) != length(deathi) # if everything is NaN, don't try to plot
            Plots.plot!(covid19us[ind[i]].time[tind], deathi, label=county[ind[i]])
        end
    end
    Plots.plot(pCOVID19stateD, yscale=:log10, framestyle=:box, title=state[ind[1]] * " - COVID-19 Deaths " * "as of " * string(t[end])[1:10] * ":  " * statetotaldeath_strfmt)

    local dstatetotaldeath_strfmt = Formatting.format.(dstatetotaldeath[end], commas=true);
    local dCOVID19stateD = Plots.plot(tstate[2:end], dstatetotaldeath, label=state[ind[1]] * " Daily Death")
    for i = 1:length(ind)
        deathi = dcountydeath[i];
        #ind0 = findall(deathi .== 0);
        #deathi[ind0] .= NaN;
        Plots.plot!(tstate[2:end], deathi, label=county[ind[i]])
    end
    #Plots.plot(dCOVID19stateD, framestyle=:box, title=state[ind[1]] * " - Daily COVID-19 Deaths " * "on " * string(t[end])[1:10] * ":  " * dstatetotaldeath_strfmt, marker = (2, :circle, 2),  markerstrokewidth = 0)
    Plots.plot(dCOVID19stateD, framestyle=:box, title=state[ind[1]] * " - Daily COVID-19 Deaths " * "on " * string(t[end])[1:10] * ":  " * dstatetotaldeath_strfmt)

    local dstatetotaldeathpc_strfmt = Formatting.format.(dstatetotaldeath[end] / sum(population) * 1.0e5, commas=true, precision = 3);
    local dCOVID19statepcD = Plots.plot(tstate[2:end], dstatetotaldeath / sum(population) * 1.0e5, label=state[ind[1]] * " Daily Death")
    for i = 1:length(ind)
        deathi = dcountydeathpc[i];
        #ind0 = findall(deathi .== 0);
        #deathi[ind0] .= NaN;
        #display([i length(deathi)])
        Plots.plot!(tstate[2:end], deathi, label=county[ind[i]])
    end
    #Plots.plot(dCOVID19statepcD, framestyle=:box, title=state[ind[1]] * " - Daily COVID-19 Deaths per 100k " * "on " * string(t[end])[1:10] * ":  " * dstatetotaldeathpc_strfmt, marker = (2, :circle, 2),  markerstrokewidth = 0)
    Plots.plot(dCOVID19statepcD, framestyle=:box, title=state[ind[1]] * " - Daily COVID-19 Deaths / 100k " * "on " * string(t[end])[1:10] * ":  " * dstatetotaldeathpc_strfmt)
    
    #covid19plot_confirmed = Plots.plot(pCOVID19usa, dCOVID19usa, pCOVID19state, dCOVID19state, dCOVID19statepc, layout = l8out,  xrotation=30, size=(800,900), xticks = t[1:7:end], legend=:false);
    #covid19plot_death = Plots.plot(pCOVID19usa, dCOVID19usa, pCOVID19state, dCOVID19state, dCOVID19statepc, layout = l8out,  xrotation=30, size=(800,900), xticks = t[1:7:end], legend=:false);

    local covid19plot = Plots.plot(pCOVID19usa, pCOVID19usaD, dCOVID19usa, dCOVID19usaD, pCOVID19state, pCOVID19stateD, dCOVID19state, dCOVID19stateD, dCOVID19statepc, dCOVID19statepcD, layout = l8out,  xrotation=35, size=reasonable_resolution(), xticks = t[1:14:end], legend=:false);

    local figoutdir = "../covid19_public/timeseries/";
    #Plots.savefig(covid19plot_confirmed, figoutdir * "covid19ts_confirmed_" * filter(x -> !isspace(x), state_of_interest) * ".html")
    #Plots.savefig(covid19plot_death, figoutdir * "covid19ts_death_" * filter(x -> !isspace(x), state_of_interest) * ".html")
    Plots.savefig(covid19plot, figoutdir * "covid19ts_integrated_" * filter(x -> !isspace(x), state_of_interest) * ".html")

    #gui(covid19plot)
    #sleep(1.0)    
end