/*
import 'dart:mirrors'; //is are under development

List<ClassMirror> findSubClasses(Type type) {
	ClassMirror classMirror = reflectClass(type);

	return currentMirrorSystem()
			.libraries
			.values
			.expand((lib) => lib.declarations.values)
			.where((lib) {return lib is ClassMirror && lib.isSubclassOf(classMirror) && lib != classMirror;})
			.toList();
}*/
