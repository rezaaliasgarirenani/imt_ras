function [commands, labels, rangeAmperes, limitBounds] = ivKeithley4CurrentRangeCommands(selection, currentLimit)
%IVKEITHLEY4CURRENTRANGECOMMANDS Compatible current range and source limit.
% TSP_Codes_2450.pdf: 14-123, 14-159/160, 14-201/202.
% Full 2450 Rev. E reference, 4-41: fixed-range maximum limit is 105%.
% 14-202: fixed-range minimum limit is 10.6%. All values are amperes.
% Apply after reset/function selection, with source output OFF.
    labels = {'Auto', '10 nA', '100 nA', '1 uA', '10 uA', '100 uA', ...
        '1 mA', '10 mA', '100 mA', '1 A'};
    amperes = [NaN, 1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1];
    index = find(strcmp(selection, labels), 1);
    if isempty(index)
        error('IVKeithley4:InvalidCurrentRange', ...
            'Choose Auto or a fixed range from the Current Range list.');
    end
    rangeAmperes = amperes(index);
    limitBounds = [1e-9, 1.05];
    if index > 1
        limitBounds = [max(1e-9, 0.106 * rangeAmperes), min(1.05, 1.05 * rangeAmperes)];
    end
    if nargin > 1
        if ~isnumeric(currentLimit) || ~isreal(currentLimit) || ...
                ~isscalar(currentLimit) || ~isfinite(currentLimit) || ...
                currentLimit < 1e-9 || currentLimit > 1.05
            error('IVKeithley4:InvalidCurrentLimit', ...
                'Current Limit must be between 1e-9 A and 1.05 A.');
        end
        if index > 1
            minimumLimit = limitBounds(1);
            maximumLimit = limitBounds(2);
            if currentLimit < minimumLimit || currentLimit > maximumLimit
                error('IVKeithley4:IncompatibleCurrentLimit', ...
                    ['For the %s range, Current Limit must be between %.12g A and %.12g A. ' ...
                     'Change Current Limit or select a compatible range. No settings were sent.'], ...
                    selection, minimumLimit, maximumLimit);
            end
        end
    end
    if index == 1
        commands = {'smu.measure.autorange = smu.ON'};
    else
        % Setting range itself disables autorange (manual 14-160). Avoid
        % freezing the previous range before the new range has been selected.
        commands = {sprintf('smu.measure.range = %.12g', amperes(index))};
    end
    if nargin > 1
        % Set compliance under autorange before fixing the measurement range.
        % This prevents the range change from clamping an incompatible old limit.
        setupCommands = {'smu.measure.autorange = smu.ON', ...
            sprintf('smu.source.ilimit.level = %.12g', currentLimit)};
        if index == 1
            commands = setupCommands;
        else
            commands = [setupCommands, commands];
        end
    end
end
