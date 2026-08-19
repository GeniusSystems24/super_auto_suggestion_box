import 'package:flutter/material.dart';

import '../source_examples_shared.dart';

class PagedSourceScreen extends StatelessWidget {
  const PagedSourceScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const SourceExamplesView(type: ExampleSourceType.paged);
}
