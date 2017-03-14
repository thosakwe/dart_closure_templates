import 'dart:io';
import 'package:args/args.dart';
import 'package:soy/soy.dart' as soy;
import 'package:tofu/tofu.dart' as tofu;

final ArgParser PARSER = new ArgParser(allowTrailingOptions: true)
  ..addFlag('help',
      abbr: 'h', help: 'Print this help information.', negatable: false)
  ..addOption('out', abbr: 'o', help: 'The filename to write to.');

main(List<String> args) async {
  try {
    var result = PARSER.parse(args);

    if (result['help'] ?? result.rest.isEmpty)
      printHelp();
    else {
      IOSink out = stdout;

      if (result['out'] != null) {
        var outFile = new File(result['out']);
        if (!await outFile.exists()) await outFile.create(recursive: true);
        out = outFile.openWrite();
      }

      var file = new File(result.rest.first);
      var ast = soy.parse(await file.readAsString());
      out.write(tofu.compileToString(ast));
    }
  } on ArgParserException {
    printHelp();
    exit(1);
  } catch (e) {
    rethrow;
  }
}

void printHelp() {
  print('usage: dofu [options...] <filename>\n\nOptions:');
  print(PARSER.usage);
}
