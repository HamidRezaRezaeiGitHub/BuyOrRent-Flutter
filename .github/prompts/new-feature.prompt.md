---
description: "Create a new feature module with the standard folder structure, screen widget, and provider."
---

# New Feature Module

Create a new feature module following the project's feature-first architecture.

Feature name: ${featureName}

## Steps

1. Create folder: `lib/features/${featureName}/`
2. Create the main screen widget: `lib/features/${featureName}/${featureName}_screen.dart`
3. If state is needed, create a provider: `lib/features/${featureName}/${featureName}_provider.dart`
4. Add a route in `lib/app/router.dart`
5. Create a test file: `test/features/${featureName}/${featureName}_screen_test.dart`

## Template (Screen)

```dart
import 'package:flutter/material.dart';

class ${FeatureName}Screen extends StatelessWidget {
  const ${FeatureName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('${FeatureName}'),
      ),
    );
  }
}
```

Follow the coding standards in `.github/instructions/dart-flutter.instructions.md`.
