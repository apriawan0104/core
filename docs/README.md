# BUMA Core Documentation

Package-level guides live here. Module API references stay next to code under `lib/src/**/doc/`.

## Package guides

| Document | Description |
|----------|-------------|
| [architecture.md](architecture.md) | Clean architecture, layers, principles |
| [migration.md](migration.md) | Package migration and breaking changes |
| [repository-error-handler.md](repository-error-handler.md) | Centralized repository error handling |
| [bearer-token-setup.md](bearer-token-setup.md) | Bearer token authentication setup |

## App integration (setup)

| Document | Description |
|----------|-------------|
| [setup/background-service.md](setup/background-service.md) | Background tasks |
| [setup/network.md](setup/network.md) | HTTP client / networking |
| [setup/logging.md](setup/logging.md) | Logging |
| [setup/storage.md](setup/storage.md) | Local storage |
| [setup/secure-storage.md](setup/secure-storage.md) | Secure storage |
| [setup/url-launcher.md](setup/url-launcher.md) | URLs, email, phone, SMS |
| [setup/connectivity.md](setup/connectivity.md) | Connectivity |
| [setup/path-provider.md](setup/path-provider.md) | Paths and directories |
| [setup/file-opener.md](setup/file-opener.md) | Open files with system apps |

## In-repo module docs

- [Error reporting setup](../lib/src/infrastructure/analytics/doc/ERROR_REPORTING_SETUP.md)
- [Use cases](../lib/src/foundation/domain/usecases/README.md)

Release history: [CHANGELOG.md](../CHANGELOG.md) at package root.