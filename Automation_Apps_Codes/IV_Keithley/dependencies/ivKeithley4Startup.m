function ivKeithley4Startup(app)
%IVKEITHLEY4STARTUP External implementation of startupFcn.
% Extracted from IV_Keithley_4.mlapp without changing the original logic.

    figure(app.UIFigure)
    defaultFallback = fullfile(userpath,'MyAppData');
    app.DefaultFolderEditField.Value = getpref('MyApp','DataFolder', defaultFallback);
    figure(app.UIFigure)
end
