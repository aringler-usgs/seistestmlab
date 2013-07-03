function [pspec, per, stahand, tseries, ttime, mabsvolt ...
    ] = noise(noisedata, sensor,digitizer,stimestr,etimestr,lowpass)
    %Compute spectra and correct for response
    %Read in data
    try
        [noisedata,~]=rdmseed(noisedata);
    catch ME
        display('Error reading in data \n');
    end

    net=deblank(noisedata(1,1).NetworkCode);
    sta=deblank(noisedata(1,1).StationIdentifierCode);
    loc=deblank(noisedata(1,1).LocationIdentifier);
    chan=deblank(noisedata(1,1).ChannelIdentifier);
    sps=noisedata(1,1).SampleRate;
    year=noisedata(1,1).RecordStartTimeISO;
    year=year(1:8);
    day=year(6:8);
    year=year(1:4);
    noisetime=cat(1,noisedata.t);
    noisedata=cat(1,noisedata.d);
    if(~isempty(stimestr))
        stimeind=strfind(stimestr,':');
        stimehour = str2double(stimestr(1:stimeind-1));
        stimemin = str2double(stimestr(stimeind+1:length(stimestr)));
        stime = datenum(str2double(year),01,str2double(day), ...
            stimehour,stimemin,0);
        noisedata=noisedata(find(noisetime>= stime));
        noisetime=noisetime(find(noisetime>= stime));
    end
    if(~isempty(etimestr))
        etimeind=strfind(etimestr,':');
        etimehour = str2double(etimestr(1:etimeind-1));
        etimemin = str2double(etimestr(etimeind+1:length(etimestr)));
        etime = datenum(str2double(year),01,str2double(day), ...
            etimehour,etimemin,0);
        noisedata=noisedata(find(noisetime<= etime));
        noisetime=noisetime(find(noisetime<= etime));
    end
    
    

    %Compute the spectra
    %[pspec,fre]=pwelch(noisedata,floor(length(noisedata)/10), ...
     %   floor(length(noisedata)/20),floor(length(noisedata)/10),sps);
	[pspec,fre]=psd(noisedata,floor(length(noisedata)/10),sps);
    pspec = pspec/sps;
    
    %Get the response and correct
    [zer,pol,gai]=getrespmodel(sensor);
    resp=1;
    for ind=1:length(pol)
        resp=resp./(2*pi*1i*fre-pol(ind));
    end
    for ind=1:length(zer)
        resp=resp.*(2*pi*1i*fre-zer(ind));
    end
    

    digsen=getdigitmodel(digitizer);

    resp=resp/abs(resp(find(fre<.1  ,1,'last')));
    if(~strcmp(sensor,'Epi-EST') && ~strcmp(sensor,'Titan') && ...
            ~strcmp(sensor,'CMG-5T') && ~strcmp(sensor,'147-01/3') && ...
            ~strcmp(sensor,'PA-23'))
        resp=((2*pi*1i*fre).^-1).*resp*gai*digsen;
    else
        resp=resp*gai*digsen;
    end

    pspec=10*log10(pspec./(abs(resp).^2));
    per = 1./fre;
    stahand = [ net ' ' sta ' ' loc ' ' chan ' ' year ' ' day];
    tseries = detrend(noisedata/digsen);
    if(lowpass)
        h=fdesign.lowpass('N,F3db',8,0.1,sps);  
        d=design(h,'FIR');
        tseries = filtfilt(d.Numerator,1,tseries);
    end
    ttime = noisetime;
    mabsvolt = mean(abs(tseries));
end



