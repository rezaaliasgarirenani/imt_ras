function itKeithley4Status(app, message, eventStage)
% Keep the latest status above device errors/warnings in the existing text area.
% TSP reference: eventlog.getcount/next, 14-80 to 14-82; showevents, 14-107.
    area = app.StateoftheExperimentTextArea;
    events = getappdata(area, 'KeithleyEvents');
    if isempty(events)
        events = cell(0, 1);
    end
    if isempty(message)
        currentText = cellstr(area.Value);
        message = currentText{1};
    end
    area.Value = [{char(message)}; events];

    if nargin == 3
        try
            count = str2double(writeread(app.KLYSM2450, 'print(eventlog.getcount(3))'));
            if ~isfinite(count) || count < 0 || count ~= fix(count)
                error('Keithley4:EventLogResponse', 'Invalid event-log count returned by Keithley.');
            end
            for k = 1:count
                response = writeread(app.KLYSM2450, ...
                    ['local code, message, severity = eventlog.next(3); ' ...
                     'print(string.format("%s %d: %s", severity == 1 and "Error" or "Warning", code, message))']);
                events{end+1, 1} = sprintf('[%s] %s', eventStage, strtrim(response));
                setappdata(area, 'KeithleyEvents', events);
                area.Value = [{char(message)}; events];
            end
        catch logError
            events{end+1, 1} = ['Cannot read Keithley event log: ' logError.message];
            setappdata(area, 'KeithleyEvents', events);
            area.Value = [{char(message)}; events];
            rethrow(logError);
        end
        drawnow limitrate nocallbacks
    end
end
