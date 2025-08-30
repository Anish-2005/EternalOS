// Conditional exports to provide a mobile implementation (speech_to_text)
// and a minimal web fallback.
export 'voice_service_mobile.dart'
    if (dart.library.html) 'voice_service_web.dart';
