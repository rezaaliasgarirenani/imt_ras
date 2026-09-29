function [askComment, askSave] = itKeithley4PromptOptions(app)
%ITKEITHLEY4PROMPTOPTIONS Read the independent end-of-measurement choices.
    comment = findall(app.UIFigure, 'Tag', 'ItKeithley4AutoComment');
    save = findall(app.UIFigure, 'Tag', 'ItKeithley4AutoSave');
    if numel(comment) ~= 1 || numel(save) ~= 1
        error('ItKeithley4:MissingPromptControls', ...
            'Close and reopen It_Keithley_4 to initialize the prompt controls.');
    end
    askComment = logical(comment.Value);
    askSave = logical(save.Value);
end
