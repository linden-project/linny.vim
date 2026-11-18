# hugo-watch-process Specification

## REMOVED Requirements

### Requirement: Start watch process

**Reason**: Watch now runs through the indexer backend seam, which uses
`lindexer watch` and does not depend on Hugo.

**Migration**: Use `g:linny_index_watch_enabled` and `:LinnyIndexWatch`. See the
indexer-watch capability.

### Requirement: Stop watch process

**Reason**: Watch lifecycle is owned by the indexer backend seam.

**Migration**: Use `:LinnyIndexStop`; `:LinnyHugoStop` remains as an alias.

### Requirement: Query watch status

**Reason**: Watch status is reported by the indexer backend seam and no longer
describes a Hugo process.

**Migration**: Use `require('linny.indexer').is_watching()`. Callers of
`require('linny.hugo').is_watching()` keep working while the Hugo backend exists.

### Requirement: Watch process cleanup on exit

**Reason**: Cleanup now applies to whichever backend is running watch.

**Migration**: None. The indexer-watch capability guarantees cleanup on
`VimLeavePre`.

### Requirement: Watch status display in menu

**Reason**: The footer no longer names Hugo because Hugo is optional.

**Migration**: The footer now shows `[Index: watching]` and `[Index: stopped]`.

### Requirement: Auto-start watch on menu open

**Reason**: Autostart is driven by the indexer configuration, not by a Hugo
specific option.

**Migration**: Set `g:linny_index_watch_enabled = 1`. The old
`g:linny_hugo_watch_enabled` is read as a deprecated alias when the new option is
unset.

### Requirement: Manual watch commands

**Reason**: The commands are backend-agnostic and named after the index rather
than Hugo.

**Migration**: Use `:LinnyIndexWatch` and `:LinnyIndexStop`.
`:LinnyHugoWatch` and `:LinnyHugoStop` remain as aliases.
