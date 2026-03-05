# release-workflow Specification

## Purpose
TBD - created by archiving change release-script. Update Purpose after archive.
## Requirements
### Requirement: Interactive version bump selection

The release script SHALL prompt the user to select a version bump type.

#### Scenario: User selects major bump
- **WHEN** the current version is `0.8.0`
- **AND** user selects "major"
- **THEN** the new version SHALL be `1.0.0`

#### Scenario: User selects minor bump
- **WHEN** the current version is `0.8.0`
- **AND** user selects "minor"
- **THEN** the new version SHALL be `0.9.0`

#### Scenario: User selects patch bump
- **WHEN** the current version is `0.8.0`
- **AND** user selects "patch"
- **THEN** the new version SHALL be `0.8.1`

### Requirement: VERSION file update

The release script SHALL update the VERSION file with the new version.

#### Scenario: VERSION file is updated
- **WHEN** a version bump is selected
- **THEN** the VERSION file SHALL contain only the new version string

### Requirement: CHANGELOG header update

The release script SHALL update the CHANGELOG.md file during release.

#### Scenario: Next version header is replaced
- **WHEN** the release script runs
- **THEN** the `## Next version` header SHALL be replaced with `## X.Y.Z - DD mon YYYY`
- **AND** a new `## Next version` placeholder section SHALL be added at the top

### Requirement: Git tag creation

The release script SHALL create a git tag for the release.

#### Scenario: Tag is created with version prefix
- **WHEN** the release completes successfully
- **THEN** a git tag `vX.Y.Z` SHALL be created
- **AND** the tag SHALL point to the current commit

### Requirement: GitHub release creation

The release script SHALL create a GitHub release using the gh CLI.

#### Scenario: GitHub release is created
- **WHEN** the git tag is created
- **THEN** a GitHub release SHALL be created for tag `vX.Y.Z`
- **AND** the release body SHALL contain the changelog entries for this version

#### Scenario: gh CLI not installed
- **WHEN** the `gh` command is not available
- **THEN** the script SHALL exit with an error message
- **AND** no partial release artifacts SHALL be created

