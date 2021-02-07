function myfunc()
    Plots.plot([1:100 1:100]); 
    for i = 1:1000
        Plots.plot!([1:100 1:100]);
    end
end