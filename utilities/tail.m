function y = tail(t,k)

    if isempty(k), k = 10; end
    
    y = t(end-9:end,:)

end