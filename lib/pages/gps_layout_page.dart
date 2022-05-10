import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/pages/gps_list_page.dart';
import 'package:pizarro_app/pages/gps_page.dart';
import 'package:pizarro_app/services/navigation_service.dart';

class GpsLayoutPage extends StatefulWidget {
  @override
  State<GpsLayoutPage> createState() => _GpsLayoutPageState();
}

class _GpsLayoutPageState extends State<GpsLayoutPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late NavigationService _nav;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _nav = GetIt.instance.get<NavigationService>();

    return Scaffold(
      body: Center(
          child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const <int, TableColumnWidth>{
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: FixedColumnWidth(128),
        },
        children: [
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 128,
                  width: 128,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_location),
                    onPressed: () {
                      _nav.navigateToPage(
                        GpsPage(),
                      );
                    },
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 128,
                  width: 128,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.assessment),
                    onPressed: () {
                      _nav.navigateToPage(
                        GpsListPage(),
                      );
                    },
                    label: const Text('List'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 128,
                  width: 128,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                    label: const Text('Settings'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 128,
                  width: 128,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.info),
                    onPressed: () {},
                    label: const Text('Info'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
            ],
          )
        ],
      )),
    );
  }
}
