# Zipride

Demonstração de um app de corridas para Itapipoca, Ceará, em português: busca de destino, categorias de viagem, pagamento, motorista, chat, percurso, avaliação, recibos e abas Serviços, Atividade e Conta.

## Versões do projeto

| Pasta | Implementação | Plataformas |
| --- | --- | --- |
| `app/` | Flutter, versão mais recente | Android, iPhone e navegador |
| `demo/` | Apresentação interativa do mesmo app Flutter | Navegador no computador ou celular |
| `Zipride/` e `ZiprideUITests/` | Versão original em SwiftUI | iPhone com iOS 26 |

As duas implementações têm testes separados. Um teste bem-sucedido da versão SwiftUI não comprova o funcionamento da versão Flutter no iPhone.

## Experimentar no Android

O APK de demonstração fica na [prévia Android](https://github.com/wayandsgn/zipride/releases/tag/android-preview). Essa versão usa dados fictícios e não solicita corridas nem realiza pagamentos reais.

## Demonstrar ao cliente pelo navegador

Abra **[wayandsgn.github.io/zipride](https://wayandsgn.github.io/zipride/)**. A apresentação inclui o aplicativo Flutter real em formato de celular, um roteiro curto, um botão para reiniciar e outro para copiar o link. Não exige instalação nem login. Use “Abrir somente o aplicativo” para apresentar sem o texto lateral.

Todos os destinos, corridas e pagamentos são simulados. Reiniciar restaura os exemplos. A primeira abertura baixa o aplicativo; mantenha a internet disponível para mapas e fotografias.

## Desenvolver a versão Flutter

Use Flutter **3.47.7**, a mesma versão fixada nos workflows, e o SDK da plataforma desejada. O simulador de iPhone exige macOS e Xcode; no Windows, use um Android conectado ou um emulador Android.

```sh
cd app
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d <identificador-do-dispositivo>
```

Veja [app/README.md](app/README.md) para executar no navegador, gerar o APK e testar o fluxo completo.

## Testes automáticos

| Workflow | O que verifica | Resultados |
| --- | --- | --- |
| `android.yml` | Analisa e testa o Flutter, gera o APK e percorre o fluxo no emulador Android | Artefato `zipride-android`, branch `ci-results-android` e prévia Android após sucesso |
| `flutter-ios.yml` | Analisa e testa o mesmo Flutter, compila sem assinatura e percorre o fluxo no simulador iPhone | Artefato `zipride-flutter-ios`, com logs e capturas |
| `ios.yml` | Compila e testa a implementação original em SwiftUI | Artefato `zipride-results`; a branch `ci-results` é atualizada apenas nas execuções de `main` |
| `web-demo.yml` | Testa o fluxo em Chrome, compila Flutter Web e verifica a apresentação em quatro tamanhos de tela | Capturas `zipride-web-checks` e publicação no GitHub Pages após sucesso |

Durante esta revisão, a demo também é publicada a partir da branch `codex/zipride-ios-validation`. Após a integração, `main` continua publicando as alterações do app e da apresentação.

Os workflows de iOS aguardam a inicialização completa do simulador antes de iniciar o teste. A compilação para simulador não gera um app assinado para instalar em um iPhone físico ou publicar na App Store.

## Limites da demonstração

- Corridas, preços, motorista, chat, Pix/cartão/dinheiro e agendamentos são simulados. Não há servidor, autenticação, cobrança, despacho de motoristas ou localização real.
- A versão Flutter mantém o estado apenas em memória: ao reiniciar, o histórico volta aos exemplos.
- Mapas e fotografias dependem de serviços externos e de internet. Os testes de widget desativam os mapas.
- Os lugares e percursos de exemplo de Itapipoca precisam ser conferidos antes de qualquer uso real.

## Abrir a versão original em SwiftUI

Em um Mac com Xcode 26:

```sh
brew install xcodegen
xcodegen generate
open Zipride.xcodeproj
```

Escolha um iPhone com iOS 26 no simulador e execute o projeto.
