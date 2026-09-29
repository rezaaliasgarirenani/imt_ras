function ivKeithley4CloseRequest(app)
%IVKEITHLEY4CLOSEREQUEST External implementation of UIFigureCloseRequest.
% Extracted from IV_Keithley_4.mlapp without changing the original logic.

    selection=uiconfirm(app.UIFigure,'Are you sure you want to close the app?', 'Close Request', 'Options',{'Yes','No'},'DefaultOption',2,'CancelOption',2);
    switch selection
        case 'Yes'
            delete(app.UIFigure)
        case 'No'
            return;
    end
end
