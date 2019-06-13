function y = head(t,k)

    if isempty(k), k = 10; end
    
    y = t(1:10,:)

end