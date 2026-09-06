# Loom

Read sources and connect highlighted passages into linked concepts.

The shared Postgres is documented in [schema.md](schema.md) (readable) and [schema.sql](schema.sql) (the DDL). Both apps use that database; do not recreate it.

## Language

**Passage**:
A highlighted excerpt from a source's text or image.
_Avoid_: Highlight, snippet, quote

**Concept**:
A grouping of passages. Concepts can be linked to other concepts.
_Avoid_: Tag, topic, node, cluster
