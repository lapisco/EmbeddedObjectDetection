import 'package:camera/camera.dart';
import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  @observable
  int counter = 0;

  @observable
  XFile? imagePicked;

  @observable
  bool isBusy = true;

  @action
  void changeBusy() {
    isBusy = !isBusy;
  }

  @action
  void receiveImage(image) {
    imagePicked = image;
  }

  Future<void> increment() async {
    counter = counter + 1;
  }
}
