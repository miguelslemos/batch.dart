<p align="center">
  <a href="https://github.com/batch-dart/batch.dart">
    <img alt="batch" width="500px" src="https://user-images.githubusercontent.com/13072231/157616062-6208b014-e104-49f4-8227-b491b7ef6d42.png">
  </a>
</p>

<p align="center">
  <b>A Lightweight and Powerful Job Scheduling Framework.</b>
</p>

---

[![pub package](https://img.shields.io/pub/v/batch.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/batch)
[![Dart SDK Version](https://badgen.net/pub/sdk-version/batch)](https://pub.dev/packages/batch/)
[![Test](https://github.com/batch-dart/batch.dart/actions/workflows/test.yml/badge.svg)](https://github.com/batch-dart/batch.dart/actions/workflows/test.yml)
[![Analyzer](https://github.com/batch-dart/batch.dart/actions/workflows/analyzer.yml/badge.svg)](https://github.com/batch-dart/batch.dart/actions/workflows/analyzer.yml)
[![codecov](https://codecov.io/gh/batch-dart/batch.dart/branch/main/graph/badge.svg?token=J5GT1PF9Y3)](https://codecov.io/gh/batch-dart/batch.dart)
[![CodeFactor](https://www.codefactor.io/repository/github/batch-dart/batch.dart/badge)](https://www.codefactor.io/repository/github/batch-dart/batch.dart)
[![Issues](https://img.shields.io/github/issues/batch-dart/batch.dart?logo=github&logoColor=white)](https://github.com/batch-dart/batch.dart/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/batch-dart/batch.dart?logo=github&logoColor=white)](https://github.com/batch-dart/batch.dart/pulls)
[![Stars](https://img.shields.io/github/stars/batch-dart/batch.dart?logo=github&logoColor=white)](https://github.com/batch-dart/batch.dart)
[![Code size](https://img.shields.io/github/languages/code-size/batch-dart/batch.dart?logo=github&logoColor=white)](https://github.com/batch-dart/batch.dart)
[![Last Commits](https://img.shields.io/github/last-commit/batch-dart/batch.dart?logo=git&logoColor=white)](https://github.com/batch-dart/batch.dart/commits/main)
[![License](https://img.shields.io/github/license/batch-dart/batch.dart?logo=open-source-initiative&logoColor=green)](https://github.com/batch-dart/batch.dart/blob/main/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](https://github.com/batch-dart/batch.dart/blob/main/CODE_OF_CONDUCT.md)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fbatch-dart%2Fbatch.dart.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fbatch-dart%2Fbatch.dart?ref=badge_shield)

---

**_Do you need a scheduled and long-lived server-side processing?_**</br>
**_If so, this is the framework you are looking for!_**

- Implementation examples are available at: [Official Examples](https://github.com/batch-dart/examples/blob/main/README.md) </br>
- Or more documentations are available at: [Official Documents](https://github.com/batch-dart/documents/blob/main/README.md)

---

<!-- TOC -->

- [1. Guide](#1-guide)
  - [1.1. Mission](#11-mission)
  - [1.2. Features](#12-features)
  - [1.3. Getting Started](#13-getting-started)
    - [1.3.1. Install Library](#131-install-library)
    - [1.3.2. Import](#132-import)
    - [1.3.3. Basic Concept](#133-basic-concept)
    - [1.3.4. Schedule Jobs](#134-schedule-jobs)
      - [1.3.4.1. Sequential Process](#1341-sequential-process)
      - [1.3.4.2. Parallel Process](#1342-parallel-process)
    - [1.3.5. Logging](#135-logging)
      - [1.3.5.1. On Sequential Process](#1351-on-sequential-process)
      - [1.3.5.2. On Parallel Process](#1352-on-parallel-process)
    - [1.3.6. Branch](#136-branch)
  - [1.4. More Examples](#14-more-examples)
  - [1.5. Contribution](#15-contribution)
  - [1.6. Support](#16-support)
  - [1.7. License](#17-license)
  - [1.8. More Information](#18-more-information)

<!-- /TOC -->

# 1. Guide

## 1.1. Mission

The goal of this project is to provide a **_high-performance_** and **_intuitive_** job scheduling in the Dart language.
And to enable people around the world to automate their tasks more easily.

And the development concept of this framework is "[DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)", "[KISS](https://en.wikipedia.org/wiki/KISS_principle)" and "[YAGNI](https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it)", which has been said in software engineering circles for a long time.

## 1.2. Features

- **Easy** and **intuitive** job scheduling.
- No complicated configuration files.
- Supports scheduling in [Cron](https://en.wikipedia.org/wiki/Cron) format.
- Supports powerful **logging feature** and it's **customizable**.
- Supports easily define **parallel processes**.
- Supports **conditional branching** of jobs and steps.
- Supports **convenient callback** functions at each event.
- Supports **skipping** and **retrying** according to user defined conditions.
- and etc...

## 1.3. Getting Started

### 1.3.1. Install Library

```bash
 dart pub add batch
```

> Note:
> Pub.dev automatically labels this library as usable for Flutter, but the intended use of this library is long-lived server-side processing.

### 1.3.2. Import

The following import will provide all the materials for developing job scheduling using `Batch.dart`.

```dart
import 'package:batch/batch.dart';
```

### 1.3.3. Basic Concept

`Batch.dart` represents the unit of scheduled processing as an `Event`.
And `Event` is composed of the following elements.

|                  | Description                                                                                                           |
| ---------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Job**          | This `Job` event is a unit of batch processing in the broad sense. And `Job` has multiple `Step` events.              |
| **ScheduledJob** | It represents a scheduled job. And `ScheduledJob` has multiple `Step` events.                                         |
| **Step**         | This event expresses the sequential processing. Each `Step` has a `Task` that defines one specific process.           |
| **ParallelStep** | This event expresses the parallel processing. Each `ParallelStep` has `ParallelTask`s that define specific processes. |

### 1.3.4. Schedule Jobs

#### 1.3.4.1. Sequential Process

Scheduling jobs using this framework is very easy.

First, create a class that defines a class extends the `Task` class and define processes in `execute` method. The `execute` method can define any process and supports both **synchronous** and **asynchronous** processing.

Second, you need to define a scheduled job. It is also easy to define a scheduled job by implementing the `build` method in a class that implements `ScheduledJobBuilder`, as in the following example. And `Batch.dart` supports standard `Cron` specifications.

Finally, let's execute `runWorkflow` method on main method with scheduled jobs as arguments!

When the `runWorkflow` method is executed, the scheduled batch process is started.

**_Example_**

```dart
import 'package:batch/batch.dart';

void main() => runWorkflow(
      jobs: [SayHelloWorldJob()],
    );


class SayHelloWorldJob implements ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Test Job',
        schedule: CronParser('*/2 * * * *'), // Execute every 2 minutes
        steps: [
          Step(
            name: 'Test Step',
            task: SayHelloWorldTask(),
          )
        ],
      );
}

class SayHelloWorldTask extends Task<SayHelloWorldTask> {
  @override
  void execute(ExecutionContext context) {
    log.info('Hello, World!');
  }
}
```

**_You can see more examples at [Official Examples](https://github.com/batch-dart/examples/blob/main/README.md)._**

#### 1.3.4.2. Parallel Process

`Batch.dart` supports powerful parallel processing and is easy to define.

When defining parallel processing, all you have to do is just inherit from `ParallelTask` and describe the process you want to parallelize in the `execute` method.

`SharedParameters` and `JobParameters` set in the main thread can be referenced through `ExecutionContext`. However, note that under the current specification, changes to the `ExecutionContext` value during parallel processing are not reflected in the main thread's `ExecutionContext`.

**_Example_**

```dart
import 'dart:async';

import 'package:batch/batch.dart';

void main() => runWorkflow(
      jobs: [DoHeavyProcessJob()],
    );

class DoHeavyProcessJob implements ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Job',
        schedule: CronParser('*/2 * * * *'), // Execute every 2 minutes
        steps: [
          ParallelStep(
            name: 'Parallel Step',
            tasks: [
              DoHeavyTask(),
              DoHeavyTask(),
              DoHeavyTask(),
              DoHeavyTask(),
            ],
          )
        ],
      );
}


class DoHeavyTask extends ParallelTask<DoHeavyTask> {
  @override
  FutureOr<void> execute(ExecutionContext context) {
    int i = 0;
    while (i < 10000000000) {
      i++;
    }
  }
}
```

### 1.3.5. Logging

The `Batch.dart` provides the following well-known logging features as a standard.
And the default log level is **trace**.

- **trace**
- **debug**
- **info**
- **warn**
- **error**
- **fatal**

The logging feature provided by `Batch.dart` has extensive customization options. For more information, you can refer to the [Official Documents](https://github.com/batch-dart/documents/blob/main/resources/02_logging.md) describing logging on `Batch.dart`.

#### 1.3.5.1. On Sequential Process

It's very easy to use logging functions on sequential process.

The logging methods provided by the `Batch.dart` can be used from any class that imports `batch.dart`. **_So no need to instantiate any Loggers by yourself_**!

All you need to specify about logging in `Batch.dart` is the configuration of the log before run `BatchApplication`, and the Logger is provided safely under the lifecycle of the `Batch.dart`.

**_Example_**

```dart
import 'package:batch/batch.dart';

class TestLogTask extends Task<TestLogTask> {
  @override
  void execute() {
    log.trace('Test trace');
    log.debug('Test debug');
    log.info('Test info');
    log.warn('Test warning');
    log.error('Test error');
    log.fatal('Test fatal');
  }
}
```

For example, if you run [example](https://pub.dev/packages/batch/example), you can get the following log output.

```bash
yyyy-MM-dd 19:25:10.575109 [info ] (_BatchApplication.run:129:11  ) - 🚀🚀🚀🚀🚀🚀🚀 The batch process has started! 🚀🚀🚀🚀🚀🚀🚀
yyyy-MM-dd 19:25:10.579318 [info ] (_BatchApplication.run:130:11  ) - Logger instance has completed loading
yyyy-MM-dd 19:25:10.580177 [info ] (_BootDiagnostics.run:32:9     ) - Batch application diagnostics have been started
yyyy-MM-dd 19:25:10.583234 [info ] (_BootDiagnostics.run:46:9     ) - Batch application diagnostics have been completed
yyyy-MM-dd 19:25:10.583344 [info ] (_BootDiagnostics.run:47:9     ) - Batch applications can be started securely
yyyy-MM-dd 19:25:10.585729 [info ] (JobScheduler.run:37:9         ) - Started Job scheduling on startup
yyyy-MM-dd 19:25:10.585921 [info ] (JobScheduler.run:38:9         ) - Detected 3 Jobs on the root
yyyy-MM-dd 19:25:10.586023 [info ] (JobScheduler.run:41:11        ) - Scheduling Job [name=Job1]
yyyy-MM-dd 19:25:10.595706 [info ] (JobScheduler.run:41:11        ) - Scheduling Job [name=Job2]
yyyy-MM-dd 19:25:10.597471 [info ] (JobScheduler.run:41:11        ) - Scheduling Job [name=Job4]
yyyy-MM-dd 19:25:10.597692 [info ] (JobScheduler.run:56:9         ) - Job scheduling has been completed and the batch application is now running
```

> Note:
> The setup of the logger is done when executing the `runWorkflow`.
> If you want to use the logging feature outside the life cycle of this library,
> be sure to do so after executing the `runWorkflow`.

#### 1.3.5.2. On Parallel Process

Parallel processing cannot directly use the convenient logging features described [above](#1351-on-sequential-process). This is because parallel processing in the Dart language **_does not share_** any instances.

Instead, use the following methods in classes that extend `ParallelTask` for parallel processing.

- **sendMessageAsTrace**
- **sendMessageAsDebug**
- **sendMessageAsInfo**
- **sendMessageAsWarn**
- **sendMessageAsError**
- **sendMessageAsFatal**

**_Example_**

```dart
class TestParallelTask extends ParallelTask<TestParallelTask> {
  @override
  FutureOr<void> execute() {
    super.sendMessageAsTrace('Trace');
    super.sendMessageAsDebug('Debug');
    super.sendMessageAsInfo('Info');
    super.sendMessageAsWarn('Warn');
    super.sendMessageAsError('Error');
    super.sendMessageAsFatal('Fatal');
  }
}
```

It should be noted that log output does not occur at the moment the above `sendMessageAsX` method is used.

This is only a function that simulates log output in parallel processing, and all messages are output at once when all parallel processing included in `Parallel` is completed.

And you can get the following log output from parallel processes.

```bash
yyyy-MM-dd 10:05:06.662561 [trace] (solatedLogMessage.output:36:13) - Received from the isolated thread [message=Trace]
yyyy-MM-dd 10:05:06.662666 [debug] (solatedLogMessage.output:39:13) - Received from the isolated thread [message=Debug]
yyyy-MM-dd 10:05:06.662760 [info ] (solatedLogMessage.output:42:13) - Received from the isolated thread [message=Info]
yyyy-MM-dd 10:05:06.662856 [warn ] (solatedLogMessage.output:45:13) - Received from the isolated thread [message=Warn]
yyyy-MM-dd 10:05:06.662947 [error] (solatedLogMessage.output:48:13) - Received from the isolated thread [message=Error]
yyyy-MM-dd 10:05:06.663039 [fatal] (solatedLogMessage.output:51:13) - Received from the isolated thread [message=Fatal]
```

### 1.3.6. Branch

`Batch.dart` supports conditional branching for each scheduled event (it's just called "**Branch**" in `Batch.dart`).

`Branch` is designed to be derived from each event, such as `Job` and `Step`. There is no limit to the number of branches that can be set up, and a recursive nesting structure is also possible.

Creating a branch for each event is very easy.

**_To create branch_**

```dart
    Step(
      name: 'Step',
      task: SwitchBranchStatusTask(),

      // Each branch can be multiple and nested
      branchesOnSucceeded: [Step(name: 'Step on succeeded', task: doSomethingTask)],
      branchesOnFailed: [Step(name: 'Step on failed', task: doSomethingTask)],
      branchesOnCompleted: [Step(name: 'Step on completed', task: doSomethingTask)],
    );
```

And the conditional branching of `Batch.dart` is controlled by switching the `BranchStatus` of each `Execution`s that can be referenced from the `ExecutionContext`.
The default branch status is "**completed**".

**_To manage branch_**

```dart
class SwitchBranchStatusTask extends Task<SwitchBranchStatusTask> {
  @override
  void execute(ExecutionContext context) {
    // You can easily manage branch status through methods as below.
    context.jobExecution!.switchBranchToSucceeded();
    context.stepExecution!.switchBranchToFailed();
  }
}
```

## 1.4. More Examples

- [Create a minimal and basic batch application](https://github.com/batch-dart/examples/blob/main/examples/bin/01_basics/01_example.dart)
- [Create a batch application consisting of multiple job nets](https://github.com/batch-dart/examples/blob/main/examples/bin/01_basics/02_example.dart)
- [Create a parallel processing tasks](https://github.com/batch-dart/examples/blob/main/examples/bin/01_basics/03_example.dart)
- [Pass command line arguments to batch application](https://github.com/batch-dart/examples/blob/main/examples/bin/01_basics/07_example.dart)
- [Create a branch and switch](https://github.com/batch-dart/examples/blob/main/examples/bin/01_basics/09_example.dart)
- [Use callback functions](https://github.com/batch-dart/examples/blob/main/examples/bin/01_basics/10_example.dart)
- [Define skippable exceptions](https://github.com/batch-dart/examples/blob/main/examples/bin/01_basics/11_example.dart)
- [Define retry processing](https://github.com/batch-dart/examples/blob/main/examples/bin/01_basics/12_example.dart)

You can check more at [Official Examples](https://github.com/batch-dart/examples/blob/main/README.md).

## 1.5. Contribution

If you would like to contribute to `Batch.dart`, please create an [issue](https://github.com/batch-dart/batch.dart/issues) or create a Pull Request.

Owner will respond to issues and review pull requests as quickly as possible.

## 1.6. Support

The simplest way to show us your support is by giving the project a star at [here](https://github.com/batch-dart/batch.dart).

And I'm always looking for sponsors to support this project. I do need support to continue ongoing open source development.

Sponsors can be individuals or corporations, and the amount is optional.

<div align="center">
  <p>
    <b>👇 Click on the button below to see more details! 👇</b>
  </p>

  <p>
    <a href="https://github.com/sponsors/myconsciousness">
      <img src="https://cdn.ko-fi.com/cdn/kofi3.png?v=3" height="50" width="210" alt="myconsciousness" />
    </a>
  </p>
</div>

## 1.7. License

All resources of `Batch.dart` is provided under the `BSD-3` license.

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fbatch-dart%2Fbatch.dart.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fbatch-dart%2Fbatch.dart?ref=badge_large)

> Note:
> License notices in the source are strictly validated based on `.github/header-checker-lint.yml`. Please check [header-checker-lint.yml](https://github.com/batch-dart/batch.dart/tree/main/.github/header-checker-lint.yml) for the permitted standards.

## 1.8. More Information

`Batch.dart` was designed and implemented by **_Kato Shinya_**.

- [Creator Profile](https://github.com/myConsciousness)
- [License](https://github.com/batch-dart/batch.dart/blob/main/LICENSE)
- [API Document](https://pub.dev/documentation/batch/latest/batch/batch-library.html)
- [Official Documents](https://github.com/batch-dart/documents/blob/main/README.md)
- [Official Examples](https://github.com/batch-dart/examples/blob/main/README.md)
- [Wikipedia](https://ja.wikipedia.org/wiki/Batch.dart)
- [Release Note](https://github.com/batch-dart/batch.dart/releases)
- [Bug Report](https://github.com/batch-dart/batch.dart/issues)
