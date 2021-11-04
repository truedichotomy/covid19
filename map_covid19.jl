#module map_covid19
using Dates, DataFrames, ColorSchemes, PlotlyJS

#include("COVID19.jl")
#include("load_covid19_data.jl")

reasonable_resolution() = (1000, 800)

# time index
#for ti = 8:length(covid19us[1].confirmed)
#ti = 200
ti = length(covid19us[1].confirmed)

cconfirmed = [covid19us[i].confirmed[ti] for i in 1:length(covid19us)];
dcconfirmed = [mean(covid19us[i].confirmed[ti-7+1:ti] - covid19us[i].confirmed[ti-8+1:ti-1]) for i in 1:length(covid19us)];
dcconfirmedinst = [mean(covid19us[i].confirmed[ti] - covid19us[i].confirmed[ti-1]) for i in 1:length(covid19us)];
cdeath = [covid19us[i].death[ti] for i in 1:length(covid19us)];
dcdeath = [mean(covid19us[i].death[ti-7+1:ti] - covid19us[i].death[ti-8+1:ti-1]) for i in 1:length(covid19us)];
dcdeathinst = [mean(covid19us[i].death[ti] - covid19us[i].death[ti-1]) for i in 1:length(covid19us)];

# extracting county indices with land area and population
cind = findall((countyarea .> 0) .& (cpop .> 0));

tind = 1:length(covid19us[1].confirmed);
t = covid19us[1].time[tind];

# plot a map of confirmed cases
#cval = cconfirmed[cind] ./ (countyarea[cind] .* cpop[cind]);
cval = cconfirmed[cind] ./ cpop[cind];
log10cval = log10.(cval);
#sval = countyarea[cind] .* cpop[cind];
sval = cpop[cind];
log10sval = log10.(sval);

# daily confirmed cases per 100k averaged over 7 days
dCONFIRMEDpc = dcconfirmed[cind] ./ cpop[cind] .* 1e5;
bind = findall(dCONFIRMEDpc .<= 0);
dCONFIRMEDpc[bind] .= NaN;

# daily instant confirmed cases per 100k
dCONFIRMEDpcinst = dcconfirmedinst[cind] ./ cpop[cind] .* 1e5;
bind = findall(dCONFIRMEDpcinst .<= 0);
dCONFIRMEDpcinst[bind] .= NaN;

# daily death per 100k averaged over 7 days
dDEATHpc = dcdeath[cind] ./ cpop[cind] .* 1e5;
bind = findall(dDEATHpc .<= 0);
dDEATHpc[bind] .= NaN;

# daily instant death per 100k
dDEATHpcinst = dcdeathinst[cind] ./ cpop[cind] .* 1e5;
bind = findall(dDEATHpcinst .<= 0);
dDEATHpcinst[bind] .= NaN;

df = DataFrame(LON = clon[cind], 
    LAT = clat[cind], 
    POPULATION = cpop[cind], 
    log10POPULATION = log10.(cpop[cind]), 
    logPOPULATION = log.(cpop[cind]), 
    nrootPOPULATION = (cpop[cind]) .^ (1.0/2.85)/5,

    CONFIRMEDpc = cconfirmed[cind] ./ cpop[cind] .* 1e5, 
    CONFIRMED = cconfirmed[cind],
    log10CONFIRMEDpc = log10.(cconfirmed[cind] ./ cpop[cind] .* 1e5),

    dCONFIRMEDpc = dCONFIRMEDpc, 
    dCONFIRMED = dcconfirmed[cind],
    log10dCONFIRMEDpc = log10.(dCONFIRMEDpc),

    dCONFIRMEDpcinst = dCONFIRMEDpcinst, 
    dCONFIRMEDinst = dcconfirmedinst[cind],
    log10dCONFIRMEDpcinst = log10.(dCONFIRMEDpcinst),

    DEATHpc = cdeath[cind] ./ cpop[cind] .* 1e5,
    DEATH = cdeath[cind],
    log10DEATHpc = log10.(cdeath[cind] ./ cpop[cind] .* 1e5),

    dDEATHpc = dDEATHpc,
    dDEATH = dcdeath[cind],
    log10dDEATHpc = log10.(dDEATHpc),

    dDEATHpcinst = dDEATHpcinst,
    dDEATHinst = dcdeathinst[cind],
    log10dDEATHpcinst = log10.(dDEATHpcinst),
    );

function pmapconfirmed()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[!, :LAT], 
        lon = df[!, :LON], 
        marker_size=df[!, :nrootPOPULATION], 
        marker_color=df[!, :log10CONFIRMEDpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        marker_cmin = 3,
        marker_cmax = 4.3,

        hoverinfo="text",
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[!, :POPULATION]) .* "<br>" .* 
            "Confirmed Cases (actual): " .* string.(df[!, :CONFIRMED]) .* "<br>" .* 
            "Confirmed Cases per 100k: " .* string.(round.(df[!, :CONFIRMEDpc], digits=2)) .* "<br>" .* 
            "Cumulative Deaths (actual): " .* string.(df[!, :DEATH]) .* "<br>" .* 
            "Cumulative Deaths per 100k: " .* string.(round.(df[!, :DEATHpc], digits=2)) .* "<br>" .*
            "% infected with COVID19: " .* string.(round.(df[!, :CONFIRMED] ./ df[!, :POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[!, :DEATH] ./ df[!, :CONFIRMED] .*100, digits=2)) 
        );

    geo = attr(scope="usa", 
        projection_type="ablbers usa", 
        showland=true, 
        landcolor="rgb(220, 220, 220)", 
        subunitwidth=1, 
        countrywidth=1, 
        subunitcolor="rgb(255,255,255)", 
        countrycolor="rgb(255,255,255)", 
        );

    title = attr(text = "Cumulative Confirmed Cases per 100k " * string(t[ti])[1:10] * " (log10) <br><sub><a href=\"https://truedichotomy.github.io/covid19_public/\">https://truedichotomy.github.io/covid19_public/</a></sub></br>", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    PlotlyJS.plot(pmapsg, layout)
end

function pmapdconfirmed()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[!, :LAT], 
        lon = df[!, :LON], 
        #marker_size=df[!, :logPOPULATION]/1.3, 
        marker_size=df[!, :nrootPOPULATION], 
        marker_color=df[!, :log10dCONFIRMEDpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        marker_cmin = -0.5,
        marker_cmax = 2.5,
        hoverinfo="text",
        #hovertext=string.(df[!, :dCONFIRMED]) .* " " .* county[cind],
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[!, :POPULATION]) .* "<br>" .* 
            "Confirmed Cases (actual): " .* string.(df[!, :CONFIRMED]) .* "<br>" .* 
            "Confirmed Cases per 100k: " .* string.(round.(df[!, :CONFIRMEDpc], digits=2)) .* "<br>" .* 
            "Daily New Cases (actual): " .* string.(round.(df[!, :dCONFIRMED], digits=2)) .* "<br>" .* 
            "Daily New Cases per 100k: " .* string.(round.(df[!, :dCONFIRMEDpc], digits=2)) .* "<br>" .* 
            "% infected with COVID19: " .* string.(round.(df[!, :CONFIRMED] ./ df[!, :POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[!, :DEATH] ./ df[!, :CONFIRMED] .*100, digits=2)) 
        );

    geo = attr(scope="usa", 
        projection_type="ablbers usa", 
        showland=true, 
        landcolor="rgb(220, 220, 220)", 
        subunitwidth=1, 
        countrywidth=1, 
        subunitcolor="rgb(255,255,255)", 
        countrycolor="rgb(255,255,255)", 
        );

    title = attr(text = "Daily New Cases per 100k " * string(t[ti])[1:10] * " (log10, 7 day avg.) <br><sub><a href=\"https://truedichotomy.github.io/covid19_public/\">https://truedichotomy.github.io/covid19_public/</a></sub></br>", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    PlotlyJS.plot(pmapsg, layout)
end

function pmapdconfirmedinst()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[!, :LAT], 
        lon = df[!, :LON], 
        marker_size=df[!, :nrootPOPULATION], 
        #marker_size=df[!, :logPOPULATION]/1.3, 
        marker_color=df[!, :log10dCONFIRMEDpcinst],
        marker_colorscale="Jet",
        marker_showscale = true,
        marker_cmin = -0.5,
        marker_cmax = 2.5,
        hoverinfo="text",
        #hovertext=string.(df[!, :dCONFIRMED]) .* " " .* county[cind],
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[!, :POPULATION]) .* "<br>" .* 
            "Confirmed Cases (actual): " .* string.(df[!, :CONFIRMED]) .* "<br>" .* 
            "Confirmed Cases per 100k: " .* string.(round.(df[!, :CONFIRMEDpc], digits=2)) .* "<br>" .* 
            "Daily New Cases (actual): " .* string.(df[!, :dCONFIRMEDinst]) .* "<br>" .* 
            "Daily New Cases per 100k: " .* string.(round.(df[!, :dCONFIRMEDpcinst], digits=2)) .* "<br>" .*
            "% infected with COVID19: " .* string.(round.(df[!, :CONFIRMED] ./ df[!, :POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[!, :DEATH] ./ df[!, :CONFIRMED] .*100, digits=2)) 
        );

    geo = attr(scope="usa", 
        projection_type="ablbers usa", 
        showland=true, 
        landcolor="rgb(220, 220, 220)", 
        subunitwidth=1, 
        countrywidth=1, 
        subunitcolor="rgb(255,255,255)", 
        countrycolor="rgb(255,255,255)", 
        );

    title = attr(text = "Daily New Cases per 100k " * string(t[ti])[1:10] * " (log10) <br><sub><a href=\"https://truedichotomy.github.io/covid19_public/\">https://truedichotomy.github.io/covid19_public/</a></sub></br>", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    PlotlyJS.plot(pmapsg, layout)
end


function pmapdeath()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[!, :LAT], 
        lon = df[!, :LON], 
        marker_size=df[!, :nrootPOPULATION], 
        #marker_size=df[!, :logPOPULATION]/1.3, 
        marker_color=df[!, :log10DEATHpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        marker_cmin = 0,
        marker_cmax = 2.5,
        hoverinfo="text",
        #hovertext=string.(df[!, :DEATH]) .* " " .* county[cind],
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[!, :POPULATION]) .* "<br>" .* 
            "Confirmed Cases (actual): " .* string.(df[!, :CONFIRMED]) .* "<br>" .* 
            "Confirmed Cases per 100k: " .* string.(round.(df[!, :CONFIRMEDpc], digits=2)) .* "<br>" .* 
            "Cumulative Deaths (actual): " .* string.(df[!, :DEATH]) .* "<br>" .* 
            "Cumulative Deaths per 100k: " .* string.(round.(df[!, :DEATHpc], digits=2)) .* "<br>" .*
            "% infected with COVID19: " .* string.(round.(df[!, :CONFIRMED] ./ df[!, :POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[!, :DEATH] ./ df[!, :CONFIRMED] .*100, digits=2)) 
        );

    geo = attr(scope="usa", 
        projection_type="ablbers usa", 
        showland=true, 
        landcolor="rgb(220, 220, 220)", 
        subunitwidth=1, 
        countrywidth=1, 
        subunitcolor="rgb(255,255,255)", 
        countrycolor="rgb(255,255,255)", 
        );

    title = attr(text = "Cumulative Death per 100k " * string(t[ti])[1:10] * " (log10) <br><sub><a href=\"https://truedichotomy.github.io/covid19_public/\">https://truedichotomy.github.io/covid19_public/</a></sub></br>", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    PlotlyJS.plot(pmapsg, layout)
end

function pmapddeath()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[!, :LAT], 
        lon = df[!, :LON], 
        #marker_size=df[!, :logPOPULATION]/1.3, 
        marker_size=df[!, :nrootPOPULATION], 
        marker_color=df[!, :log10dDEATHpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        marker_cmin = -1.5,
        marker_cmax = 1,
        hoverinfo="text",
        #hovertext=string.(df[!, :dDEATH]) .* " " .* county[cind],
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[!, :POPULATION]) .* "<br>" .* 
            "Total Deaths (actual): " .* string.(df[!, :DEATH]) .* "<br>" .* 
            "Total Deaths per 100k: " .* string.(round.(df[!, :DEATHpc], digits=2)) .* "<br>" .*
            "Daily New Deaths (actual): " .* string.(round.(df[!, :dDEATH], digits=2)) .* "<br>" .* 
            "Daily New Deaths per 100k: " .* string.(round.(df[!, :dDEATHpc], digits=2)) .* "<br>" .* 
            "% infected with COVID19: " .* string.(round.(df[!, :CONFIRMED] ./ df[!, :POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[!, :DEATH] ./ df[!, :CONFIRMED] .*100, digits=2)) 
        );

    geo = attr(scope="usa", 
        projection_type="ablbers usa", 
        showland=true, 
        landcolor="rgb(220, 220, 220)", 
        subunitwidth=1, 
        countrywidth=1, 
        subunitcolor="rgb(255,255,255)", 
        countrycolor="rgb(255,255,255)", 
        );

    title = attr(text = "Daily New Deaths per 100k " * string(t[ti])[1:10] * " (log10, 7 day avg.) <br><sub><a href=\"https://truedichotomy.github.io/covid19_public/\">https://truedichotomy.github.io/covid19_public/</a></sub></br>", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    PlotlyJS.plot(pmapsg, layout)
end

function pmapddeathinst()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[!, :LAT], 
        lon = df[!, :LON], 
        #marker_size=df[!, :logPOPULATION]/1.3, 
        marker_size=df[!, :nrootPOPULATION], 

        marker_color=df[!, :log10dDEATHpcinst],
        marker_colorscale="Jet",
        marker_showscale = true,
        marker_cmin = -1.5,
        marker_cmax = 1,
        hoverinfo="text",
        #hovertext=string.(df[!, :dDEATH]) .* " " .* county[cind],
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[!, :POPULATION]) .* "<br>" .* 
            "Total Deaths (actual): " .* string.(df[!, :DEATH]) .* "<br>" .* 
            "Total Deaths per 100k: " .* string.(round.(df[!, :DEATHpc], digits=2)) .* "<br>" .*
            "Daily New Deaths (actual): " .* string.(df[!, :dDEATHinst]) .* "<br>" .* 
            "Daily New Deaths per 100k: " .* string.(round.(df[!, :dDEATHpcinst], digits=2)) .* "<br>" .* 
            "% infected with COVID19: " .* string.(round.(df[!, :CONFIRMED] ./ df[!, :POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[!, :DEATH] ./ df[!, :CONFIRMED] .*100, digits=2)) 
        );

    geo = attr(scope="usa", 
        projection_type="ablbers usa", 
        showland=true, 
        landcolor="rgb(220, 220, 220)", 
        subunitwidth=1, 
        countrywidth=1, 
        subunitcolor="rgb(255,255,255)", 
        countrycolor="rgb(255,255,255)", 
        );

    title = attr(text = "Daily New Deaths per 100k " * string(t[ti])[1:10] * " (log10) <br><sub><a href=\"https://truedichotomy.github.io/covid19_public/\">https://truedichotomy.github.io/covid19_public/</a></sub></br>", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    PlotlyJS.plot(pmapsg, layout)
end


#figoutdir = "/Volumes/GoogleDrive/My Drive/COVID19/";
figoutdir = "../covid19_public/maps/";

#PlotlyJS._js_path = "https://cdn.plot.ly/plotly-latest.min.js";

PlotlyJS.savefig(pmapconfirmed(), figoutdir * "covid19map_confirmed.html", format="html");
PlotlyJS.savefig(pmapdconfirmed(), figoutdir * "covid19map_delta_confirmed_7days.html", format="html");
PlotlyJS.savefig(pmapdconfirmedinst(), figoutdir * "covid19map_delta_confirmed_latest.html", format="html");
PlotlyJS.savefig(pmapdeath(), figoutdir * "covid19map_death.html", format="html");
PlotlyJS.savefig(pmapddeath(), figoutdir * "covid19map_delta_death_7days.html", format="html");
PlotlyJS.savefig(pmapddeathinst(), figoutdir * "covid19map_delta_death_latest.html", format="html");

#PlotlyJS.savehtml(pmapconfirmed(), figoutdir * "covid19map_confirmed.html", :remote);
#PlotlyJS.savehtml(pmapdconfirmed(), figoutdir * "covid19map_delta_confirmed_7days.html", :remote);
#PlotlyJS.savehtml(pmapdconfirmedinst(), figoutdir * "covid19map_delta_confirmed_latest.html", :remote);
#PlotlyJS.savehtml(pmapdeath(), figoutdir * "covid19map_death.html", :remote);
#PlotlyJS.savehtml(pmapddeath(), figoutdir * "covid19map_delta_death_7days.html", :remote);
#PlotlyJS.savehtml(pmapddeathinst(), figoutdir * "covid19map_delta_death_latest.html", :remote);
#end