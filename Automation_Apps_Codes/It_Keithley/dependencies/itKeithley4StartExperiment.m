function itKeithley4StartExperiment(app)
%ITKEITHLEY4STARTEXPERIMENT External implementation of StartExperimentButtonPushed.

    %% Initialization:
    rangeCommands = itKeithley4CurrentRangeCommands(app.CurrentRangeListBox.Value);
    app.defaultFolder = app.DefaultFolderEditField.Value;
    format longE
    app.connectDeviceKeithley();
    if ~strcmp(app.connectionStatusKeithley,'Connected')
        uialert(app.UIFigure,'Cannot start the experiment because the device is not connected','Connection Error')
        clear IV_Keithley_1;
        return;
    end

    app.IndicatorLamp.Color='y'; % Yellow means experiment has started
    app.StateoftheExperimentTextArea.Value=('The Phase: Experiment has started, resetting and initializing parameters');
    app.StartExperimentButton.Enable="off";
    app.stopExperiment = false;

    cla(app.It_Plot_Linear)
    cla(app.It_Plot_Logarithmic)
    app.MeasurementTable.Data=[];
    app.ConstantValuesTabel.Data=[];

    app.i = 1;
    app.time=zeros(app.i,1);
    app.voltage_source=zeros(app.i,1);
    app.current_measure =zeros(app.i,1);

    app.LevelVoltage=app.LevelVoltageEditField.Value;
    app.Voltagerange=app.VoltageRangeListBox.Value;
    app.Currentlimit=app.CurrentLimitEditField.Value;

    app.Currentrange=app.CurrentRangeListBox.Value;
    app.Minimumrange=app.MinimumRangeListBox.Value;
    app.Autozero=app.AutoZeroSwitch.Value;
    app.Inputterminals=app.InputTerminalsListBox.Value;
    app.Outputoff=app.OutputOffListBox.Value;
    app.Sense=app.SenseListBox.Value;

    app.Sweeppoints=app.SourceSweepPointsEditField.Value;
    app.CurrentRange=app.CurrentRangeListBox.Value;
    app.SourcetoMeasureDelay=app.SourcetoMeasureDelaySEditField.Value;
    app.NPLC=app.NPLCEditField.Value;

    app.Measurecount=app.MeasurecountEditField.Value;
    app.aftervoltage=app.VoltageaftermeasureSwitch.Value;
    app.updateInterval=app.UpdateIntervalEditField.Value;

    app.SampleInfo=app.SampleInfoEditField.Value;
    app.Comments=app.CommentsEditField.Value;

    %% Saving parameters
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
    app.measurement_window=app.NPLC/app.freq;
    app.consttableData=[app.freq, app.NPLC];
    app.ConstantValuesTabel.ColumnFormat={'numeric'};
    app.ConstantValuesTabel.Data=app.consttableData;
    app.VoltageVTextArea.Value=num2str(app.LevelVoltage);
    app.SweepPointsTextArea.Value=num2str(app.Sweeppoints);
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
    for rangeCommandIndex = 1:numel(rangeCommands)
        writeline(app.KLYSM2450, rangeCommands{rangeCommandIndex});
    end
    writeline(app.KLYSM2450, strcat('smu.measure.count = ',string(app.Measurecount)))
    writeline(app.KLYSM2450, strcat('smu.measure.nplc=', string(app.NPLC)))
    % Source Settings for KEITHLEY:
    writeline(app.KLYSM2450,'smu.source.highc = smu.OFF')
    writeline(app.KLYSM2450,'smu.source.autorange = smu.ON')
    writeline(app.KLYSM2450,'smu.source.readback = smu.ON')
    writeline(app.KLYSM2450,'smu.source.output = smu.ON')
    writeline(app.KLYSM2450,'smu.source.offmode = smu.OFFMODE_NORMAL')
    writeline(app.KLYSM2450, strcat('smu.source.ilimit.level = ', string(app.Currentlimit)))

    %% Measurements
    writeline(app.KLYSM2450,'beeper.beep(0.35, 1500); delay(0.35) ; beeper.beep(0.35, 1500)')
    app.StateoftheExperimentTextArea.Value=('The Phase: Measurements have started');
    app.IndicatorLamp.Color='r';
    writeline(app.KLYSM2450,'Voltage_Current_Buffer = buffer.make(1000),buffer.STYLE_WRITABLE_FULL')
    writeline(app.KLYSM2450,'Voltage_Current_Buffer.clear()')

    %--- Time Sweep: Start -> Stop ---
    voltage = app.LevelVoltage;
    writeline(app.KLYSM2450, strcat('smu.source.level = ',string(voltage)))
    timestart=tic;
    for k = 1:app.Sweeppoints
        if app.stopExperiment
            break;
        end
        % Set the source voltage for the current Sweep Points and read
        pause(app.SourcetoMeasureDelay);
        writeline(app.KLYSM2450, 'Voltage_Current_Buffer.clear()')
        writeline(app.KLYSM2450,'smu.measure.read(Voltage_Current_Buffer)')
        app.voltage_source (app.i,1)=mean(str2double(split(writeread(app.KLYSM2450,'printbuffer(1,Voltage_Current_Buffer.n,Voltage_Current_Buffer.sourcevalues)'),', ')));
        app.current_measure(app.i,1)=mean(str2double(split(writeread(app.KLYSM2450,'printbuffer(1,Voltage_Current_Buffer.n,Voltage_Current_Buffer.readings)'),', ')));
        app.time(app.i,1)=toc(timestart);

        if mod(k, app.updateInterval) == 0 || k == app.Sweeppoints
            app.StateoftheExperimentTextArea.Value = sprintf('Measurement point number: %d', app.i);
            app.TimeTextArea.Value=num2str(app.time(app.i,1));
            app.CurrentTextArea.Value=num2str(app.current_measure(app.i,1));
            plot(app.It_Plot_Linear,app.time,app.current_measure)
            semilogy(app.It_Plot_Logarithmic, app.time, abs(app.current_measure))
            drawnow;
        end

        app.i = app.i + 1;
    end

    MeasurementtableData=[(1:app.i-1)', app.time(1:app.i-1), app.current_measure(1:app.i-1), app.voltage_source(1:app.i-1)];
    app.MeasurementTable.ColumnFormat = {'numeric', 'numeric', 'numeric'};
    app.MeasurementTable.Data = MeasurementtableData;

    [askComment, askSave] = itKeithley4PromptOptions(app);
    app.additionalComments = 'No Comments Provided';
    app.additionalCommentsCell = {};
    if askComment
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
    'Level Voltage, V', app.LevelVoltage ;
    'Current Limit, A', app.Currentlimit ;
    'Sweep Points', app.Sweeppoints ;
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
    if askSave
        [filename, pathname] = uiputfile('.xlsx', 'Save as',app.defaultFolder);
        if isequal(filename,0) || isequal(pathname,0)
            app.StateoftheExperimentTextArea.Value=('The Phase: The Experiment is done, the Data is not saved!');
            figure(app.UIFigure)
        else
            app.StateoftheExperimentTextArea.Value=('The Phase: The Experiment is done, the Data is saved!');
            app.measurement_var_names = {'Time', 'Current', 'Voltage'};
            app.measurement_table = table(app.time, app.current_measure, app.voltage_source,'VariableNames', app.measurement_var_names);
            writecell(app.settings, fullfile(pathname, filename), 'Sheet', app.sheet1);
            writetable(app.measurement_table, fullfile(pathname, filename), 'Sheet', app.sheet2);
            figure(app.UIFigure)
        end
    end

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
