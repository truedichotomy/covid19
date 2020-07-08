#module map_covid19
using Dates, DataFrames, ColorSchemes, PlotlyJS

#include("load_covid19_data.jl")

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

dCONFIRMEDpc = dcconfirmed[cind] ./ cpop[cind];
bind = findall(dCONFIRMEDpc .<= 0);
dCONFIRMEDpc[bind] .= NaN;

dDEATHpc = dcdeath[cind] ./ cpop[cind];
bind = findall(dDEATHpc .<= 0);
dDEATHpc[bind] .= NaN;

df = DataFrame(LON = clon[cind], 
    LAT = clat[cind], 
    POPULATION = cpop[cind], 
    log10POPULATION = log10.(cpop[cind]), 

    CONFIRMEDpc = cconfirmed[cind] ./ cpop[cind], 
    CONFIRMED = cconfirmed[cind],
    log10CONFIRMEDpc = log10.(cconfirmed[cind] ./ cpop[cind]),

    dCONFIRMEDpc = dCONFIRMEDpc, 
    dCONFIRMED = dcconfirmed[cind],
    log10dCONFIRMEDpc = log10.(dCONFIRMEDpc),

    DEATHpc = cdeath[cind] ./ cpop[cind],
    DEATH = cdeath[cind],
    log10DEATHpc = log10.(cdeath[cind] ./ cpop[cind]),

    dDEATHpc = dDEATHpc,
    dDEATH = dcdeath[cind],
    log10dDEATHpc = log10.(dDEATHpc),
    );

function pmapconfirmed()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[:LAT], 
        lon = df[:LON], 
        marker_size=df[:log10POPULATION]*1.5, 
        marker_color=df[:log10CONFIRMEDpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        hoverinfo="text",
        hovertext=df[:CONFIRMED],
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

    title = attr(text = "Total Confirmed Cases per Capita (log10)", yref = "paper", y=0.9)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    plot(pmapsg, layout)
end

function pmapdconfirmed()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[:LAT], 
        lon = df[:LON], 
        marker_size=df[:log10POPULATION]*1.5, 
        marker_color=df[:log10dCONFIRMEDpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        hoverinfo="text",
        hovertext=df[:dCONFIRMED],
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

    title = attr(text = "Weekly Cases per Capita (log10)", yref = "paper", y=0.9)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    plot(pmapsg, layout)
end

function pmapdeath()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[:LAT], 
        lon = df[:LON], 
        marker_size=df[:log10POPULATION]*1.5, 
        marker_color=df[:log10DEATHpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        hoverinfo="text",
        hovertext=df[:DEATH],
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

    title = attr(text = "Total Death per Capita (log10)", yref = "paper", y=0.9)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    plot(pmapsg, layout)
end

function pmapddeath()
    pmapsg = PlotlyJS.scattergeo(; locationmode="USA-states", 
        lat = df[:LAT], 
        lon = df[:LON], 
        marker_size=df[:log10POPULATION]*1.5, 
        marker_color=df[:log10dDEATHpc],
        marker_colorscale="Jet",
        marker_showscale = true,
        hoverinfo="text",
        hovertext=df[:dDEATH],
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

    title = attr(text = "Weekly Death per Capita (log10)", yref = "paper", y=0.9)

    layout = Layout(; title=title, showlegend=false, geo=geo)
    plot(pmapsg, layout)
end

PlotlyJS.savefig(pmapconfirmed(), "/Volumes/GoogleDrive/My Drive/COVID19/" * "covid19map_confirmed.html"; scale=1);
PlotlyJS.savefig(pmapdeath(), "/Volumes/GoogleDrive/My Drive/COVID19/" * "covid19map_death.html", scale = 1);
PlotlyJS.savefig(pmapdconfirmed(), "/Volumes/GoogleDrive/My Drive/COVID19/" * "covid19map_delta_confirmed.html", scale=1);
PlotlyJS.savefig(pmapddeath(), "/Volumes/GoogleDrive/My Drive/COVID19/" * "covid19map_delta_death.html", scale=1);
#end