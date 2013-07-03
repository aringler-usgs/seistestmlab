function noisemainplot
% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.
 
    digtype={'Q330HR','Q330','Q330HRx20','Q330x20'};
    sentype={'STS-1','STS-1t5','STS-2SGgen1','STS-2SGgen2', ...
        'STS-2SGgen3', 'STS-2HGgen1', 'STS-2HGgen2', 'STS-2HGgen3', ...
        'STS-2.5', 'KS-54000','KS-36000','CMG-3T','TR-240','TR-120', 'TR-CMPT', ...
        'Titan','147-01/3','Epi-EST','PA-23'};
    
    nlnm=load('auxfiles/NLNM.txt');
    nhnm=load('auxfiles/NHNM.txt');


    %  Create and then hide the GUI as it is being constructed.
    f = figure('Visible','off','Position',[1060,500,850,850]);
 
    %  Construct the components.
    hchan1 = uicontrol('Style','pushbutton','String','Channel 1',...
          'Position',[750,800,70,25],...
          'Callback',{@sen1button_Callback});
    hsen1 = uicontrol('Style','text','String','Sensor 1 Type',...
          'Position',[750,770,100,15]);
    hpopupsen1 = uicontrol('Style','popupmenu',...
          'String',sentype,...
          'Position',[750,740,100,25],...
          'Callback',{@popup_menu_Callback_sen_1});
    hdig1 = uicontrol('Style','text','String','Digitizer 1 Type',...
          'Position',[750,710,100,15]);
    hpopupdig1 = uicontrol('Style','popupmenu',...
          'String',digtype,...
          'Position',[750,680,100,25],...
          'Callback',{@popup_menu_Callback_dig_1});
   
    hchan2 = uicontrol('Style','pushbutton','String','Channel 2',...
          'Position',[750,640,70,25],...
          'Callback',{@sen2button_Callback});
    hsen2 = uicontrol('Style','text','String','Sensor 2',...
          'Position',[750,610,100,15]);
    hpopupsen2 = uicontrol('Style','popupmenu',...
          'String',sentype,...
          'Position',[750,580,100,25],...
          'Callback',{@popup_menu_Callback_sen_2});
    hdig2 = uicontrol('Style','text','String','Digitizer 2 Type',...
          'Position',[750,550,100,15]);
    hpopupdig2 = uicontrol('Style','popupmenu',...
          'String',digtype,...
          'Position',[750,520,100,25],...
          'Callback',{@popup_menu_Callback_dig_2});
      
    hchan3 = uicontrol('Style','pushbutton',...
          'String','Channel 3',...
          'Position',[750,480,70,25],...
          'Callback',{@sen3button_Callback}); 
    hsen3 = uicontrol('Style','text','String','Sensor 3 Type',...
          'Position',[750,450,100,15]);
    hpopupsen3 = uicontrol('Style','popupmenu',...
          'String',sentype,...
          'Position',[725,420,100,25],...
          'Callback',{@popup_menu_Callback_sen_3});
    hpopupdig3 = uicontrol('Style','popupmenu',...
          'String',digtype,...
          'Position',[700,360,100,25],...
          'Callback',{@popup_menu_Callback_dig_3});
    hdig3 = uicontrol('Style','text','String','Digitizer 3 Type',...
          'Position',[700,390,100,15]);
    plotme = uicontrol('Style','pushbutton',...
          'String','Plot Me',...
          'Position',[700,310,100,25],...
          'Callback',{@plot_Callback}); 
    clearme = uicontrol('Style','pushbutton',...
          'String','Clear Data',...
          'Position',[700,280,100,25],...
          'Callback',{@clearme_Callback});
    saveme = uicontrol('Style','pushbutton',...
          'String','Save Plot',...
          'Position',[700,240,100,25],...
          'Callback',{@saveme_Callback});
    starttime = uicontrol('Style','edit',...
          'String','00:00',...
          'Position',[700,210,100,15],...
          'Callback',{@starttime_Callback});
    hstime = uicontrol('Style','text','String','Start Time',...
          'Position',[750,190,100,15]); 
    endtime = uicontrol('Style','edit',...
          'String','24:00',...
          'Position',[700,150,100,15],...
          'Callback',{@endtime_Callback});
      hetime = uicontrol('Style','text','String','End Time',...
          'Position',[750,130,100,15]); 
      
    lowpass = uicontrol('Style','pushbutton',...
          'String','Low Pass',...
          'Position',[700,90,100,25],...
          'Callback',{@lowpass_Callback});
      
    ha = axes('Units','Pixels','Position',[100,300,480,450]); 
    align([hchan1,hsen1,hchan2,hsen2,hchan3,hsen3,hpopupsen1, ...
        hpopupsen2, hpopupsen3, hpopupdig1, hpopupdig2, hpopupdig3, ...
        hdig1, hdig2, hdig3, plotme, clearme, saveme, ...
        starttime, endtime, hstime, hetime, lowpass],'Center','None');
   
    datafile1=[];
    datafile2=[];
    datafile3=[];
    dig1='Q330HR';
    dig2='Q330HR';
    dig3='Q330HR';
    sen1='STS-1';
    sen2='STS-1';
    sen3='STS-1';
    stahand1='';
    stahand2='';
    stahand3='';
    etimestr='';
    stimestr='';
    lowpass=0;
   
   % Initialize the GUI.
   % Change units to normalized so components resize 
   % automatically.
   set([f,ha,hchan1,hsen1,hchan2,hsen2,hchan3,hsen3,hpopupsen1, ...
       hpopupsen2, hpopupsen3, hpopupdig1, hpopupdig2, hpopupdig3, ...
       hdig1, hdig2, hdig3, plotme, clearme, saveme, ...
       starttime, endtime, hstime, hetime, lowpass],...
   'Units','normalized');
   %Create a plot in the axes.
   subplot(10,6,[ 1 2 3 4 5 7 8 9 10 11 13 14 15 16 17 19 20 21 22 23 ] )
   p1=semilogx(nlnm(:,1),nlnm(:,4),'color','k','LineWidth',3);
   hold on
   semilogx(nhnm(:,1),nhnm(:,2),'color','k','LineWidth',3);
   set(gca,'FontSize',14);
   xlim([.01 1000]);
   ylim([-200 -80]);
   legend(p1,'NLNM','FontSize',14,'Location','NorthWest');
   hold off
   title('Noise Estimate','FontSize',14);
   xlabel('Period (s)','FontSize',14);
   ylabel('Power (dB)','FontSize',14);
   subplot(10,6,[ 31 32 33 34 35])
   plot(-1,-1)
   xlim([0 1000]);
   xlabel('Time (HH:MM)','FontSize',14);
   title('Channel 1 Time Series','FontSize',14);
   set(gca,'fontsize',14);
   ylabel('Volts');
   subplot(10,6,[ 43 44 45 46 47])
   plot(-1,-1)
   xlim([0 1000]);
   xlabel('Time (HH:MM)','FontSize',14);
   title('Channel 2 Time Series','FontSize',14);
   set(gca,'fontsize',14);
   ylabel('Volts');
   subplot(10,6,[ 55 56 57 58 59])
   plot(-1,-1)
   xlim([0 1000]);
   set(gca,'fontsize',14);
   xlabel('Time (HH:MM)','FontSize',14);
   ylabel('Volts');
   title('Channel 3 Time Series','FontSize',14);
   
   
   
   
   % Assign the GUI a name to appear in the window title.
    set(f,'Name','Noise Estimate')
   % Move the GUI to the center of the screen.
    movegui(f,'center')
   % Make the GUI visible.
    set(gcf, 'color', [.3 .7 .7]);
    set(gcf,'MenuBar','none','ToolBar','none');
    set(f,'Visible','on');
  
   
    function popup_menu_Callback_sen_1(source,~) 
        str = get(source, 'String');
        val = get(source,'Value');
        sen1=str{val};
    end

    function popup_menu_Callback_sen_2(source,~) 
        str = get(source, 'String');
        val = get(source,'Value');
        sen2=str{val};
    end

    function popup_menu_Callback_sen_3(source,~) 
        str = get(source, 'String');
        val = get(source,'Value');
        sen3=str{val};
    end

    function popup_menu_Callback_dig_1(source,~) 
        str = get(source, 'String');
        val = get(source,'Value');
        dig1=str{val};
    end

    function popup_menu_Callback_dig_2(source,~) 
        str = get(source, 'String');
        val = get(source,'Value');
        dig2=str{val};
    end

    function popup_menu_Callback_dig_3(source,~) 
        str = get(source, 'String');
        val = get(source,'Value');
        dig3=str{val};
    end
  
    % Push button callbacks. Each callback plots current_data in
    % the specified plot type.
 
    function sen1button_Callback(~,~) 
        if(~isempty(datafile3))
            direstart = datafile3;
            if(strcmp(computer,'PCWIN64') || strcmp(computer,'PCWIN'))
                extend = strfind(direstart,'\');
            else
                extend = strfind(direstart,'/');
            end
            direstart = direstart(1:extend(length(extend)));
            [FileName,PathName] = uigetfile('*.seed', ...
                'Select the Seed File', direstart);
        else
            [FileName,PathName] = uigetfile('*.seed', ...
                'Select the Seed File');
        end
        datafile1 = fullfile(PathName,FileName);
    end
 
    function sen2button_Callback(~,~)
        if(~isempty(datafile1))
            direstart = datafile1;
            if(strcmp(computer,'PCWIN64') || strcmp(computer,'PCWIN'))
                extend = strfind(direstart,'\');
            else
                extend = strfind(direstart,'/');
            end
            direstart = direstart(1:extend(length(extend)));
            [FileName,PathName] = uigetfile('*.seed', ...
                'Select the Seed File', direstart);
        else
            [FileName,PathName] = uigetfile('*.seed', ...
                'Select the Seed File');
        end
        datafile2 = fullfile(PathName,FileName);
    end
 
    function sen3button_Callback(~,~)
        if(~isempty(datafile2))
            direstart = datafile2;
            if(strcmp(computer,'PCWIN64') || strcmp(computer,'PCWIN'))
                extend = strfind(direstart,'\');
            else
                extend = strfind(direstart,'/');
            end
            direstart = direstart(1:extend(length(extend)));
            [FileName,PathName] = uigetfile('*.seed', ...
                'Select the Seed File', direstart);
        else
            [FileName,PathName] = uigetfile('*.seed', ...
                'Select the Seed File');
        end
        datafile3 = fullfile(PathName,FileName);
    end 

    function plot_Callback(~,~)
        phand1=[];
        phand2=[];
        phand3=[];
        stahand1=[];
        stahand2=[];
        stahand3=[];
        if(~isempty(datafile1))
            [pspec1, per1, stahand1, tseries1,ttime1, mabsvolt1, ...
                ] = noise(datafile1, sen1,dig1,stimestr,etimestr, lowpass);
            thand1=stahand1(length(stahand1)-8:length(stahand1));
            stahand1=stahand1(1:length(stahand1)-8);
            subplot(10,6,[ 1 2 3 4 5 7 8 9 10 11 13 14 15 16 17 19 20 21 22 23 ] )
            phand1=semilogx(per1,pspec1,'color','r'); 
            hold on
            subplot(10,6,[ 31 32 33 34 35])
            plot(ttime1,tseries1,'color','r');
            datetick('x',15)
            xlabel('Time (HH:MM)','FontSize',14);
            ylabel('Volts');
            title(['Channel 1 Time Series ' thand1 ' ' ...
                num2str(roundn(1000*mabsvolt1,-2)) ' mV'],'FontSize',14);
            set(gca,'fontsize',14);
        end
        if(~isempty(datafile2))
            [pspec2, per2, stahand2, tseries2,ttime2, mabsvolt2 ...
                ] = noise(datafile2,sen2,dig2,stimestr,etimestr, lowpass);
            thand2=stahand2(length(stahand2)-8:length(stahand2));
            stahand2=stahand2(1:length(stahand2)-8);
            subplot(10,6,[ 1 2 3 4 5 7 8 9 10 11 13 14 15 16 17 19 20 21 22 23 ] )
            phand2=semilogx(per2,pspec2,'color','b');  
            hold on
            subplot(10,6,[ 43 44 45 46 47])
            plot(ttime2,tseries2,'color','b');
            datetick('x',15)
            xlabel('Time (HH:MM)','FontSize',14);
            ylabel('Volts');
            title(['Channel 2 Time Series ' thand2 ' ' ...
                num2str(roundn(1000*mabsvolt2,-2)) ' mV'],'FontSize',14);
            set(gca,'fontsize',14);    
        end   
        if(~isempty(datafile3))
            [pspec3, per3, stahand3, tseries3,ttime3, mabsvolt3 ...
                ] = noise(datafile3,sen3,dig3,stimestr,etimestr,lowpass);
            thand3=stahand3(length(stahand3)-8:length(stahand3));
            stahand3=stahand3(1:length(stahand3)-8);
            subplot(10,6,[ 1 2 3 4 5 7 8 9 10 11 13 14 15 16 17 19 ...
                20 21 22 23 ] )
            phand3=semilogx(per3,pspec3,'color','g');  
            hold on
            subplot(10,6,[ 55 56 57 58 59])
            plot(ttime3,tseries3,'color','g');
            datetick('x',15)
            xlabel('Time (HH:MM)','FontSize',14);
            ylabel('Volts');
            title(['Channel 3 Time Series ' thand3 ' ' ...
                num2str(roundn(1000*mabsvolt3,-2)) ' mV'],'FontSize',14);
            set(gca,'fontsize',14);  
        end  
        subplot(10,6,[ 1 2 3 4 5 7 8 9 10 11 13 14 15 16 17 19 ...
            20 21 22 23 ] );
        hold on
        p1=semilogx(nlnm(:,1),nlnm(:,4),'color','k','LineWidth',3);
        semilogx(nhnm(:,1),nhnm(:,2),'color','k','LineWidth',3);
        set(gca,'FontSize',14);
        title('Noise Estimate','FontSize',14);
        xlabel('Period (s)','FontSize',14);
        ylabel('Power (dB)','FontSize',14);
        xlim([.01 1000]);
        ylim([-200 -80]);
        if(length([phand1 phand2 phand3]) == 3);
            legend([phand1 phand2 phand3 p1],stahand1,stahand2, ...
                stahand3,'NLNM','Location','NorthWest');
        elseif(length([phand1 phand2]) == 2);
            legend([phand1 phand2 p1],stahand1,stahand2,'NLNM', ...
                'Location','NorthWest');
        elseif(length([phand1 phand3]) == 2);
            legend([phand1 phand3 p1],stahand1,stahand3,'NLNM', ...
                'Location','NorthWest');
        elseif(length([phand2 phand3]) == 2);
            legend([phand2 phand3 p1],stahand2,stahand3,'NLNM', ...
                'Location','NorthWest');
        elseif(length(phand1)==1);
            legend([phand1 p1],stahand1,'NLNM','Location','NorthWest');
        elseif(length(phand2)==1);
            legend([phand2 p1],stahand2,'NLNM','Location','NorthWest');
        elseif(length(phand3)==1)
            legend([phand3 p1],stahand3,'NLNM','Location','NorthWest');
        else
            legend(p1,'NLNM','Location','NorthWest');
        end
            
        
        hold off
        subplot(10,6,[ 43 44 45 46 47])
        
        
    end

    function clearme_Callback(~,~)
        subplot(10,6,[ 1 2 3 4 5 7 8 9 10 11 13 14 15 16 17 19 20 21 ...
            22 23 ] )
        p1=semilogx(nlnm(:,1),nlnm(:,4),'color','k','LineWidth',3);
        hold on
        semilogx(nhnm(:,1),nhnm(:,2),'color','k','LineWidth',3);
        set(gca,'FontSize',14);
        xlim([.01 1000]);
        ylim([-200 -80]);
        legend(p1,'NLNM','FontSize',14,'Location','NorthWest');
        hold off
        title('Noise Estimate','FontSize',14);
        xlabel('Period (s)','FontSize',14);
        ylabel('Power (dB)','FontSize',14);
        subplot(10,6,[ 31 32 33 34 35])
        plot(-1,-1)
        xlim([0 1000]);
        xlabel('Time (HH:MM)','FontSize',14);
        title('Channel 1 Time Series','FontSize',14);
        set(gca,'fontsize',14);
        ylabel('Volts');
        subplot(10,6,[ 43 44 45 46 47])
        plot(-1,-1)
        xlim([0 1000]);
        xlabel('Time (HH:MM)','FontSize',14);
        title('Channel 2 Time Series','FontSize',14);
        set(gca,'fontsize',14);
        ylabel('Volts');
        subplot(10,6,[ 55 56 57 58 59])
        plot(-1,-1)
        xlim([0 1000]);
        set(gca,'fontsize',14);
        xlabel('Time (HH:MM)','FontSize',14);
        ylabel('Volts');
        title('Channel 3 Time Series','FontSize',14);
        datafile1=[];
        datafile2=[];
        datafile3=[];
        stahand2='';
        stahand3='';
        
        
    end
    function saveme_Callback(~,~)
        orient LandScape
        printstr=regexprep([stahand1 stahand2 stahand3],' ','');
        if(~isempty(printstr))
            print('-dpdf',[printstr '.pdf']);
        end
    end
    
    function starttime_Callback(source,~) 
        str = get(source, 'String');
        stimestr=str;
    end
        
    function endtime_Callback(source,~) 
        str = get(source, 'String');
        etimestr=str;
    end    
    
    function lowpass_Callback(~,~) 
        if(lowpass == 0)
            lowpass=1;
        else
            lowpass=0;
        end
    end    

 
end 