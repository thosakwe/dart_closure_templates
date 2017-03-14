import 'dart:async';
import 'package:build/build.dart';
import 'package:soy/soy.dart' as soy;
import 'tofu.dart' as tofu;

class TofuBuilder implements Builder {
  const TofuBuilder();

  @override
  List<AssetId> declareOutputs(AssetId inputId) =>
      [inputId.changeExtension('.g.dart')];

  @override
  Future build(BuildStep buildStep) async {
    var contents = await buildStep.readAsString(buildStep.inputId);
    var ast = soy.parse(contents, sourceUrl: buildStep.inputId.path);
    var compiled = tofu.compileToString(ast);
    buildStep.writeAsString(
        buildStep.inputId.changeExtension('.g.dart'), compiled);
  }
}
