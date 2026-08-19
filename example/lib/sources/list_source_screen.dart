import 'package:flutter/material.dart';

import '../source_examples_shared.dart';

class ListSourceScreen extends StatelessWidget {
  const ListSourceScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const SourceExamplesView(type: ExampleSourceType.list);
}
