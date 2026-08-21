#!/usr/bin/env bash
# LLM Wiki 스킬 설치 — skills/ 하위 전체를 ~/.claude/skills/ 로 복사한다.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.claude/skills"

for SRC in "$ROOT"/skills/*/; do
  NAME="$(basename "$SRC")"
  DST="$HOME/.claude/skills/$NAME"
  if [ -d "$DST" ]; then
    BACKUP="$DST.bak.$(date +%Y%m%d%H%M%S)"
    echo "기존 스킬 발견($NAME) → 백업: $BACKUP"
    mv "$DST" "$BACKUP"
  fi
  cp -R "$SRC" "$DST"
  echo "설치: $DST"
done

echo
echo "다음 단계 — Claude Code를 열고 입력하세요:"
echo "  /llm-wiki setup"
