# Changelog

All notable changes to this project are documented in this file.

The format is based on Keep a Changelog, and this project follows Semantic Versioning.

## [0.1.1] - 2026-03-22

### Added

- Added HexDocs guide set under `docs/guides/*` for getting started, configuration, public/private API usage, authentication, and error handling.
- Added middleware test coverage for second-based nonce behavior in private API signing.

### Changed

- Authentication middleware nonce generation now uses `System.os_time(:second)`.
- Updated README structure to align with HexDocs guide navigation and current install/version details.

## [0.1.0] - 2024-11-13

### Added

- Introduced consolidated `0.1.x` API surface for Gemini public/private REST access.

### Changed

- Historical `0.0.x` line promoted into the `0.1.0` baseline.

## [0.0.4] - 2024-11-08

### Added

- Added docs and CI improvements for ongoing API surface expansion.

## [0.0.3] - 2024-11-08

### Added

- Expanded private API coverage and implementation refinements.

## [0.0.2] - 2024-11-06

### Added

- Added early public/private API adapters and tests.

## [0.0.1] - 2024-11-06

### Added

- Initial release.
