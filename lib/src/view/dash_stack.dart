import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/master_controller.dart';
import 'auto_action_view.dart';

class DashStack extends StatefulWidget {
  final Widget child;
  const DashStack({super.key, required this.child});

  @override
  State<DashStack> createState() => _DashStackState();
}

class _DashStackState extends State<DashStack> {
  @override
  void initState() {
    Get.put<MasterController>(MasterController());
    MasterController.to.callUserDetail();
    MasterController.to.callGetAction();
    MasterController.to.startActivityCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: MasterController.to.actionList.stream,
          builder: (context, snapshot) {
            return Stack(
              fit: StackFit.expand,
              children: [
                ...MasterController.to.actionList.map((e) => AutoActionView(
                      actionElement: e,
                      key: UniqueKey(),
                    )),
                Positioned.fill(child: Container(color: Theme.of(context).canvasColor, child: widget.child)),
              ],
            );
          }),
    );
  }
}
