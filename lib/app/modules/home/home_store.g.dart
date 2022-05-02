// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$HomeStore on HomeStoreBase, Store {
  final _$counterAtom = Atom(name: 'HomeStoreBase.counter');

  @override
  int get counter {
    _$counterAtom.reportRead();
    return super.counter;
  }

  @override
  set counter(int value) {
    _$counterAtom.reportWrite(value, super.counter, () {
      super.counter = value;
    });
  }

  final _$imagePickedAtom = Atom(name: 'HomeStoreBase.imagePicked');

  @override
  XFile? get imagePicked {
    _$imagePickedAtom.reportRead();
    return super.imagePicked;
  }

  @override
  set imagePicked(XFile? value) {
    _$imagePickedAtom.reportWrite(value, super.imagePicked, () {
      super.imagePicked = value;
    });
  }

  final _$isBusyAtom = Atom(name: 'HomeStoreBase.isBusy');

  @override
  bool get isBusy {
    _$isBusyAtom.reportRead();
    return super.isBusy;
  }

  @override
  set isBusy(bool value) {
    _$isBusyAtom.reportWrite(value, super.isBusy, () {
      super.isBusy = value;
    });
  }

  final _$HomeStoreBaseActionController =
      ActionController(name: 'HomeStoreBase');

  @override
  void changeBusy() {
    final _$actionInfo = _$HomeStoreBaseActionController.startAction(
        name: 'HomeStoreBase.changeBusy');
    try {
      return super.changeBusy();
    } finally {
      _$HomeStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void receiveImage(dynamic image) {
    final _$actionInfo = _$HomeStoreBaseActionController.startAction(
        name: 'HomeStoreBase.receiveImage');
    try {
      return super.receiveImage(image);
    } finally {
      _$HomeStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
counter: ${counter},
imagePicked: ${imagePicked},
isBusy: ${isBusy}
    ''';
  }
}
