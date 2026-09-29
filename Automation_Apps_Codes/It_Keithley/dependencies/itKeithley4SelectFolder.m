function itKeithley4SelectFolder(app)
%ITKEITHLEY4SELECTFOLDER External implementation of SelectFolderButtonPushed.

prevFolder = app.DefaultFolderEditField.Value;
selected = uigetdir(prevFolder, 'Select Folder');
if selected ~= 0
    setpref('MyApp','DataFolder', selected);
    app.DefaultFolderEditField.Value = selected;
end
figure(app.UIFigure)
end
