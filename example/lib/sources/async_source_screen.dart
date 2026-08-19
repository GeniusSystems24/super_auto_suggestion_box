import 'package:flutter/material.dart';

import '../source_examples_shared.dart';

class AsyncSourceScreen extends StatelessWidget {
  const AsyncSourceScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const SourceExamplesView(type: ExampleSourceType.asyncSource);
}
