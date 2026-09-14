import 'package:flutter/material.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prestamos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por usuario o material...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {},
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'all',
                      child: Text('Todos'),
                    ),
                    const PopupMenuItem(
                      value: 'active',
                      child: Text('Activos'),
                    ),
                    const PopupMenuItem(
                      value: 'overdue',
                      child: Text('Vencidos'),
                    ),
                    const PopupMenuItem(
                      value: 'returned',
                      child: Text('Devueltos'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Loans List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index % 2 == 0
                          ? Colors.purple.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.assignment,
                        color: index % 2 == 0 ? Colors.purple : Colors.red,
                      ),
                    ),
                    title: Text('Prestamo ${index + 1}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Usuario: Usuario ejemplo'),
                        Text('Material: Material ejemplo'),
                        Text(
                          'Fecha prestamo: ${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().month}/${DateTime.now().year}',
                        ),
                        Text(
                          'Devolucion: ${DateTime.now().add(Duration(days: 7 - index)).day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: TextStyle(
                            color: index % 2 == 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'return',
                          child: Text('Devolver'),
                        ),
                        const PopupMenuItem(
                          value: 'extend',
                          child: Text('Prorrogar'),
                        ),
                        const PopupMenuItem(
                          value: 'details',
                          child: Text('Ver detalles'),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
