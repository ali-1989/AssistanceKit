import 'dart:convert';
import 'dart:io';

class ShellAssistance {
  ShellAssistance._();

  // shell('grep', ['-i', 'main', 'test.dart'])
  static Future<ProcessResult> shell(String command, List<String> arguments,{
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
    }) async {

    var process = await Process.run(
        command, arguments,
        runInShell: runInShell,
      environment: environment,
      workingDirectory: workingDirectory,
      includeParentEnvironment: includeParentEnvironment,
      stderrEncoding: stderrEncoding,
      stdoutEncoding: stdoutEncoding,
    );

    //stdout.write(process.stdout);
    //stderr.write(process.stderr);

    //process.stdout
    //process.stderr
    return process;
  }
}

/*
* process.stdout.transform(utf8.decoder).forEach(print);
  process.stdin.writeln('Hello, world!');
  * -----------------------------------------------------
  Map<String, String> env = {'PATH': 'C:\\src\\'};
  * ---------------------------------------------------
  * var p = Process.start(cmd, opts);
  p.stdout.pipe(stdout);  // Process output to stdout.
  stdin.pipe(p.stdin);    // stdin to process input.
  p.onExit = (exitCode) {
    p.close();
    onExit(exitCode);
  };
------------------------------------------------------------
* https://stackoverflow.com/questions/59746768/dart-how-to-pass-data-from-one-process-to-another-via-streams
* */