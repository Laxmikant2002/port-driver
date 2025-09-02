import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({super.key});

  final List<Map<String, String>> transactions = [
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for rider',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for ride',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for ride',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for ride',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for ride',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for ride',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for ride',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for ride',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for ride',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for ride',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
    {
      'imageURL':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKWdGBM5jGP3oHdusQo1-bnZcdmwXg5vofdvPZs-XUy8vGYx2mAPD0nEyYaA&s',
      'title': 'Received for ride',
      'date': '20 Jun, 10:20 AM',
      'amount': r'+ $13.00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          'Wallet',
          style: TextStyle(
            fontSize: 27,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColoredBox(
            color: Colors.black,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 7),
                          Text(
                            r'$ 150.50',
                            style: TextStyle(
                              fontSize: 35,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/send-to-bank');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Withdraw',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(
            thickness: 5,
            color: Color.fromARGB(255, 229, 229, 229),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return transactionTile(
                  transactions[index]['imageURL']!,
                  transactions[index]['title']!,
                  transactions[index]['date']!,
                  transactions[index]['amount']!,
                );
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 3,
                color: Color.fromARGB(255, 229, 229, 229),
              ),
            ),
          ),
          const Divider(
            thickness: 3,
            color: Color.fromARGB(255, 229, 229, 229),
          ),
        ],
      ),
    );
  }
}

Widget transactionTile(
  String imageURL,
  String title,
  String date,
  String amount,
) {
  return ListTile(
    // tileColor: Colors.white,
    leading: CircleAvatar(
      backgroundImage: NetworkImage(
        imageURL,
      ),
      radius: 25,
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              date,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
