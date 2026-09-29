function ivKeithley4StartExperiment(app)
%IVKEITHLEY4STARTEXPERIMENT Start-button logic for IV_Keithley_4.
% Keep this file on the MATLAB path alongside IV_Keithley_4.mlapp.
% The original callback body is preserved; edit experiment logic here.

    %% Initialization:
    app.defaultFolder = app.DefaultFolderEditField.Value;
    format longE
    app.connectDeviceKeithley();
    if ~strcmp(app.connectionStatusKeithley,'Connected')
        uialert(app.UIFigure,'Cannot start the experiment because the device is not connected','Connection Error')
        clear IV_Keithley_1;
        return;
    end
    app.stopExperiment = false;
    app.IndicatorLamp.Color='y'; % Yellow means experiment has started
    app.StateoftheExperimentTextArea.Value=('Experiment has started, resetting and initializing parameters');
    app.StartExperimentButton.Enable="off";

    cla(app.IV_Plot_Linear)
    cla(app.IV_Plot_Logarithmic)
    app.MeasurementTable.Data=[];
    app.ConstantValuesTabel.Data=[];
    
    app.i = 1;
    app.voltage_source=zeros(app.i,1);
    app.current_measure =zeros(app.i,1);

    app.StartVoltage=app.StartVoltageEditField.Value;
    app.StopVoltage=app.StopVoltageEditField.Value;
    app.Voltagerange=app.VoltageRangeListBox.Value;
    app.Currentlimit=app.CurrentLimitEditField.Value;
    app.Dualsweep=app.DualSweepSwitch.Value;
    app.Currentrange=app.CurrentRangeListBox.Value;
    app.Minimumrange=app.MinimumRangeListBox.Value;
    app.Autozero=app.AutoZeroSwitch.Value;
    app.Inputterminals=app.InputTerminalsListBox.Value;
    app.Outputoff=app.OutputOffListBox.Value;
    app.Sense=app.SenseListBox.Value;
 
    app.Sweeppoints=app.SourceSweepPointsEditField.Value;
    app.CurrentRange=app.CurrentRangeListBox.Value;
    app.Repeat=app.RepeatEditField.Value;
    app.SourcetoMeasureDelay=app.SourcetoMeasureDelaySEditField.Value;
    app.NPLC=app.NPLCEditField.Value;

    app.Measurecount=app.MeasurecountEditField.Value;
    app.aftervoltage=app.VoltageaftermeasureSwitch.Value;
    app.updateInterval=app.UpdateIntervalEditField.Value;
    
    app.SampleInfo=app.SampleInfoEditField.Value;
    app.Comments=app.CommentsEditField.Value;
    
    %% Parameters:
    
    if exist('data.xlsx','file')==2
        delete('data.xlsx')
    end
    app.data='data.xlsx';
    app.sheet1 ='Settings';
    app.sheet2 ='Measurements';

    app.currentDateTime=datetime('now');
    app.hourvalue=num2str(hour(app.currentDateTime));
    app.minutevalue=num2str(minute(app.currentDateTime));
    app.secondvalue=num2str(fix(second(app.currentDateTime)));
    app.yearvalue=num2str(year(app.currentDateTime));
    app.monthvalue=num2str(month(app.currentDateTime));
    app.dayvalue=num2str(day(app.currentDateTime));
    app.Combineddate=strcat(app.dayvalue,'.',app.monthvalue,'.',app.yearvalue);
    app.dateString=strcat(app.Combineddate);
    app.Combinedtime=strcat(app.hourvalue,':',app.minutevalue,':',app.secondvalue);
    app.timeString=strcat(app.Combinedtime);

    app.freq=str2double(writeread(app.KLYSM2450,'print(frequency)'));
    pause(0.1)
    app.measurement_window=app.NPLC/app.freq;
    if strcmp(app.Dualsweep,'On')
    app.Calculatedpoints = (app.Repeat+1) * ((2 * app.Sweeppoints) - (1));
    else
    app.Calculatedpoints = app.Sweeppoints * (app.Repeat+1);
    end
    app.Step = (app.StopVoltage - app.StartVoltage) / (app.Sweeppoints-1);
    app.consttableData=[app.freq, app.NPLC];
    app.ConstantValuesTabel.ColumnFormat={'numeric'};
    app.ConstantValuesTabel.Data=app.consttableData;
    app.StepTextArea.Value=num2str(app.Step);
    app.SweepPointsTextArea.Value=num2str(app.Sweeppoints);
    app.CalculatedPointsTextArea.Value=num2str(app.Calculatedpoints);
    app.DelaySTextArea.Value=num2str(app.SourcetoMeasureDelay);
    app.MeasureWindowSTextArea.Value=num2str(app.measurement_window);
    app.MeasureCountTextArea.Value=num2str(app.Measurecount);
    app.additionalComments = [];

    %% Device Settings:
    writeline(app.KLYSM2450,'*RST')
    pause(0.1)
    %Voltage is the SOURCE function, Current is measurement:
    writeline(app.KLYSM2450,'smu.measure.func = smu.FUNC_DC_CURRENT')
    writeline(app.KLYSM2450,'smu.source.func = smu.FUNC_DC_VOLTAGE')
    writeline(app.KLYSM2450,'frequency=localnode.linefreq')
    %Measure Settings for KEITHLEY:
    writeline(app.KLYSM2450,'smu.measure.terminals = smu.TERMINALS_REAR')
    writeline(app.KLYSM2450,'smu.measure.sense = smu.SENSE_2WIRE')
    writeline(app.KLYSM2450,'smu.measure.autorange = smu.ON')
    writeline(app.KLYSM2450, strcat('smu.measure.count = ',string(app.Measurecount)))
    writeline(app.KLYSM2450, strcat('smu.measure.nplc = ', string(app.NPLC)))
    % Source Settings for KEITHLEY:
    writeline(app.KLYSM2450,'smu.source.highc = smu.OFF')
    writeline(app.KLYSM2450,'smu.source.autorange = smu.ON')
    writeline(app.KLYSM2450,'smu.source.readback = smu.ON')
    writeline(app.KLYSM2450,'smu.source.output = smu.ON')
    writeline(app.KLYSM2450,'smu.source.offmode = smu.OFFMODE_NORMAL')
    writeline(app.KLYSM2450, strcat('smu.source.ilimit.level = ', string(app.Currentlimit)))

    %% Measurements
    writeline(app.KLYSM2450,'beeper.beep(0.35, 1500); delay(0.35) ; beeper.beep(0.35, 1500)')
    app.StateoftheExperimentTextArea.Value=('Measurements have started');
    app.IndicatorLamp.Color='r';
    writeline(app.KLYSM2450,'Voltage_Current_Buffer = buffer.make(1000),buffer.STYLE_WRITABLE_FULL')
    writeline(app.KLYSM2450,'Voltage_Current_Buffer.clear()')

    %--- Repeat Sweep ---
    for r = 1:app.Repeat+1
        %--- Forward Sweep: start -> stop ---
        voltage = app.StartVoltage;
        for k = 1:app.Sweeppoints
            if app.stopExperiment
                break;
            end
            % Set the source voltage for the current step and read  
            writeline(app.KLYSM2450, strcat('smu.source.level = ',string(voltage)))
            pause(app.SourcetoMeasureDelay);
            writeline(app.KLYSM2450, 'Voltage_Current_Buffer.clear()')
            writeline(app.KLYSM2450,'smu.measure.read(Voltage_Current_Buffer)')
            app.voltage_source (app.i,1)=mean(str2double(split(writeread(app.KLYSM2450,'printbuffer(1,Voltage_Current_Buffer.n,Voltage_Current_Buffer.sourcevalues)'),', ')));
            app.current_measure(app.i,1)=mean(str2double(split(writeread(app.KLYSM2450,'printbuffer(1,Voltage_Current_Buffer.n,Voltage_Current_Buffer.readings)'),', ')));       
           
            if mod(k, app.updateInterval) == 0 || k == app.Sweeppoints
                app.StateoftheExperimentTextArea.Value = sprintf('Measurement point number: %d', app.i);
                app.VoltageTextArea.Value = num2str(app.voltage_source(app.i,1));
                app.CurrentTextArea.Value = num2str(app.current_measure(app.i,1));
                plot(app.IV_Plot_Linear, app.voltage_source(1:app.i), app.current_measure(1:app.i));
                semilogy(app.IV_Plot_Logarithmic, app.voltage_source(1:app.i), abs(app.current_measure(1:app.i)));
                drawnow;
            end

            voltage = voltage + app.Step;
            app.i = app.i + 1;
        end
        
        %--- Reverse Sweep (if dualSweep is enabled): stop -> start ---
        if strcmp(app.Dualsweep,'On')
            voltage = app.StopVoltage - app.Step;
            for k = 1:app.Sweeppoints - 1
            if app.stopExperiment
                break;
            end
            % Set the source voltage for the current step and read  
            writeline(app.KLYSM2450, strcat('smu.source.level = ',string(voltage)))
            pause(app.SourcetoMeasureDelay);
            writeline(app.KLYSM2450, 'Voltage_Current_Buffer.clear()')
            writeline(app.KLYSM2450,'smu.measure.read(Voltage_Current_Buffer)')
            app.voltage_source (app.i,1)=mean(str2double(split(writeread(app.KLYSM2450,'printbuffer(1,Voltage_Current_Buffer.n,Voltage_Current_Buffer.sourcevalues)'),', ')));
            app.current_measure(app.i,1)=mean(str2double(split(writeread(app.KLYSM2450,'printbuffer(1,Voltage_Current_Buffer.n,Voltage_Current_Buffer.readings)'),', ')));       

            if mod(k, app.updateInterval) == 0 || k == app.Sweeppoints
                app.StateoftheExperimentTextArea.Value = sprintf('Measurement point number: %d', app.i);
                app.VoltageTextArea.Value = num2str(app.voltage_source(app.i,1));
                app.CurrentTextArea.Value = num2str(app.current_measure(app.i,1));
                plot(app.IV_Plot_Linear, app.voltage_source(1:app.i), app.current_measure(1:app.i));
                semilogy(app.IV_Plot_Logarithmic, app.voltage_source(1:app.i), abs(app.current_measure(1:app.i)));
                drawnow;
            end

            voltage = voltage - app.Step;
            app.i = app.i + 1;

            end
        end
    if app.stopExperiment
        break;
    end
    end

    MeasurementtableData = [(1:app.i-1)', app.voltage_source(1:app.i-1), app.current_measure(1:app.i-1)];
    app.MeasurementTable.ColumnFormat = {'numeric', 'numeric', 'numeric'};
    app.MeasurementTable.Data = MeasurementtableData;

    prompt={'Enter additional comments:'};
    dlgtitle='Additional Comments';
    dims=[1 50];
    definput={'No additional comments'};
    app.additionalCommentsCell=inputdlg(prompt,dlgtitle,dims,definput);
    if isempty (app.additionalCommentsCell)
        app.additionalComments='No Comments Provided';
    else
        app.additionalComments=app.additionalCommentsCell{1};
    end

    app.settings = {
    'Time', '' ;
    'Date', app.dateString ;
    'Clock', app.timeString ;
    '', '' ;
    'Sample Info', app.SampleInfo ;
    'Comments', app.Comments ;
    'Additional Comments', app.additionalComments ;
    '', '' ;
    'Measurement Parameters', '' ;
    'Start Voltage, V', app.StartVoltage ;
    'Stop Voltage, V', app.StopVoltage ;
    'Current Limit, A', app.Currentlimit ;
    'Step, V', app.Step ;
    '', '' ;
    'Dual Sweep', app.Dualsweep ;
    'Repeat', app.Repeat ;
    'Sweep Points', app.Sweeppoints ;
    'Calculated Points', app.Calculatedpoints ;
    '', '' ;
    'Source to Measure Delay, S', app.SourcetoMeasureDelay ;
    'NPLC', app.NPLC ;
    'Measure Window, S', app.measurement_window ;
    'Measurecount', app.Measurecount ;
    'Frequency, Hz', app.freq ;
    '', '' ;
    'Input Terminals', app.Inputterminals ;
    'Output Off', app.Outputoff ;
    'Sense', app.Sense ;
    '', '' ;
    'Voltage Range', app.Voltagerange ;
    'Current Range', app.CurrentRange ;
    'Minimum Range', app.Minimumrange ;
    'Auto Zero', app.Autozero ;
    };

    [filename, pathname] = uiputfile('.xlsx', 'Save as',app.defaultFolder);
    if isequal(filename,0) || isequal(pathname,0)
        app.StateoftheExperimentTextArea.Value=('The Experiment is done, the Data is not saved!');
        figure(app.UIFigure)
    else
        app.StateoftheExperimentTextArea.Value=('The Experiment is done, the Data is saved!');
        app.measurement_var_names = {'Voltage', 'Current'};
        app.measurement_table = table(app.voltage_source, app.current_measure ,'VariableNames', app.measurement_var_names);
        writecell(app.settings, fullfile(pathname, filename), 'Sheet', app.sheet1);
        writetable(app.measurement_table, fullfile(pathname, filename), 'Sheet', app.sheet2);   
        figure(app.UIFigure)
    end

    app.StartExperimentButton.Enable="on";
    
    %% Finishing the Experiment
    writeline(app.KLYSM2450,'smu.source.output = smu.OFF') %Put output off in KEITHLEY
    if strcmp(app.aftervoltage,'Off')
        writeline(app.KLYSM2450, 'smu.source.level = 0')
    end

    pause(1);
    app.StateoftheExperimentTextArea.Value=('The Experiment is done!');
    app.IndicatorLamp.Color='w';
    app.KEITHLEYSourceMeter2450Lamp.Color='w';
    app.StartExperimentButton.Enable="on";
    clc
    clearvars -global
    clear IV_Keithley_1
end
