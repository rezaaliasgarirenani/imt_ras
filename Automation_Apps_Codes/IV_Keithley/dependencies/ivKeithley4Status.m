function ivKeithley4Status(app, message, eventStage)
% Keep experiment status on tab 3 and device messages on the Settings tab.
% TSP reference: eventlog.clear/getcount/next, 14-79 to 14-82; showevents, 14-107.
    if nargin < 3
        app.StateoftheExperimentTextArea.Value = message;
        return;
    end

    area = findall(app.UIFigure, 'Tag', 'IVKeithley4DeviceMessages');
    if strcmp(eventStage, 'clear')
        % Clear historical entries once, before this run's setup commands.
        writeline(app.KLYSM2450, 'eventlog.clear()');
        setappdata(area, 'KeithleyEvents', cell(0, 1));
        area.Value = {'No device messages collected for this run.'};
        return;
    end
    events = getappdata(area, 'KeithleyEvents');
    if isempty(events)
        events = cell(0, 1);
    end

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
            area.Value = events;
        end
    catch logError
        events{end+1, 1} = ['Cannot read Keithley event log: ' logError.message];
        setappdata(area, 'KeithleyEvents', events);
        area.Value = events;
        rethrow(logError);
    end
    drawnow limitrate nocallbacks
end
