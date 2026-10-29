# Tasks — contracts

gRPC-контракты трекера задач jedi-tasks. Контекст предметной области — в репо `ios` (`CONTEXT.md`).

## Состав

- `proto/<сущность>/<сущность>-endpoint.proto` — исходники, по пакету на сущность (как в Coin).
- Сгенерированный код здесь не хранится. По тегу `vX.Y.Z` CI (`.github/workflows/build.yml`) генерирует его и пушит
  с тем же тегом в [go-server-grpc](https://github.com/jedi-tasks/go-server-grpc)
  (импорт `github.com/jedi-tasks/go-server-grpc/proto`) и [swift-client-grpc](https://github.com/jedi-tasks/swift-client-grpc)
  (SPM-пакет `ProtoDefinitions`). CI нужен секрет `PAT_TOKEN` с правом записи в эти репозитории.
- `make build` — локальная генерация для проверки, в `go-server-grpc-local` и `swift-grpc-local` (в git не попадает).

## Правила контракта

- Идентификаторы — UUID в `bytes` (16 байт), генерирует клиент. Даты без времени — строка `yyyy-MM-dd`.
- Каждый запрос несёт `accessToken`, каждый ответ — `optional error.Error error`.
- Клиент работает офлайн: мутации копятся в очереди и уходят обычными Create/Update/Delete.
- Каждая мутация несёт `updatedAt` — время действия на клиенте. Сервер применяет её, только если она
  новее того, что хранится (последняя запись строки побеждает).
- Удаление мягкое. В `Sync` удалённое приходит списками `deleted…IDs`.
- `Update…` меняет только переданные поля. Поле, которое может быть пустым, сбрасывается пустым значением:
  пустые `bytes` — нет раздела или приоритета, пустая строка — нет даты, `0` — нет оценки длительности.
- Изменения скачиваются через `SyncEndpoint` по аудит-логу (`Sync` → `ConfirmSync`),
  `SubscribeToSync` сигналит о новых изменениях, пока приложение открыто.
