import 'package:fluent_ui/fluent_ui.dart';

class RoomOverviewEquipmentCard extends StatefulWidget {
  late Color? color;
  late String? label;
  late String? tooltip;
  late String? subLabel;

  RoomOverviewEquipmentCard({this.color, this.label, this.tooltip, this.subLabel});

  @override
  _RoomOverviewEquipmentCardState createState() => _RoomOverviewEquipmentCardState();
}

class _RoomOverviewEquipmentCardState extends State<RoomOverviewEquipmentCard> {
  List<Widget> cards = [

  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Tooltip(
        message: widget.tooltip ?? "This is the description of the equipment.",
        child: Stack(
          children: [
            Container(
              color: widget.color ?? Colors.grey,
              child: Center(
                child: Text(
                  widget.label ?? "1",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  widget.subLabel ?? "A",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
