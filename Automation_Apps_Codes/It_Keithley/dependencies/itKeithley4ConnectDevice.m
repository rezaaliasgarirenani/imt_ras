function itKeithley4ConnectDevice(app)
%ITKEITHLEY4CONNECTDEVICE External implementation of connectDeviceKeithley.

    if strcmp(app.connectionStatusKeithley,'Connected')
        delete(app.KLYSM2450)
        app.connectionStatusKeithley='Not Connected';
    end
    try
        app.KLYSM2450=visadev("USB0::0x05E6::0x2450::04429200::0::INSTR");
        app.KEITHLEYSourceMeter2450Lamp.Color='g';
        app.connectionStatusKeithley='Connected';
    catch
        app.KEITHLEYSourceMeter2450Lamp.Color='r';
        app.StateoftheExperimentTextArea.Value=('The Phase: The Connection to the device has failed!');
        app.connectionStatusKeithley='Not Connected';
    end
end
