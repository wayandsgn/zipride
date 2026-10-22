# Zipride em Flutter

Versão Android, iPhone e navegador da demonstração de corridas para Itapipoca. Requer Flutter **3.47.7** (Dart 3.13.5 ou compatível) e as ferramentas da plataforma.

## Desenvolvimento

Execute os comandos a partir desta pasta:

```sh
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d <identificador-do-dispositivo>
```

No Windows, use um emulador Android ou um aparelho Android conectado. Para iPhone, use um Mac com Xcode e um simulador iOS.

## Navegador e demonstração para clientes

A demo publicada está em **https://wayandsgn.github.io/zipride/**. Ela usa este mesmo app, dentro da apresentação em `../demo/`.

Para desenvolver no Windows, macOS ou Linux com Chrome instalado:

```sh
flutter run -d chrome
flutter test --platform chrome
```

O workflow `web-demo.yml` compila o app com base `/zipride/app/`, copia a apresentação para a raiz do site e só publica depois dos testes. Para reproduzir o build e a apresentação localmente:

```sh
flutter build web --release --base-href /zipride/app/ --no-web-resources-cdn
# Monte uma pasta pública com demo/* em zipride/,
# build/web/* em zipride/app/ e as três fontes Inter usadas por demo.css em zipride/fonts/.
# Sirva a pasta pública por HTTP e abra /zipride/.
```

## APK para testar no Android

```sh
flutter build apk --release
```

O arquivo fica em `build/app/outputs/flutter-apk/app-release.apk`. É uma prévia de demonstração; a configuração de assinatura de produção deve ser preparada antes da publicação em loja.

## Teste do fluxo completo

Com o emulador ou simulador iniciado:

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d <identificador-do-dispositivo>
```

As capturas são gravadas em `screenshots/`. O teste percorre busca, categorias, pagamento simulado, motorista, chat, viagem, avaliação, histórico e as demais abas. O mesmo teste é usado pelos workflows de Android e Flutter iOS.

O estado é mantido apenas em memória; reiniciar restaura os dados de exemplo. Consulte o [README principal](../README.md) para os limites da demonstração e a distinção em relação ao app original em SwiftUI.
