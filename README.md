
```markdown
# RuraLTime

Aplicativo Flutter para **monitoramento de seca** com **score de risco explicável (IA)**, **visualização em gráficos**, **mapa por geolocalização** e **integração operacional (ManageEngine – modo DEMO)**.

> Projeto acadêmico – FIAP Enterprise Challenge.

---

## Sumário

- [Visão geral](#visão-geral)
- [Principais funcionalidades](#principais-funcionalidades)
- [Arquitetura (alto nível)](#arquitetura-alto-nível)
- [IA de risco (explicável)](#ia-de-risco-explicável)
- [Integração ManageEngine (DEMO)](#integração-manageengine-demo)
- [Pré-requisitos](#pré-requisitos)
- [Como rodar (dev)](#como-rodar-dev)
- [Build (APK/IPA)](#build-apkipa)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Configurações importantes](#configurações-importantes)
- [Demonstração rápida (roteiro)](#demonstração-rápida-roteiro)
- [Solução de problemas](#solução-de-problemas)
- [Licença](#licença)
- [Links](#links)

---

## Visão geral

O **RuraLTime** ajuda produtores a **perceber risco de seca em tempo real** e **agir rapidamente** quando o risco sobe:

- Consulta clima local via **OpenWeather** (lat/lon).
- Calcula **score de risco (0–100)** usando **temperatura, umidade e VPD** (déficit de pressão de vapor).
- Explica o score com **contribuições por fator** (IA explicável).
- Exibe **mapa**, **gráficos** (Temp/Umidade/VPD) e **atalhos operacionais** (ManageEngine – DEMO).
- Inclui botões de **emergência (193)** e **Sair** em telas principais.

---

## Principais funcionalidades

- 🔎 **Home**: “Analisar” → pega localização, consulta clima, mostra alerta rápido e abre **Mapa**.
- 🧠 **IA & Alertas**: score, faixa (baixo/médio/alto), VPD (kPa), **chips** com contribuição por fator, botões de **métrica**/**ticket** (ManageEngine – DEMO).
- 📈 **Gráficos**: **Temperatura** (barras), **Umidade** (linha) e **VPD** (linha).  
  *Sem séries históricas?* A tela simula 5 dias **a partir do clima real atual** (tendência coerente).
- 🆘 **Suporte**: abertura de ticket manual (DEMO) + **Logs ManageEngine (DEMO)**.
- ℹ️ **Sobre**: versão do app, status de configuração (OWM/ME), links úteis.
- ☎️ **Ações rápidas**: **193** (liga) e **Sair** (logout) no rodapé de telas chave.

---

## Arquitetura (alto nível)

```

Flutter App (Material 3)
├─ Services
│   ├─ LocationService        → geolocalização
│   ├─ ApiService/OpenWeather → clima por lat/lon (OWM\_KEY via --dart-define)
│   ├─ RiskService (IA)       → score 0..100, VPD, explicabilidade
│   └─ ManageEngineService    → métricas/tickets (DEMO por padrão)
├─ Provider
│   └─ ClimaProvider          → estado do clima na UI
└─ Views (Screens)
├─ Login / Home / Mapa
├─ IA & Alertas / Gráficos
├─ Suporte / Logs (DEMO)
└─ Sobre

````

- **Credenciais seguras**: nada hardcoded → `--dart-define`.
- **Estado**: `provider`.

---

## IA de risco (explicável)

Arquivo: `lib/services/risk_service.dart`

- **Score (0–100)** combina:
  - Temperatura (20–40°C),
  - **Secura** (1 − umidade relativa),
  - **VPD** (0–3 kPa, fórmula de Tetens),
  - Vento (0–10 m/s, opcional),
  - Chuva/POP (redutor, opcional).
- Retorna também:
  - **Faixa** (BAIXO/MÉDIO/ALTO),
  - **Recomendação**,
  - **Contribuição por fator** (UI com chips),
  - **VPD** (kPa).

> Se o modelo de clima não tiver vento/chuva/POP, o serviço funciona do mesmo jeito (campos opcionais tratados como `null`).

---

## Integração ManageEngine (DEMO)

Arquivo: `lib/services/manageengine_service.dart`

- Por padrão: **modo DEMO** (`ME_DEMO=1`).
- Ações disponíveis:
  - `enviarMetricaRisco(score)` → registra localmente (exibido em **Logs**),
  - `abrirTicket(titulo, descricao)` → simula criação de chamado.
- Para endpoints reais:
  - Rodar com `ME_DEMO=0` e definir `ME_BASE_URL` + `ME_API_KEY` via `--dart-define`.

---

## Pré-requisitos

- **Flutter** 3.x
- **Dart** 3.x
- Conta no **OpenWeather** (para obter **OWM_KEY**)
- Android/iOS SDK configurados

---

## Como rodar (dev)

1) Instale dependências:
```bash
flutter pub get
````

2. Rode com variáveis (sem expor chaves no código):

```bash
flutter run \
  --dart-define=OWM_KEY=SUA_CHAVE_OPENWEATHER \
  --dart-define=ME_DEMO=1
```

> Variáveis suportadas:
>
> * `OWM_KEY` (obrigatória)
> * `ME_DEMO` (`1`=demo, `0`=real)
> * `ME_BASE_URL` (se `ME_DEMO=0`)
> * `ME_API_KEY` (se `ME_DEMO=0`)

---

## Build (APK/IPA)

**Android (APK release)**:

```bash
flutter build apk \
  --release \
  --dart-define=OWM_KEY=SUA_CHAVE_OPENWEATHER \
  --dart-define=ME_DEMO=1
```

**iOS (archive)**:

```bash
flutter build ios \
  --release \
  --dart-define=OWM_KEY=SUA_CHAVE_OPENWEATHER \
  --dart-define=ME_DEMO=1
```

---

## Estrutura do projeto

```
lib/
  core/
    theme.dart
  models/
    clima_model.dart
  providers/
    clima_provider.dart
  services/
    api_service.dart
    location_service.dart
    manageengine_service.dart
    risk_service.dart
  views/
    login_screen.dart
    home_screen.dart
    mapa_screen.dart
    ia_screen.dart
    graficos_screen.dart
    suporte_screen.dart
    me_logs_screen.dart
    sobre_screen.dart
  main.dart
```

---

## Configurações importantes

**Localização**

* Android: `ACCESS_COARSE/FINE_LOCATION` no `AndroidManifest.xml`.
* iOS: `NSLocationWhenInUseUsageDescription` no `Info.plist`.

**Internet**

* Android: `android.permission.INTERNET` (geralmente já incluso).

**Segurança de credenciais**

* Nunca versionar chaves. Use **`--dart-define`** em `run`/`build`.

---

## Demonstração rápida (roteiro)

1. **Login** → Entrar.
2. **Home** → **Analisar** → clima + alerta → abre **Mapa**.
3. **IA & Alertas** → score, VPD, explicabilidade → **Registrar métrica** (DEMO) e **Abrir ticket** (se risco alto).
4. **Gráficos** → Temp/Umid/VPD (simulados a partir do clima atual).
5. **Suporte** → abrir ticket (DEMO) → ver **Logs ManageEngine**.
6. **Sobre** → versão, status de configs, links.

---

## Solução de problemas

* **401 ao buscar clima**

    * Verifique `OWM_KEY` no `--dart-define`.
    * Confirme que a chave está ativa no OpenWeather.
    * Garanta permissão de localização aprovada (coordenadas válidas).

* **Sem localização**

    * Aceite a permissão quando solicitado.
    * No emulador, configure uma localização válida.

* **Ticket desabilitado**

    * Habilita quando **score ≥ 75**. Para demo, ajuste temporariamente o threshold na `ia_screen.dart`.

* **Cores/tema**

    * O app usa Material 3 (`ColorScheme`). Mantenha o esquema coerente ao customizar.

---

## Licença

Uso **acadêmico** para o **FIAP Enterprise Challenge**.
Para abrir como open-source, sugere-se **MIT License**.

---

## Links

* **GitHub**: [https://github.com/ThiagoAlvesFeitosa/seca\_fiap](https://github.com/ThiagoAlvesFeitosa/seca_fiap)
* **Vídeo (YouTube)**: *(insira aqui o link do pitch)*

```
