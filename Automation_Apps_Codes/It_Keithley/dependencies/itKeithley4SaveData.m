function itKeithley4SaveData(app)
%ITKEITHLEY4SAVEDATA External implementation of SaveDataButtonPushed.

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
