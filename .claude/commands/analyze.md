---
description: "Run flutter analyze and dart fix --dry-run to catch lint issues"
---

Analyze the Flutter project for lint and type errors:

```!
cd /Users/mac/Developer/Freelance/creative/creative && flutter analyze
```

Then check for auto-fixable issues:

```!
cd /Users/mac/Developer/Freelance/creative/creative && dart fix --dry-run
```

Summarize any issues found. If `dart fix` reports fixable issues, ask the user whether to apply them.
