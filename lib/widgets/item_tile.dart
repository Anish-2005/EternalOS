import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';

class ItemTile extends StatelessWidget {
  final String title;
  const ItemTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context, listen: false);
    return ListTile(
      title: Text(title),
      trailing: ElevatedButton(
        onPressed: () {
          ctx.addToCart(title);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Added $title to cart')));
        },
        child: const Text('Add'),
      ),
    );
  }
}
