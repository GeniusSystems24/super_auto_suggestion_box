import 'package:flutter/material.dart';

import '../source_examples_shared.dart';

class RemoteFallbackSourceScreen extends StatelessWidget {
  const RemoteFallbackSourceScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const SourceExamplesView(type: ExampleSourceType.remoteFallback);
}
