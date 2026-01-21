set dotenv-load := false
set ignore-comments := true

[private]
default:
  @just --list

ansible-lint flavor:
  ansible-lint {{ flavor }}/{{ flavor }}.yml

prettier:
  find . -name '*.yaml' -o -name '*.yml' | xargs prettier -w
  find . -name '*.md' | xargs prettier -w
