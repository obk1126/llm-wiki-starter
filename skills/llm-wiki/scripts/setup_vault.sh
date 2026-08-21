#!/usr/bin/env bash
# setup_vault.sh — 카파시 LLM Wiki 패턴으로 새 옵시디언 볼트를 생성한다.
# 사용법: bash setup_vault.sh "<볼트경로>" ["<볼트이름>"]
# 예:     bash setup_vault.sh "$HOME/Documents/llm-wiki-vault" "LLM Wiki Brain"
set -euo pipefail

VAULT="${1:-$HOME/Documents/llm-wiki-vault}"
VAULT_NAME="${2:-LLM Wiki Brain}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$SKILL_DIR/templates"

if [ -e "$VAULT" ] && [ -n "$(ls -A "$VAULT" 2>/dev/null || true)" ]; then
  echo "❌ 대상 경로가 비어있지 않습니다: $VAULT"
  echo "   기존 볼트를 덮어쓰지 않습니다. 다른 경로를 지정하세요."
  exit 1
fi

echo "📁 볼트 생성: $VAULT  (이름: $VAULT_NAME)"
mkdir -p "$VAULT"/{Raw,Wiki/Index,Wiki/Log,Wiki/Concepts,Wiki/Entities,Synthesis,Output,Templates/webclipper,Templates/notes,graphify_out}
mkdir -p "$VAULT/.obsidian"

# --- 폴더별 CLAUDE.md (스키마) ---
cp "$TPL/folder_CLAUDE/raw.md"       "$VAULT/Raw/CLAUDE.md"
cp "$TPL/folder_CLAUDE/wiki.md"      "$VAULT/Wiki/CLAUDE.md"
cp "$TPL/folder_CLAUDE/synthesis.md" "$VAULT/Synthesis/CLAUDE.md"
cp "$TPL/folder_CLAUDE/output.md"    "$VAULT/Output/CLAUDE.md"

# --- 루트 CLAUDE.md + 핵심 맥락 노트 (인터뷰 전 placeholder 상태) ---
sed "s|{{VAULT_NAME}}|$VAULT_NAME|g" "$TPL/root_CLAUDE.md"  > "$VAULT/CLAUDE.md"
cp "$TPL/core_context.md" "$VAULT/_Core-Context.md"

# --- 노트 템플릿 ---
cp "$TPL/notes/"*.md "$VAULT/Templates/notes/" 2>/dev/null || true

# --- 웹 클리퍼 템플릿 (옵시디언 Web Clipper Import용 JSON) ---
cp "$TPL/webclipper/"*.json "$VAULT/Templates/webclipper/" 2>/dev/null || true

# --- 옵시디언이 볼트로 인식하도록 최소 설정 골격 ---
cat > "$VAULT/.obsidian/app.json" <<'JSON'
{
  "alwaysUpdateLinks": true,
  "newFileLocation": "folder",
  "newFileFolderPath": "Raw",
  "attachmentFolderPath": "Raw/attachments"
}
JSON
cat > "$VAULT/.obsidian/core-plugins.json" <<'JSON'
["file-explorer","global-search","switcher","graph","backlink","outgoing-link","tag-pane","page-preview","templates","note-composer","command-palette","outline","word-count","file-recovery"]
JSON

# --- README ---
cat > "$VAULT/README.md" <<MD
# $VAULT_NAME

카파시 LLM Wiki 패턴 기반 AI 세컨드 브레인 볼트.
\`/llm-wiki\` 스킬로 운영한다. (setup / ingest / query / lint / graphify)

- \`Raw/\` 원천 수집 → \`Wiki/\` AI 정리 → \`Synthesis/\` 시사점 → \`Output/\` 산출물
- 원칙: **Gold In, Gold Out** (목적 있는 수집).
MD

echo "✅ 완료. 생성된 구조:"
find "$VAULT" -maxdepth 2 -not -path '*/.obsidian/*' | sed "s|$VAULT|.|" | sort
echo ""
echo "다음 단계:"
echo "  1) 옵시디언 → Open folder as vault → $VAULT"
echo "  2) /llm-wiki setup 으로 핵심 맥락 인터뷰 진행 (CLAUDE.md / _Core-Context.md 완성)"
echo "  3) 옵시디언 Web Clipper 설정 → Import → Templates/webclipper/*.json"
