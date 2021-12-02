using PlotlyJS

function linescatter1()
    trace1 = scatter(;x=1:4, y=[10, 15, 13, 17], mode="markers")
    plot([trace1])
end
linescatter1()

testio = open("test.jpg", "w")
PlotlyJS.savefig(testio, linescatter1(); format="jpeg");
close(testio)
