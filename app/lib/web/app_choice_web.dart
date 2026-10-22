import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Which app this page opens: `window.itaxApp` set by the page, or `?app=` in the URL.
/// Values: cliente, motorista, admin. Anything else opens the demo hub.
String? pageAppChoice() {
  final fromPage = globalContext.getProperty<JSAny?>('itaxApp'.toJS);
  if (fromPage.isA<JSString>()) return (fromPage as JSString).toDart;
  return Uri.base.queryParameters['app'];
}
