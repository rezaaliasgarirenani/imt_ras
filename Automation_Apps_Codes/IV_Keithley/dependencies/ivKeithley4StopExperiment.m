function ivKeithley4StopExperiment(app)
%IVKEITHLEY4STOPEXPERIMENT External implementation of StopExperimentButtonPushed.
% Extracted from IV_Keithley_4.mlapp without changing the original logic.

    app.IndicatorLamp.Color='k';
    app.StartExperimentButton.Enable="on";
    app.KEITHLEYSourceMeter2450Lamp.Color='w';

    app.StateoftheExperimentTextArea.Value=('The Experiment has been stopped, Save the data!');
    writeline(app.KLYSM2450,'smu.source.output = smu.OFF') %Put outpot off in KEITHLEY
    if strcmp(app.aftervoltage,'Off')
        writeline(app.KLYSM2450, 'smu.source.level = 0')
    end
    app.stopExperiment = true;
end
