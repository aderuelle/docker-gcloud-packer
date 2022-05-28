# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2022-05-28

### Changed

- Update Packer version to 1.8.1
- Dockerfile: fixes for Hadolint reports
- Add Hadolint and Anchore scan actions
- README.md: add CI status badges

## [v0.1.0] - 2022-05-27

### Changed

- Update CI to include tag name of pushed image using [docker/metadata-action@v4]

## [v0.0] - 2022-05-27

### Changed

- Added CHANGELOG.md
- Added GitHub Action: build & push to ghcr.io
- Refactor by using variables for most things
- Forked from https://github.com/arquivei/docker-gcloud-packer

[docker/metadata-action@v4]: https://github.com/marketplace/actions/docker-metadata-action
[Unreleased]: https://github.com/aderuelle/docker-gcloud-packer/compare/v0.1...HEAD
[v0.1]: https://github.com/aderuelle/docker-gcloud-packer/compare/v0.0...v0.1
[v0.0]: https://github.com/aderuelle/docker-gcloud-packer/compare/5062e22d...v0.0
