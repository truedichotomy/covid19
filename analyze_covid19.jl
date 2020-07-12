using Dates, Formatting, Plots, ColorSchemes, DataFrames

include("load_covid19_data.jl")

states_of_interest = ["Virginia","North Carolina","West Virginia","Delaware", "Wisconsin", "Minnesota", "Idaho", "Tennessee", "Alabama", "New York", "New Jersey", "Massachusetts", "Texas","Florida","California","Michigan", "Ohio", "Washington", "Oregon", "Illinois", "Oklahoma", "Maryland", "District of Columbia", "Alaska", "Arizona","Georgia","South Carolina", "Mississippi", "Maine", "Pennsylvania", "Puerto Rico", "Colorado", "New Hampshire", "Iowa", "Vermont","Hawaii"]

strnow = string(Dates.now())
strnow30 = strnow[1:4] * strnow[6:7] * strnow[9:10] * "T" * strnow[12:13] * strnow[15:16] * strnow[18:19]

# extracting county indices with land area and population
cind = findall((countyarea .> 0) .& (cpop .> 0));

reasonable_resolution() = (1000, 800)

tind = 1:length(covid19us[1].confirmed);
t = covid19us[1].time[tind];
