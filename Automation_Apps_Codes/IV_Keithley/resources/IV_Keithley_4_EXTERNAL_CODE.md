# Editing IV_Keithley_4 outside App Designer

All seven wrappers and the dependencies path setup are present in the current
`IV_Keithley_4.mlapp`. The user has tested the extraction on the work PC.
The wrapper instructions below are retained for reference; do not repeat them.

## Requested options (September 2026)

Synchronize the updated `dependencies` folder, close the running app, and run
`IV_Keithley_4` again. No additional App Designer edits are needed.

Startup creates two checkboxes to the left of the Sample Info / Comments row:

| Add Comment prompt auto | Save Data prompt auto | After measurement |
| --- | --- | --- |
| On | On | Ask for comments, then open Save Data (original behavior). |
| On | Off | Ask for comments; keep results in the app for manual saving. |
| Off | On | Open Save Data without asking for comments. |
| Off | Off | Show neither dialog; keep results in the app. |

Both start checked when the app is launched. Their values are read after the
measurement loop finishes, including runs ended with Stop. Skipping comments
uses `No Comments Provided`; it never reuses comments from a previous run.
These controls do not auto-save a file: they control whether dialogs appear.
The manual Save Data button retains its existing comment and save prompts.
Unsaved results remain in memory until overwritten by another run or closing.

Current Range now offers Auto, 10 nA, 100 nA, 1 uA, 10 uA, 100 uA, 1 mA,
10 mA, 100 mA, and 1 A. Auto remains the initial selection. The selection is
applied after instrument reset and DC-current measurement-function selection.
The entered current limit is sent before the measurement range, with output
enabled afterward. Selecting a fixed range can make the instrument adjust
the current limit and issue a warning (TSP reference, printed page 14-202).
The sweep loops, instrument connection, manual saving, and shutdown order are
unchanged. I-t uses the same setup order.

Runtime-created controls are visible in the running app, not in the saved
App Designer design canvas. Their tags identify them without new app properties.

### Command reference

The supplied `TSP_Codes_2450.pdf` documents `smu.measure.autorange` on printed
page 14-123 (PDF page 135) and `smu.measure.range` on printed pages 14-159/160
(PDF pages 171/172). Auto sends `smu.measure.autorange = smu.ON`; fixed selection
sends `smu.measure.range = value`, which itself disables measurement autorange,
where value is in amperes. Fixed ranges can overflow if measured current is too
large; the manual describes the returned value as `9.9e+37`.

The discrete ranges are confirmed in the
[2450 datasheet, Current Specifications](https://www.tek.com/en/datasheet/smu-2400-graphical-sourcemeter/model-2450-touchscreen-source-measure-unit-smu-instrument).
The 10 nA and 100 nA ranges require rear triax connections. The existing code
already requests rear terminals; terminal-selection behavior is not changed.

## One-time replacements

Synchronize the whole folder to the work PC. The layout is:

```text
IV_Keithley/
    IV_Keithley_4.mlapp
    dependencies/       # external callbacks and option helpers
    legacy/             # IV_Keithley_1.mlapp through IV_Keithley_3.mlapp
    resources/          # instructions, PDF, and reference image
```
In App Designer Code View, replace each listed function's entire editable body
with the indicated line. Keep its declaration and matching closing `end`.
Do not leave any of the old body below the new line.

| Existing function | Complete replacement body |
| --- | --- |
| `connectDeviceKeithley` | `ivKeithley4ConnectDevice(app);` |
| `startupFcn` | Use the two-line body below. |
| `StartExperimentButtonPushed` (already done) | `ivKeithley4StartExperiment(app);` |
| `StopExperimentButtonPushed` | `ivKeithley4StopExperiment(app);` |
| `UIFigureCloseRequest` | `ivKeithley4CloseRequest(app);` |
| `SaveDataButtonPushed` | `ivKeithley4SaveData(app);` |
| `SelectFolderButtonPushed` | `ivKeithley4SelectFolder(app);` |

Startup must add the dependencies folder before calling its external function:

```matlab
function startupFcn(app)
    addpath(fullfile(fileparts(mfilename('fullpath')), 'dependencies'));
    ivKeithley4Startup(app);
end
```

Put these lines inside the `.mlapp` startup callback, not inside the external
startup file. The path is derived from the app location, so it works on both
computers without a hard-coded drive letter. Do this before running the app
with the reorganized folders. No permanent `savepath` change is needed.

For example, the connection helper becomes:

```matlab
function connectDeviceKeithley(app)
    ivKeithley4ConnectDevice(app);
end
```

And Stop becomes:

```matlab
function StopExperimentButtonPushed(app, event)
    ivKeithley4StopExperiment(app);
end
```

Keep both properties blocks public and keep `connectDeviceKeithley` in its
public methods block. The callbacks' methods block stays private. Properties
remain in the app so all callbacks share the same state. Leave generated
component creation, constructor, and destructor code in App Designer.

The Start file still calls `app.connectDeviceKeithley()`; the public wrapper
above routes that call to the new external implementation.

Save `_4.mlapp`, then synchronize that saved file back to this repository.

## Check in MATLAB R2022b

Make the parent `IV_Keithley` folder (containing `_4.mlapp`, not `resources`)
the MATLAB Current Folder and run:

```matlab
addpath(fullfile(pwd, 'dependencies'));
files = dir(fullfile('dependencies', 'ivKeithley4*.m'));
for k = 1:numel(files)
    [~, functionName] = fileparts(files(k).name);
    which(functionName, '-all')
    checkcode(fullfile(files(k).folder, files(k).name))
end
```

Each function should resolve to the intended file in `dependencies`. Review any
Code Analyzer messages. These commands do not start an experiment.

Run `_4` and check startup, folder selection, your usual controlled experiment,
Stop during a measurement, Save Data after acquiring data, and the close dialog
(both No and Yes). There is no breakpoint requirement.

## Subsequent edits

Edit the external `.m` files and synchronize them to the work PC. Close and
relaunch the running app between versions. Startup adds `dependencies` to the
MATLAB path. Keep that subfolder and all its files with `_4.mlapp`. Open older
apps from `legacy` when needed; their contents are unchanged.
The small App Designer wrappers stay the same for changes to these functions.

## Verification limits

Local checks verify that the sweep loop, manual callbacks, and binary apps are
unchanged and that the added prompt conditions enclose the intended dialogs.
MATLAB and instrument execution are not available on this computer. Runtime UI
layout and hardware behavior must be checked on the work PC. Existing error
handling and output shutdown order are retained.
