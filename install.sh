#!/usr/bin/env bash
# LLM Wiki 스킬 설치 — skills/llm-wiki 를 ~/.claude/skills/ 로 복사한다.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/skills/llm-wiki"
DST="$HOME/.claude/skills/llm-wiki"

if [ ! -d "$SRC" ]; then
  echo "오류: $SRC 가 없습니다. 저장소 루트에서 실행하세요." >&2
  exit 1
fi

mkdir -p "$HOME/.claude/skills"

if [ -d "$DST" ]; then
  BACKUP="$DST.bak.$(date +%Y%m%d%H%M%S)"
  echo "기존 스킬 발견 → 백업: $BACKUP"
  mv "$DST" "$BACKUP"
fi

cp -R "$SRC" "$DST"
echo "설치 완료: $DST"
echo
echo "다음 단계 — Claude Code를 열고 입력하세요:"
echo "  /llm-wiki setup"
