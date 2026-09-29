function itKeithley4StopExperiment(app)
%ITKEITHLEY4STOPEXPERIMENT External implementation of StopExperimentButtonPushed.

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
