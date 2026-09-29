# Editing the IV_Keithley_4 Start button outside App Designer

`ivKeithley4StartExperiment.m` contains the existing Start button logic extracted
from `IV_Keithley_4.mlapp`. The extraction preserves the callback body; it does
not change instrument commands, settings, timing, plotting, or saving behavior.
The `.mlapp` has not been modified or connected to this file yet.

## One-time setup on the MATLAB R2022b work PC

1. Synchronize this folder, including `ivKeithley4StartExperiment.m`, to the work PC.
2. Open `IV_Keithley_4.mlapp` in App Designer and select Code View.
3. Find `StartExperimentButtonPushed`. Replace its entire editable body (from
   `%% Initialization:` through the final `clear IV_Keithley_1`) with:

   ```matlab
   ivKeithley4StartExperiment(app);
   ```

   Keep the generated function declaration and its matching closing `end`.
   The complete callback should look like:

   ```matlab
   function StartExperimentButtonPushed(app, event)
       ivKeithley4StartExperiment(app);
   end
   ```

4. Keep the existing app properties and `connectDeviceKeithley` public. Leave
   the callback methods block private. Keep all other callbacks unchanged.
5. Save the app and synchronize the saved `.mlapp` back to this repository.

## Check the setup before a measurement

In MATLAB, make this `IV_Keithley` folder the Current Folder. Run:

```matlab
which ivKeithley4StartExperiment -all
checkcode('ivKeithley4StartExperiment.m')
```

`which` should resolve to the file in this folder. Review Code Analyzer results;
the extraction retains the original code and any existing warnings.
These commands do not run the experiment or connect to the instrument.

To verify the callback connection, set a breakpoint on the first executable line
of `ivKeithley4StartExperiment.m`, run the app, then click Start. MATLAB should
pause at that line before the instrument connection. Stop debugging there for
a routing-only check; continuing executes the real experiment.

## Subsequent edits

Edit `ivKeithley4StartExperiment.m`, synchronize it to the work PC, and close and
relaunch the running app between versions. The wrapper in App Designer stays the
same. Keep the folder on MATLAB's search path or use it as the Current Folder.
Distribute this `.m` file with `_4.mlapp`; the app will depend on it after setup.

Stop, Save Data, startup, folder selection, and connection logic still reside in
the `.mlapp`. This first extraction moves only the Start callback.

## Verification limits

Local checks compared the extracted body with the original and checked that its
referenced app members are public. MATLAB R2022b and instrument execution have
not been tested on this computer. Existing experiment behavior, including error
handling and output shutdown order, is preserved rather than corrected here.
