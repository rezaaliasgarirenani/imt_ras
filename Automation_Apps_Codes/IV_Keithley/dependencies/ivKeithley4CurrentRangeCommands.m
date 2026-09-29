function [commands, labels] = ivKeithley4CurrentRangeCommands(selection)
%IVKEITHLEY4CURRENTRANGECOMMANDS Current measurement range, not source limit.
% TSP_Codes_2450.pdf: 14-123 and 14-159/160 (PDF pages 135, 171/172).
% Values are amperes. Set after reset and selecting DC current measurement.
    labels = {'Auto', '10 nA', '100 nA', '1 uA', '10 uA', '100 uA', ...
        '1 mA', '10 mA', '100 mA', '1 A'};
    amperes = [NaN, 1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1];
    index = find(strcmp(selection, labels), 1);
    if isempty(index)
        error('IVKeithley4:InvalidCurrentRange', ...
            'Choose Auto or a fixed range from the Current Range list.');
    end
    if index == 1
        commands = {'smu.measure.autorange = smu.ON'};
    else
        commands = {'smu.measure.autorange = smu.OFF', ...
            sprintf('smu.measure.range = %.12g', amperes(index))};
    end
end
