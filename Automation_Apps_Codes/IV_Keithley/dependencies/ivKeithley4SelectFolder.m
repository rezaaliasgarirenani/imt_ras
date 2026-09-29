function ivKeithley4SelectFolder(app)
%IVKEITHLEY4SELECTFOLDER External implementation of SelectFolderButtonPushed.
% Extracted from IV_Keithley_4.mlapp without changing the original logic.

prevFolder = app.DefaultFolderEditField.Value;
selected = uigetdir(prevFolder, 'Select Folder');
if selected ~= 0
    setpref('MyApp','DataFolder', selected);
    app.DefaultFolderEditField.Value = selected;
end
figure(app.UIFigure)
end
