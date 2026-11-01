import 'package:openpanel_flutter/src/models/open_panel_options.dart';
import 'package:openpanel_flutter/src/models/update_profile_payload.dart';

/// The transport used by the OpenPanel wrapper.
///
/// The wrapper delegates to the official OpenPanel Kotlin and Swift SDKs
/// through a method channel.
abstract class OpenpanelBackend {
  /// Initializes the backend.
  Future<void> initialize(OpenpanelOptions options);

  /// Enables or disables event collection in the native SDK.
  Future<void> setCollectionEnabled(bool enabled);

  /// Tracks an event.
  Future<void> track({
    required String name,
    required Map<String, dynamic> properties,
    String? profileId,
  });

  /// Creates or updates a profile.
  Future<void> identify(UpdateProfilePayload payload);

  /// Increments a numeric profile property.
  Future<void> increment({
    required String profileId,
    required String property,
    required int value,
  });

  /// Decrements a numeric profile property.
  Future<void> decrement({
    required String profileId,
    required String property,
    required int value,
  });

  /// Creates an alias for a profile.
  Future<void> alias({
    required String profileId,
    required String alias,
  });

  /// Sets properties that are sent with every event.
  Future<void> setGlobalProperties(Map<String, dynamic> properties);

  /// Sets the current profile id without sending profile data.
  Future<void> setProfileId(String profileId);

  /// Clears the current profile id and global properties.
  Future<void> clear();

  /// Flushes any queued events.
  Future<void> flush();

  /// Flushes queued events and stops waiting for a profile.
  Future<void> ready();
}
