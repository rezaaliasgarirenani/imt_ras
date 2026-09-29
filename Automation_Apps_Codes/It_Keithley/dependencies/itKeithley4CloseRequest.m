function itKeithley4CloseRequest(app)
%ITKEITHLEY4CLOSEREQUEST External implementation of UIFigureCloseRequest.

    selection=uiconfirm(app.UIFigure,'Are you sure you want to close the app?', 'Close Request', 'Options',{'Yes','No'},'DefaultOption',2,'CancelOption',2);
    switch selection
        case 'Yes'
            delete(app.UIFigure)
        case 'No'
            return;
    end
end
