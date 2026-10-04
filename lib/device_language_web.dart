import 'dart:js_interop';

@JS('navigator.language')
external JSString get _language;

String browserLanguage() => _language.toDart;
