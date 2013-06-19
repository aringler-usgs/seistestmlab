function [sen] = getdigitmodel(digmod)
%This function returns the sensitivity of the digitizer
    if(strcmp(digmod,'Q330'))
        sen=(2^24)/40;
    elseif(strcmp(digmod,'Q330HR'))
        sen=(2^26)/40;
    elseif(strcmp(digmod,'Q330HRx20'))
        sen=20*(2^26)/40;
    elseif(strcmp(digmod,'Q330x20'))
        sen=20*(2^24)/40;
    else
        sen=(2^24)/40;
        display('Can not find digitizer assuming 24-bit\n');
    end

end

