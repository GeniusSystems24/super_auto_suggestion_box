import 'package:flutter/material.dart';

import '../source_examples_shared.dart';

class FuzzySourceScreen extends StatelessWidget {
  const FuzzySourceScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const SourceExamplesView(type: ExampleSourceType.fuzzy);
}
