function ivKeithley4SaveData(app)
%IVKEITHLEY4SAVEDATA External implementation of SaveDataButtonPushed.
% Extracted from IV_Keithley_4.mlapp without changing the original logic.

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
        ivKeithley4Status(app, ('The Experiment is done, the Data is not saved!'));
        figure(app.UIFigure)
    else
        ivKeithley4Status(app, ('The Experiment is done, the Data is saved!'));
        app.measurement_var_names = {'Voltage', 'Current'};
        app.measurement_table = table(app.voltage_source, app.current_measure ,'VariableNames', app.measurement_var_names);
        writecell(app.settings, fullfile(pathname, filename), 'Sheet', app.sheet1);
        writetable(app.measurement_table, fullfile(pathname, filename), 'Sheet', app.sheet2);   
        figure(app.UIFigure)
    end
end
