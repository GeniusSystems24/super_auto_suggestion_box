import 'package:flutter/material.dart';

import '../source_examples_shared.dart';

class HybridSourceScreen extends StatelessWidget {
  const HybridSourceScreen({super.key});

  @override
  Widget build(BuildContext context) => const SourceExamplesView(
    type: ExampleSourceType.hybrid,
  );
}
