# startup-health-check Specification

## REMOVED Requirements

### Requirement: Hugo availability validation

**Reason**: Health no longer treats Hugo as a requirement; the check reports the
selected index backend instead, and a missing backend is a warning.

**Migration**: Use the `indexer` field from
`require('linny.health').validate()`. The `hugo` field is no longer set by the new
backend seam.

### Requirement: Checkhealth reports Hugo status

**Reason**: Checkhealth reports the active index backend rather than Hugo
specifically.

**Migration**: Read the `Indexer` section in `:checkhealth linny`.

### Requirement: Hugo check is non-blocking

**Reason**: The equivalent non-blocking guarantee is now stated for backend
detection in the indexer-integration capability.

**Migration**: None. A missing backend still does not fail the overall health
result.

### Requirement: Health check validates Hugo configuration

**Reason**: Hugo output format, publish directory and data directory settings only
matter when Hugo is the selected backend.

**Migration**: Hugo-specific configuration is validated only when Hugo is selected.
Notebook content directory and taxonomy checks remain part of health validation.

### Requirement: Checkhealth reports Hugo configuration status

**Reason**: The dedicated Hugo configuration section only applies to the Hugo
backend.

**Migration**: When Hugo is selected, the report keeps the existing
`Hugo Configuration` section. When `lindexer` is selected the section is omitted.
