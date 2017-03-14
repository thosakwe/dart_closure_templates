import 'package:code_builder/code_builder.dart';
import 'package:recase/recase.dart';
import 'package:soy/soy.dart' as soy;

Map<String, String> _names = {};

ReCase _normalize(String name) {
  return new ReCase(name.toLowerCase().replaceAll('.', '_'));
}

String _convertCamel(String name) {
  if (_names.containsKey(name)) return _names[name];
  return _names[name] = _normalize(name).camelCase;
}

String compileToString(soy.TemplateContext template) =>
    prettyToSource(compile(template).buildAst());

LibraryBuilder compile(soy.TemplateContext template) {
  var lib = new LibraryBuilder();
  lib.addMember(_compileClass(template));
  return lib;
}

ClassBuilder _compileClass(soy.TemplateContext template) {
  var clazz = new ClassBuilder(
      _normalize(template.namespace.name).pascalCase + 'Renderer');
  bool strictAutoEscape = false;

  for (var member in template.namespace.members) {
    if (member is soy.AttributeContext && member.name == 'autoescape') {
      if (member.value == 'strict') {
        strictAutoEscape = true;
        break;
      }
    }
  }

  for (var node in template.nodes) {
    if (node.tagName == 'template')
      clazz.addMethod(_compileTemplate(node, strictAutoEscape));
  }

  return clazz;
}

MethodBuilder _compileTemplate(soy.NodeContext node, bool strictAutoEscape) {
  String className = (node.members.firstWhere(
          (member) => member is soy.ClassContext,
          orElse: () => null) as soy.ClassContext)
      ?.name;

  if (className == null) throw new StateError('This template has no name.');

  var meth = new MethodBuilder(_convertCamel(className),
      returnType: new TypeBuilder('String'));
  return meth;
}
