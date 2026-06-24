import 'package:get/get.dart';

class HomeController extends GetxController {
  final navIndex = 0.obs;

  void setTab(int index) => navIndex.value = index;
}
