# hybrid_stack_manager example (Add-to-App)

This example includes:

- Flutter module: example/flutter_module
- Android host: /Users/zhangyc/StudioProjects/Todos
- iOS host: /Users/zhangyc/xcodeProjects/Todos

## Flutter module

1. Install deps:

```
cd example/flutter_module
flutter pub get
```

2. (Optional) Run module standalone:

```
flutter run
```

## Android host

1. Ensure module path is correct in:

`/Users/zhangyc/StudioProjects/Todos/settings.gradle`

2. Build & run:

```
cd /Users/zhangyc/StudioProjects/Todos
./gradlew :app:installDebug
```

## iOS host

1. Add Flutter module Pod to host Podfile (if not already):

```
flutter_application_path = '/Users/zhangyc/StudioProjects/hybrid_stack_manager/example/flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')
install_all_flutter_pods(flutter_application_path)
```

2. Install pods:

```
cd /Users/zhangyc/xcodeProjects/Todos
pod install
```

3. Open Todos.xcworkspace and run.
