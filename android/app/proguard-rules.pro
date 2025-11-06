# Stripe SDK ProGuard Rules
# Keep all Stripe classes to prevent R8 issues
-keep class com.stripe.android.** { *; }
-keep interface com.stripe.android.** { *; }
-keepclassmembers class com.stripe.android.** { *; }

# Keep Stripe push provisioning classes specifically
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep interface com.stripe.android.pushProvisioning.** { *; }

# Keep React Native Stripe SDK classes (if using)
-keep class com.reactnativestripesdk.** { *; }
-keep interface com.reactnativestripesdk.** { *; }

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
