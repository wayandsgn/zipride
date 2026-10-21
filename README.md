# Zipride

App iOS de corridas (SwiftUI, iOS 26) ambientado em Itapipoca, Ceará. Tudo roda offline com dados de exemplo: Pix, R$, placa Mercosul, motorista Marcos no Chevrolet Onix.

## Como rodar

```sh
brew install xcodegen
xcodegen generate
open Zipride.xcodeproj
```

Escolha um iPhone no simulador e aperte ▶︎.

## CI

O workflow `.github/workflows/ios.yml` roda num Mac do GitHub: confere as imagens do Unsplash, gera o projeto, compila, abre o app no simulador e percorre todos os fluxos com `ZiprideUITests`. Os prints de cada tela ficam no artefato `zipride-results`.
