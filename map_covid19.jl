#module map_covid19
using Dates, DataFrames, ColorSchemes, PlotlyJS

include("load_covid19_data.jl")

# extracting county indices with land area and population
cind = findall((countyarea .> 0) .& (cpop .> 0));

reasonable_resolution() = (1000, 800)

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
        lat = df[:LAT], 
        lon = df[:LON], 
        marker_size=df[:logPOPULATION]/1.2, 
        marker_color=df[:log10CONFIRMEDpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        hoverinfo="text",
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[:POPULATION]) .* "<br>" .* 
            "Confirmed Cases (actual): " .* string.(df[:CONFIRMED]) .* "<br>" .* 
            "Confirmed Cases per 100k: " .* string.(round.(df[:CONFIRMEDpc], digits=2)) .* "<br>" .* 
            "% infected with COVID19: " .* string.(round.(df[:CONFIRMED] ./ df[:POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[:DEATH] ./ df[:CONFIRMED] .*100, digits=2)) 

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

    title = attr(text = "Cumulative Confirmed Cases per 100k " * string(t[end])[1:10] * " (log10)", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    plot(pmapsg, layout)
end

function pmapdconfirmed()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[:LAT], 
        lon = df[:LON], 
        marker_size=df[:logPOPULATION]/1.2, 
        marker_color=df[:log10dCONFIRMEDpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        marker_cmin = -0.6,
        marker_cmax = 2.3,
        hoverinfo="text",
        #hovertext=string.(df[:dCONFIRMED]) .* " " .* county[cind],
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[:POPULATION]) .* "<br>" .* 
            "Confirmed Cases (actual): " .* string.(df[:CONFIRMED]) .* "<br>" .* 
            "Confirmed Cases per 100k: " .* string.(round.(df[:CONFIRMEDpc], digits=2)) .* "<br>" .* 
            "Daily New Cases (actual): " .* string.(df[:dCONFIRMED]) .* "<br>" .* 
            "Daily New Cases per 100k: " .* string.(round.(df[:dCONFIRMEDpc], digits=2)) .* "<br>" .* 
            "% infected with COVID19: " .* string.(round.(df[:CONFIRMED] ./ df[:POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[:DEATH] ./ df[:CONFIRMED] .*100, digits=2)) 
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

    title = attr(text = "Daily New Cases per 100k " * string(t[end])[1:10] * " (log10, 7 day avg.)", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    plot(pmapsg, layout)
end

function pmapdconfirmedinst()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[:LAT], 
        lon = df[:LON], 
        marker_size=df[:logPOPULATION]/1.2, 
        marker_color=df[:log10dCONFIRMEDpcinst],
        marker_colorscale="Jet",
        marker_showscale = true,
        marker_cmin = -0.6,
        marker_cmax = 2.3,
        hoverinfo="text",
        #hovertext=string.(df[:dCONFIRMED]) .* " " .* county[cind],
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[:POPULATION]) .* "<br>" .* 
            "Confirmed Cases (actual): " .* string.(df[:CONFIRMED]) .* "<br>" .* 
            "Confirmed Cases per 100k: " .* string.(round.(df[:CONFIRMEDpc], digits=2)) .* "<br>" .* 
            "Daily New Cases (actual): " .* string.(df[:dCONFIRMEDinst]) .* "<br>" .* 
            "Daily New Cases per 100k: " .* string.(round.(df[:dCONFIRMEDpcinst], digits=2)) .* "<br>" .*
            "% infected with COVID19: " .* string.(round.(df[:CONFIRMED] ./ df[:POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[:DEATH] ./ df[:CONFIRMED] .*100, digits=2)) 
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

    title = attr(text = "Daily New Cases per 100k " * string(t[end])[1:10] * " (log10)", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    plot(pmapsg, layout)
end


function pmapdeath()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[:LAT], 
        lon = df[:LON], 
        marker_size=df[:logPOPULATION]/1.2, 
        marker_color=df[:log10DEATHpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        hoverinfo="text",
        #hovertext=string.(df[:DEATH]) .* " " .* county[cind],
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[:POPULATION]) .* "<br>" .* 
            "Confirmed Cases (actual): " .* string.(df[:DEATH]) .* "<br>" .* 
            "Confirmed Cases per 100k: " .* string.(round.(df[:DEATHpc], digits=2)) .* "<br>" .*
            "% infected with COVID19: " .* string.(round.(df[:CONFIRMED] ./ df[:POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[:DEATH] ./ df[:CONFIRMED] .*100, digits=2)) 
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

    title = attr(text = "Cumulative Death per 100k " * string(t[end])[1:10] * " (log10)", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    plot(pmapsg, layout)
end

function pmapddeath()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[:LAT], 
        lon = df[:LON], 
        marker_size=df[:logPOPULATION]/1.2, 
        marker_color=df[:log10dDEATHpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        hoverinfo="text",
        #hovertext=string.(df[:dDEATH]) .* " " .* county[cind],
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[:POPULATION]) .* "<br>" .* 
            "Confirmed Cases (actual): " .* string.(df[:DEATH]) .* "<br>" .* 
            "Confirmed Cases per 100k: " .* string.(round.(df[:DEATHpc], digits=2)) .* "<br>" .*
            "Daily New Deaths (actual): " .* string.(df[:dDEATH]) .* "<br>" .* 
            "Daily New Deaths per 100k: " .* string.(round.(df[:dDEATHpc], digits=2)) .* "<br>" .* 
            "% infected with COVID19: " .* string.(round.(df[:CONFIRMED] ./ df[:POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[:DEATH] ./ df[:CONFIRMED] .*100, digits=2)) 
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

    title = attr(text = "Daily New Deaths per 100k " * string(t[end])[1:10] * " (log10, 7 day avg.)", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    plot(pmapsg, layout)
end

function pmapddeathinst()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[:LAT], 
        lon = df[:LON], 
        marker_size=df[:logPOPULATION]/1.2, 
        marker_color=df[:log10dDEATHpcinst],
        marker_colorscale="Jet",
        marker_showscale = true,
        hoverinfo="text",
        #hovertext=string.(df[:dDEATH]) .* " " .* county[cind],
        hovertext=
            "County: " .* county[cind] .* ", " .* state[cind] .* "<br>" .*
            "Population: " .* string.(df[:POPULATION]) .* "<br>" .* 
            "Confirmed Cases (actual): " .* string.(df[:DEATH]) .* "<br>" .* 
            "Confirmed Cases per 100k: " .* string.(round.(df[:DEATHpc], digits=2)) .* "<br>" .*
            "Daily New Deaths (actual): " .* string.(df[:dDEATHinst]) .* "<br>" .* 
            "Daily New Deaths per 100k: " .* string.(round.(df[:dDEATHpcinst], digits=2)) .* "<br>" .* 
            "% infected with COVID19: " .* string.(round.(df[:CONFIRMED] ./ df[:POPULATION] .* 100, digits=2)) .* "<br>" .*
            "% death rate: " .* string.(round.(df[:DEATH] ./ df[:CONFIRMED] .*100, digits=2)) 
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

    title = attr(text = "Daily New Deaths per 100k " * string(t[end])[1:10] * " (log10, 7 day avg.)", yref = "paper", y=1.0)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    plot(pmapsg, layout)
end


#figoutdir = "/Volumes/GoogleDrive/My Drive/COVID19/";
figoutdir = "/Users/gong/GitHub/covid19_public/maps/";

#PlotlyJS._js_path = "https://cdn.plot.ly/plotly-latest.min.js";

PlotlyJS.savehtml(pmapconfirmed(), figoutdir * "covid19map_confirmed.html", :remote);
PlotlyJS.savehtml(pmapdeath(), figoutdir * "covid19map_death.html", :remote);
PlotlyJS.savehtml(pmapdconfirmed(), figoutdir * "covid19map_delta_confirmed_7days.html", :remote);
PlotlyJS.savehtml(pmapdconfirmedinst(), figoutdir * "covid19map_delta_confirmed_latest.html", :remote);
PlotlyJS.savehtml(pmapddeath(), figoutdir * "covid19map_delta_death_7days.html", :remote);
PlotlyJS.savehtml(pmapddeath(), figoutdir * "covid19map_delta_death_latest.html", :remote);
#end