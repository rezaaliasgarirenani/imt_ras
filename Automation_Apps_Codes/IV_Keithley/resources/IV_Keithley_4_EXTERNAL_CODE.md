# Editing IV_Keithley_4 outside App Designer

The Start callback is already connected to its external file in the current
`IV_Keithley_4.mlapp`; the user has run a test experiment successfully.
The other six implementations are now extracted, but their wrappers must still
be saved in App Designer on the MATLAB R2022b work PC.

This migration preserves the existing logic. No experiment behavior is changed.

## One-time replacements

Synchronize the whole folder to the work PC. The layout is:

```text
IV_Keithley/
    IV_Keithley_4.mlapp
    dependencies/       # all seven ivKeithley4*.m files
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
MATLAB path. Keep that subfolder and all seven files with `_4.mlapp`. Open older
apps from `legacy` when needed; their contents are unchanged.
The small App Designer wrappers stay the same for changes to these functions.

## Verification limits

Local checks compare each new implementation with its original body and check
access to referenced app members. MATLAB and instrument execution are not
available on this computer. The original logic, including existing error
handling and output shutdown order, is retained. The six new wrappers still
need runtime verification on the work PC.
