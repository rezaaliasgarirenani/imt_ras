function ivKeithley4Startup(app)
%IVKEITHLEY4STARTUP External implementation of startupFcn.
% Add runtime controls without modifying the App Designer binary model.

    figure(app.UIFigure)
    defaultFallback = fullfile(userpath,'MyAppData');
    app.DefaultFolderEditField.Value = getpref('MyApp','DataFolder', defaultFallback);

    % Blank space immediately left of the Sample Info / Comments row.
    % Tags allow external callbacks to find controls without new app properties.
    if isempty(findall(app.UIFigure, 'Tag', 'IVKeithley4AutoComment'))
        uicheckbox(app.SettingsTab, ...
            'Text', 'Add Comment prompt auto', 'Value', true, ...
            'Position', [20 157 235 24], 'FontSize', 14, ...
            'Tag', 'IVKeithley4AutoComment', ...
            'Tooltip', 'Ask for additional comments after measurement.');
    end
    if isempty(findall(app.UIFigure, 'Tag', 'IVKeithley4AutoSave'))
        uicheckbox(app.SettingsTab, ...
            'Text', 'Save Data prompt auto', 'Value', true, ...
            'Position', [20 121 235 24], 'FontSize', 14, ...
            'Tag', 'IVKeithley4AutoSave', ...
            'Tooltip', 'Open Save Data after measurement. Uncheck to save manually later.');
    end

    selectedRange = app.CurrentRangeListBox.Value;
    [~, ranges] = ivKeithley4CurrentRangeCommands('Auto');
    app.CurrentRangeListBox.Items = ranges;
    if any(strcmp(selectedRange, ranges))
        app.CurrentRangeListBox.Value = selectedRange;
    else
        app.CurrentRangeListBox.Value = 'Auto';
    end
    app.CurrentRangeListBox.Tooltip = ...
        ['Fixed current range requires a compatible Current Limit (10.6% to 105% of range). ' ...
         '10 nA and 100 nA require rear triax connections.'];
    if isempty(findall(app.UIFigure, 'Tag', 'IVKeithley4CurrentLimitNote'))
        uilabel(app.MeasurementParametersPanel, ...
            'Position', [20 282 665 24], 'FontSize', 12, ...
            'BackgroundColor', [0.96 0.96 0.96], ...
            'Tag', 'IVKeithley4CurrentLimitNote', ...
            'Tooltip', ['Range-based limits from the Keithley manual. Enter Current Limit in amperes. ' ...
                'Other instrument operating limits may also apply.']);
    end
    app.CurrentRangeListBox.ValueChangedFcn = @(~, ~) updateCurrentLimitNote(app);
    updateCurrentLimitNote(app);
    figure(app.UIFigure)
end

function updateCurrentLimitNote(app)
    selection = app.CurrentRangeListBox.Value;
    [~, ~, ~, bounds] = ivKeithley4CurrentRangeCommands(selection);
    note = findall(app.UIFigure, 'Tag', 'IVKeithley4CurrentLimitNote');
    note.Text = sprintf('Current Limit for %s range: %.4g to %.4g A.', ...
        selection, bounds(1), bounds(2));
end
