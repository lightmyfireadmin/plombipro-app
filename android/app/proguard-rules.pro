# Stripe SDK ProGuard Rules
# Keep all Stripe classes to prevent R8 issues
-keep class com.stripe.android.** { *; }
-keep interface com.stripe.android.** { *; }
-keepclassmembers class com.stripe.android.** { *; }

# Dontwarn rules for Stripe push provisioning (not used in Flutter)
-dontwarn com.stripe.android.pushProvisioning.**

# Dontwarn rules for React Native Stripe SDK (not applicable to Flutter apps)
-dontwarn com.reactnativestripesdk.**

# Keep Flutter Stripe plugin classes
-keep class com.flutter.stripe.** { *; }

# Keep all inner classes
-keepattributes InnerClasses
-keep class **.R
-keep class **.R$* {
    <fields>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
