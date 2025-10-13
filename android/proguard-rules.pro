# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Gson specific classes
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep model classes
-keep class **.models.** { *; }
-keep class **.src.models.** { *; }

# Keep API response classes
-keep class **.api_client.** { *; }
-keep class **.auth_repo.** { *; }
-keep class **.trip_repo.** { *; }
-keep class **.finance_repo.** { *; }
-keep class **.documents_repo.** { *; }
-keep class **.profile_repo.** { *; }
-keep class **.notifications_repo.** { *; }
-keep class **.history_repo.** { *; }
-keep class **.vehicle_repo.** { *; }
-keep class **.driver_status.** { *; }
-keep class **.shared_repo.** { *; }
-keep class **.rewards_repo.** { *; }
-keep class **.localstorage.** { *; }

# Keep BLoC classes
-keep class **.bloc.** { *; }
-keep class **.cubit.** { *; }

# Keep service classes
-keep class **.services.** { *; }

# Keep utility classes
-keep class **.utils.** { *; }
-keep class **.constants.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.location.** { *; }

# Dio HTTP client
-keep class dio.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Socket.IO
-keep class io.socket.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable implementations
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Remove debug logs in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Keep line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
