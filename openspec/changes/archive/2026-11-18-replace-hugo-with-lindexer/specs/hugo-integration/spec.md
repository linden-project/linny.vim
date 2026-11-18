# hugo-integration Specification

## REMOVED Requirements

### Requirement: R key triggers index rebuild in views

**Reason**: The refresh rebuild is backend-agnostic now. Keeping it in the Hugo
capability would imply Hugo is the only way to rebuild the index.

**Migration**: The requirement moved to the indexer-integration capability as
`Menu refresh rebuilds through the selected backend`. The behaviour is unchanged
apart from reading `g:linny_index_hook_enabled` (with
`g:linny_hugo_hook_enabled` as a deprecated alias).
