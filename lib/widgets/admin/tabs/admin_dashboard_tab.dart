import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  int blacklistedWebsites = 0;
  void getBlacklistedWebsites() async {
    final blacklistedWebsitesCount = await firestore
        .collection("blacklist")
        .get()
        .then((value) => value.docs.length);
    setState(() {
      blacklistedWebsites = blacklistedWebsitesCount;
    });
  }

  @override
  void initState() {
    getBlacklistedWebsites();
    super.initState();
  }

  final firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('whitelist').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // first child is a pie chart of total whitelisted websites with active and inactive
            SiteChart(snapshot: snapshot),
            // second child is a row which has cards
            Expanded(
              child: Row(
                children: [
                  // first card is total whitelisted websites with number
                  NumberCard(
                    title: "Total whitelisted websites",
                    number: snapshot.data!.docs.length.toDouble(),
                  ),
                  // second card is total blacklisted websites, get it from blacklist collection
                  // get it from firestore blacklist collection the number of docs
                  NumberCard(
                    title: "Total Blacklisted websites",
                    number: blacklistedWebsites.toDouble(),
                  ),
                  NumberCard(
                    title: "Total Active websites",
                    number: snapshot.data!.docs
                        .where((doc) => doc['status'] == true)
                        .length
                        .toDouble(),
                  ),
                ],
              ),
            ),
            // second child is a list of whitelisted websites with active and inactive
          ],
        );
      },
    );
  }
}

class SiteChart extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot<Object?>> snapshot;
  const SiteChart({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text("Welcome Admin",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        )),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Text("Active"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 10),
                        Text("InActive "),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: PieChart(PieChartData(
                centerSpaceColor: Colors.grey.shade100,
                borderData: FlBorderData(show: true),
                sectionsSpace: 0,
                sections: [
                  PieChartSectionData(
                      titleStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      // title: "Total sites",
                      value: snapshot.data!.docs
                          .where((doc) => doc['status'] == false)
                          .length
                          .toDouble(),
                      color: Colors.grey.shade500),
                  PieChartSectionData(
                      titleStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      // title: "Active sites",
                      value: snapshot.data!.docs
                          .where((doc) => doc['status'] == true)
                          .length
                          .toDouble(),
                      color: Theme.of(context).colorScheme.primary),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberCard extends StatelessWidget {
  final String title;
  final double number;
  const NumberCard({super.key, required this.title, required this.number});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              Text(
                "$number",
                style: TextStyle(fontSize: 60),
              ),
            ],
          ),
          color: Colors.green.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
