# I-t Keithley version 4 setup

```text
It_Keithley/
    It_Keithley_4.mlapp
    dependencies/    # seven external callbacks and two option helpers
    legacy/          # versions 1-3, unchanged
    resources/       # spreadsheet, image, and these instructions
```

The `_4.mlapp` file is a byte-for-byte copy of the original `_3.mlapp` under
a new filename. Its internal class is still `It_Keithley_3`. It has not yet been
saved or connected to the external functions using MATLAB.

## One-time steps on the work PC

1. Synchronize this entire folder.
2. In App Designer, open `legacy/It_Keithley_3.mlapp`, then use **Save As** to save
   it as `It_Keithley_4.mlapp` in the parent `It_Keithley` folder. Overwrite the
   prepared copy. This lets MATLAB update the internal class and constructor
   consistently. Make all subsequent edits in `_4`, leaving `legacy/_3` alone.
3. In Code View, change the custom properties block above `SampleInfo` from
   `properties (Access = private)` to `properties (Access = public)`.
   The generated component properties are already public. Keep the connection
   method public, and keep the callbacks' `methods (Access = private)` unchanged.
4. Replace the entire body of each function below. Keep its existing declaration
   and matching closing `end`. Do not retain the old code under the replacement.

| Function | Replacement body |
| --- | --- |
| `connectDeviceKeithley(app)` | `itKeithley4ConnectDevice(app);` |
| `startupFcn(app)` | Use the two-line body below. |
| `StartExperimentButtonPushed(app, event)` | `itKeithley4StartExperiment(app);` |
| `StopExperimentButtonPushed(app, event)` | `itKeithley4StopExperiment(app);` |
| `UIFigureCloseRequest(app, event)` | `itKeithley4CloseRequest(app);` |
| `SaveDataButtonPushed(app, event)` | `itKeithley4SaveData(app);` |
| `SelectFolderButtonPushed(app, event)` | `itKeithley4SelectFolder(app);` |

```matlab
function startupFcn(app)
    addpath(fullfile(fileparts(mfilename('fullpath')), 'dependencies'));
    itKeithley4Startup(app);
end
```

Only startup needs `addpath`; it runs automatically at each app launch. Keep
the generated component creation, constructor, and destructor code unchanged.
Save `_4`, then synchronize the saved app back into this repository.

## Included changes

Startup adds the same controls as I-V beside Sample Info / Comments:

- **Add Comment prompt auto**: checked by default.
- **Save Data prompt auto**: checked by default.

The choices are independent and read after measurement, including after Stop.
Disabling a prompt skips that dialog. Disabling automatic Save Data keeps
results in memory for the existing manual Save Data button. Starting another
run or closing the app can discard unsaved results. The manual button retains
its original additional-comment and save dialogs.

Current Range offers Auto, 10 nA, 100 nA, 1 uA, 10 uA, 100 uA, 1 mA, 10 mA,
100 mA, and 1 A. Auto is the initial selection. A fixed selection disables
measurement autorange and sends `smu.measure.range` in amperes after reset and
function selection. The entered current limit is sent before the measurement
range, with output enabled afterward. Selecting a fixed range can make the
instrument adjust the current limit and issue a warning (TSP reference,
printed page 14-202). The 10 nA and 100 nA ranges require rear triax connections.

The command reference is `IV_Keithley/resources/TSP_Codes_2450.pdf`, printed
pages 14-123 and 14-159/160 (PDF pages 135 and 171/172). The same range mapping
and runtime UI implementation are used as in the working I-V version, with
I-t-specific function names and tags. I-t does not depend on the I-V folder
at runtime.

The time-measurement loop, original manual callbacks, and output shutdown order
are preserved. UI controls are added at runtime and do not appear on App
Designer's design canvas. No test or simulation code is included.

The files have been checked locally; MATLAB execution and instrument behavior
still require verification on the work PC after the replacements above.

## Device messages in State of experiment

The existing text area shows the latest experiment status followed by errors
and warnings read from the Keithley event log. Messages include severity,
code, original device text, and the stage where they were retrieved. Previously
queued messages are labelled separately. The displayed history resets at Start
and remains visible through progress updates, Stop, and Save Data.

Events are read during setup (including separately after the current limit,
current range, and output-on commands), after the measurement loop, and after
finishing commands. There are no event queries between measurement points;
messages generated during measurement appear after the loop finishes or stops.
Reading an event consumes its unread remote entry but leaves it in the device's
front-panel log. Messages are displayed in the app, not added to the saved XLSX.
The instrument's Log Warning setting must be on to record warnings (full 2450
reference manual, printed page 3-39); warnings disabled there cannot be retrieved.

The commands are documented in `TSP_Codes_2450.pdf` (in the I-V resources),
printed pages 14-80 to 14-82 and 14-107. Automatic event output is disabled on
the active connection so it cannot mix unsolicited messages into measurement
replies; events are explicitly requested instead. Device messages do not
change settings or stop a run. A communication failure while reading the log
is displayed in the text area and propagates as a MATLAB error.

Synchronize the entire dependencies folder, including the new Status helper,
and relaunch the app. No App Designer edits are needed. MATLAB R2022b and
hardware verification remain necessary on the work PC.
