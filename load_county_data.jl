using Shapefile

function load_county_data(countyshppath = "/Users/gong/Box/Data/CENSUS/tl_2019_us_county/tl_2019_us_county.shp")
    return countytable = Shapefile.Table(countyshppath);
end