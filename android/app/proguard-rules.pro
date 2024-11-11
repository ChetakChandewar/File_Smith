       # Flutter-specific rules
       -keep class io.flutter.** { *; }

       # Prevents Flutter-related components from being removed
       -keep class io.flutter.plugins.** { *; }

       # Keep R class (resource class)
       -keep class **.R$* { *; }
       -keep class **.R { *; }

       # Keep SLF4J Logger classes
       -keep class org.slf4j.** { *; }
       -dontwarn org.slf4j.**


       # Remove rules for unused libraries (like Gson, Retrofit, Firebase) if not in us