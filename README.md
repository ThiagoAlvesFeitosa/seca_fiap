# Enterprise Challange 2
```markdown
# RuraLTime

Aplicativo móvel (Flutter) para monitoramento do risco de seca a partir de dados meteorológicos georreferenciados, com cálculo de um indicador explicável e integração operacional em modo demonstrativo.

## Visão geral
O RuraLTime consulta condições climáticas locais, estima um **score de risco (0–100)** com base em temperatura, umidade e VPD (déficit de pressão de vapor) e oferece fluxos de ação (registro de métricas e abertura de chamado) em integração **ManageEngine** em **modo DEMO**. O projeto adota boas práticas de segurança, utilizando variáveis de ambiente (`--dart-define`) para credenciais.

## Funcionalidades
- **Análise local**: geolocalização + consulta ao OpenWeather; apresentação de resumo e mapa.
- **IA & Alertas**: score explicável (0–100), VPD (kPa) e contribuição por fator; registro de métrica e abertura de ticket (DEMO).
- **Gráficos**: temperatura, umidade e VPD. Na ausência de séries históricas, gera-se uma tendência simulada derivada do estado atual.
- **Suporte**: abertura de ticket (DEMO) e visualização de logs.
- **Sobre**: versão do app, status de configuração e links úteis.

## Arquitetura (alto nível)
```

Flutter (Material 3)
├─ Services
│   ├─ LocationService         → geolocalização
│   ├─ ApiService (OpenWeather)→ clima por lat/lon
│   ├─ RiskService (IA)        → score, VPD, explicabilidade
│   └─ ManageEngineService     → métricas/tickets (DEMO)
├─ Provider
│   └─ ClimaProvider           → estado do clima na UI
└─ Views
Login, Home, Mapa, IA & Alertas, Gráficos, Suporte, Logs (DEMO), Sobre

````

## Execução (desenvolvimento)
```bash
flutter pub get
flutter run \
  --dart-define=OWM_KEY=SUA_CHAVE_OPENWEATHER \
  --dart-define=ME_DEMO=1
````

### Parâmetros (`--dart-define`)

* `OWM_KEY` (obrigatório)
* `ME_DEMO` = `1` (padrão, integração demonstrativa) ou `0` (prepara uso real)
* `ME_BASE_URL`, `ME_API_KEY` (necessários apenas se `ME_DEMO=0`)

## Build (opcional)

Android (APK):

```bash
flutter build apk --release \
  --dart-define=OWM_KEY=SUA_CHAVE_OPENWEATHER \
  --dart-define=ME_DEMO=1
```

## Configuração

* **Permissões de localização**

  * Android: `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` em `AndroidManifest.xml`
  * iOS: `NSLocationWhenInUseUsageDescription` em `Info.plist`
* **Internet**: garantir permissão (`INTERNET`) no Android quando aplicável
* **Credenciais**: não versionar chaves; usar `--dart-define`

## Estrutura do projeto

```
lib/
  core/theme.dart
  models/clima_model.dart
  providers/clima_provider.dart
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

## Metodologia de risco (resumo)

* **Indicadores**: temperatura (°C), umidade relativa (%) e **VPD** (kPa, via fórmula de Tetens).
* **Score**: combinação normalizada e ponderada dos indicadores; apresenta **faixa** (baixo/médio/alto) e **explicabilidade** (contribuição por fator).
* **Gráficos**: quando não há séries, gera-se tendência simulada (5 dias) consistente com o estado atual (↑ temperatura → ↓ umidade; VPD acompanha o estresse hídrico).

## Integração operacional (ManageEngine)

* **Modo DEMO**: registro de métricas e tickets em armazenamento local para demonstração do fluxo.
* **Futuro uso real**: executar com `ME_DEMO=0` e configurar `ME_BASE_URL`/`ME_API_KEY` via `--dart-define`.

## Licença

Uso acadêmico no contexto do FIAP Enterprise Challenge.

## Links

* Repositório: [https://github.com/ThiagoAlvesFeitosa/seca\_fiap](https://github.com/ThiagoAlvesFeitosa/seca_fiap)
* Vídeo (YouTube): *inserir link do pitch*

```

```
