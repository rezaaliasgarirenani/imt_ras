function [askComment, askSave] = ivKeithley4PromptOptions(app)
%IVKEITHLEY4PROMPTOPTIONS Read the independent end-of-measurement choices.
    comment = findall(app.UIFigure, 'Tag', 'IVKeithley4AutoComment');
    save = findall(app.UIFigure, 'Tag', 'IVKeithley4AutoSave');
    if numel(comment) ~= 1 || numel(save) ~= 1
        error('IVKeithley4:MissingPromptControls', ...
            'Close and reopen IV_Keithley_4 to initialize the prompt controls.');
    end
    askComment = logical(comment.Value);
    askSave = logical(save.Value);
end
