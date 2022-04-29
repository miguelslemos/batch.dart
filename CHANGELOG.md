# Release Note

## v1.3.0

- Added `runWorkflow` method as an application entry point and deprecated `BatchApplication`. ([#180](https://github.com/batch-dart/batch.dart/issues/180))

## v1.2.0

- Eliminated the `addSchedule` method and added a `jobs` field to the `BatchApplication` constructor to specify the `ScheduledJobBuilder`. ([#171](https://github.com/batch-dart/batch.dart/issues/171))
- Added `argsConfigBuilder` callback to `BatchApplication` to more easily build `ArgParser`. ([#174](https://github.com/batch-dart/batch.dart/issues/174))
- Eliminated the `addSharedParameter` method from `BatchApplication` and added the `sharedParameters` argument to the constructor of `BatchApplication`. ([#173](https://github.com/batch-dart/batch.dart/issues/173))
- Add `jobParameters` argument to the `Job` and `ScheduledJob` constructors. ([#177](https://github.com/batch-dart/batch.dart/issues/177))

## v1.1.0

- Eliminated `nextStep` when adding steps and added `steps` to the `Job` and `ScheduledJob` constructors. This necessitates a change in the procedure for adding steps. ([#164](https://github.com/batch-dart/batch.dart/issues/164))
- Changed the `nextSchedule` method to the `addSchedule` method when adding a scheduled job to the `BatchApplication`. ([#167](https://github.com/batch-dart/batch.dart/issues/167))

## v1.0.1

- Fixed `README.md`.
- Refactored dependencies. ([#160](https://github.com/batch-dart/batch.dart/issues/160))

## v1.0.0

- Made changes to the specifications to make it easier and safer to use the framework.
  - The method of adding Tasks to Steps has been changed.
  - Specify `Task` or `ParallelTask` in the constructor of `Step` or `ParallelStep`, not `registerStep` and `registerParallel`.
  - The method to create branches are changed. Use`branchesOnSucceeded`, `branchesOnFailed`, `branchesOnCompleted` in the constructors of Events such as `Job` and `Step` instead of in the `createBranch...` methods.
  - The method for setting up a job in `BatchApplication` has changed. Use the `nextSchedule` method instead of `addJob`. Also, pass a class that extends `ScheduledJobBuilder` to this `nextSchedule` method; the object that should be returned from `ScheduledJobBuilder` is `ScheduledJob`, which must be scheduled.
  - `SkipConfiguration` and `RetryConfiguration` settings were limited to `Step` only. ([#145](https://github.com/batch-dart/batch.dart/issues/145))

## v0.12.2

- Enhanced `README.md`.

## v0.12.1

- Enhanced `README.md` and added examples.

## v0.12.0

- The `args` argument of the `onLoadArgs` callback is now non-nullable. The null check is no longer necessary. ([#135](https://github.com/batch-dart/batch.dart/issues/135))

## v0.11.0

- Improved names of branch features. Now you can create branches with `createBranchOnXXXXX` and switch branches with `switchBranchToXXXXX`. ([#128](https://github.com/batch-dart/batch.dart/issues/128))
- Fixed to be able to refer to ExecutionContext in processing Precondition. ([#132](https://github.com/batch-dart/batch.dart/issues/132))

## v0.10.0

- Allows parallel processing to use the main thread `ExecutionContext`. ([#121](https://github.com/batch-dart/batch.dart/issues/121))
- Removed `trace`, `debug`, `info`, `warn`, `error`, and `fatal` from convenient methods of logging feature. Make sure to access the logger from `log`. ([#125](https://github.com/batch-dart/batch.dart/issues/125)
- Changed specification regarding tasks to be set in `Step`. Under the new specification, there will always be only one task that can be set in a single step. ([#123](https://github.com/batch-dart/batch.dart/issues/123))

## v0.9.0

- Improved schedule checking process. ([#118](https://github.com/batch-dart/batch.dart/issues/118))
- Fixed handling of duplicate keys in `Parameters`. ([#117](https://github.com/batch-dart/batch.dart/issues/117))

## v0.8.1

- Improved `README.md`.

## v0.8.0

- Changed startup banner. ([#101](https://github.com/batch-dart/batch.dart/issues/101))
- Add `onRecover` feature to `RetryConfiguration`. It's executed when all retry has failed. ([#100](https://github.com/batch-dart/batch.dart/issues/100))
- Supported to output log errors during parallel processing. ([#99](https://github.com/batch-dart/batch.dart/issues/99))
- Added `onLoadArgs` callback in the `BatchApplication`. ([#102](https://github.com/batch-dart/batch.dart/issues/102))
- Enhanced customizability of `LogPrinter`. ([#107](https://github.com/batch-dart/batch.dart/issues/107))

## v0.7.1

- Enhanced documents on `README`.

## v0.7.0

- Added feature to allow to execute `parallel` processing. ([#25](https://github.com/batch-dart/batch.dart/issues/25), [#74](https://github.com/batch-dart/batch.dart/issues/74),[#84](https://github.com/batch-dart/batch.dart/issues/84), [#87](https://github.com/batch-dart/batch.dart/issues/87))
- Added a convenient reference to `logger_provider`. Now you can access to logging features with `log.`prefix like `log.debug('debug')`. ([#73](https://github.com/batch-dart/batch.dart/issues/73))
- Added `MultiLogOutput` to allow multiple log output methods. ([#82](https://github.com/batch-dart/batch.dart/issues/82))
- A specification has been added to suppress multiple launches of batch applications within the same thread. ([#81](https://github.com/batch-dart/batch.dart/issues/81))

## v0.6.0

- Added the feature to log notifications at application startup when there are library updates. ([#32](https://github.com/batch-dart/batch.dart/issues/32))
- Changed the log level of the system log regarding application shutdown from `info` to `warn`. ([#45](https://github.com/batch-dart/batch.dart/issues/45))
- Standardized notation regarding licenses. ([#44](https://github.com/batch-dart/batch.dart/issues/44))
- Command line arguments can now be easily passed to batch applications. Command line arguments can be used throughout the framework lifecycle as `SharedParameters`. ([#13](https://github.com/batch-dart/batch.dart/issues/13))

## v0.5.1

- Improved coloring process for log output. Added `logColor` field to `LogOutput` and modified the class `ConsoleLogOutput` to get the console color. ([#31](https://github.com/batch-dart/batch.dart/issues/31))

## v0.5.0

- Added the feature to specify any exception type before application execution and skip exceptions that occur during application processing. Only classes that inherit from `Exception` are eligible; classes that inherit from `Error` are not eligible for this retry feature. ([#12](https://github.com/batch-dart/batch.dart/issues/12))
- Added the feature to specify any exception type before application execution and retry when exception occurs during application processing. Only classes that inherit from `Exception` are eligible; classes that inherit from `Error` are not eligible for this skip feature. ([#20](https://github.com/batch-dart/batch.dart/issues/20))
- Added convenient method `shutdown()` to shutdown application in `Step` ([#17](https://github.com/batch-dart/batch.dart/issues/17)).
- Precondition callback now supports asynchronous processing. ([#21](https://github.com/batch-dart/batch.dart/issues/21))
- Callbacks (onStarted, onSucceeded, onError, onCompleted) now support asynchronous processing. ([#23](https://github.com/batch-dart/batch.dart/issues/23))

## v0.4.0

- Added `onStarted`, `onSucceeded`, `onError` and `onCompleted` callbacks for `Job`, `Step` and `Task`.
- Added feature to specify the color of the message when logging out with `LogColor` and `ConsoleColor`.
- Improved log message from framework.
- Added convenient method `shutdown()` to shutdown the application from `Task`.
- Changed to define `Precondition` as an anonymous function.

## v0.3.0

- Added `Precondition` to check the preconditions for executing `Job`, `Step` and `Task`.
- Conditional branching is now possible for the all layers (`Job`/`Step`/`Task`) based on `BranchStatus` by using the `branchOnSucceeded`, `branchOnFailed` and `branchOnCompleted`.
- Due to the feature to create branches in `Job`, the schedule argument of the `Job` object is no longer required. However, be sure to set up a schedule for the root `Job`s.
- Changed the type of the argument when specifying `Job` scheduling. Now you can use `CronParser` to specify the schedule in Cron format.

## v0.2.1

- Added `DefaultLogFilter`.
- Added `Precondition` to check the starting condition of `Job` and `Step`. It can be specified as an argument when creating `Job` and `Step` instances.
- Deleted `DevelopmentLogFilter` and `ProductionLogFilter`.

## v0.2.0

- Added logging feature. Some logs are automatically output to the console during batch processing, but you can output logs at any log level by using the various methods for log output.
- Enabled parameter exchange between tasks in the same step.
- Added the concept of SharedParameters, which are shared by the entire batch application.
- Refactored the structure, made `JobLauncher` private and released `BatchApplication` as new entry point.
- Added ExecutionContext as an argument to the execute method of the Task class.

## v0.1.0

- Improved documents.
- Wrapped the return value of execute with `Future` to allow asynchronous processing in `Task`. Asynchronous processing defined in `Task` is safely controlled by the `batch` library, so you don't need to be aware of it when running `JobLauncher`.

## v0.0.1

- First Release!
