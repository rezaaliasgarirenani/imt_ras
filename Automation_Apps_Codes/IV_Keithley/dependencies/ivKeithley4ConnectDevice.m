function ivKeithley4ConnectDevice(app)
%IVKEITHLEY4CONNECTDEVICE External implementation of connectDeviceKeithley.
% Extracted from IV_Keithley_4.mlapp without changing the original logic.

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
        ivKeithley4Status(app, ('The Connection to the device has failed!'));
        app.connectionStatusKeithley='Not Connected';
    end
end
