import 'package:flutter/material.dart';

class UserDetailView extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailView({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    if (userData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("User Details")),
        body: const Center(child: Text("No login data available.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Login informations"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PROFILE HEADER
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(userData['image']),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userData['login'], style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 4),
                              Text(userData['email']),
                              Text("Phone: ${userData['mobile'] ?? 'N/A'}"),
                              Text("Wallet: ${userData['wallet'] ?? '€0'}"),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SKILLS SECTION
                    Text("Skills", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...List<Widget>.from(userData['skills'].map<Widget>((skill) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${skill['name']} - Level: ${skill['level'].toStringAsFixed(2)}"),
                            LinearProgressIndicator(
                              value: skill['level'] / 20.0,
                              minHeight: 8,
                            ),
                          ],
                        ),
                      );
                    })),

                    const SizedBox(height: 24),

                    // PROJECTS SECTION
                    Text("Projects", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...List<Widget>.from(userData['projects'].map<Widget>((project) {
                      return Card(
                        color:  Colors.green[100],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(project['name']),
                          subtitle: Text("Status: ${project['status']}"),
                          trailing: Text(
                            "${project['final_mark'] != null ? project['final_mark'].toString() : 'N/A'} pts",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    })),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
