function i=ts(pop,m)

    S=randsample(numel(pop),m)    
    [~, j]=min(pop(S))
    i=S(j)

end