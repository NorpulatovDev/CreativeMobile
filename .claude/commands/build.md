---
description: "Build the Flutter app for a target platform"
argument-hint: "apk|ios|web [--release|--debug]"
---

Build the Flutter app for the specified platform. If no argument is given, default to `apk --debug`.

```!
cd /Users/mac/Developer/Freelance/creative/creative && flutter build ${ARGUMENTS:-apk --debug}
```

Report the output path of the built artifact on success. On failure, show the error and suggest fixes.
