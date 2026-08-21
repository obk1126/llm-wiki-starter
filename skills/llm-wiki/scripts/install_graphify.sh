#!/usr/bin/env bash
# install_graphify.sh — (선택) 지식 그래프용 graphify 설치 + 검증
# 사용법: bash install_graphify.sh [--yes]
#   --yes : 확인 프롬프트 없이 설치
set -uo pipefail

AUTO=0
[ "${1:-}" = "--yes" ] && AUTO=1

echo "🕸  graphify (지식 그래프) 설치 — 선택 사항"
echo "------------------------------------"

# 1) python3/pip3 확인
if ! command -v python3 >/dev/null 2>&1 || ! command -v pip3 >/dev/null 2>&1; then
  echo "❌ python3/pip3 가 없습니다. graphify는 건너뜁니다."
  echo "   (graphify 없이도 ingest/query/lint 는 완전히 동작합니다.)"
  exit 0
fi

# 2) 이미 설치?  (CLI 명령은 graphify, PyPI 패키지는 graphifyy)
if command -v graphify >/dev/null 2>&1 || pip3 show graphifyy >/dev/null 2>&1; then
  echo "✅ 이미 설치됨: graphify CLI = $(command -v graphify 2>/dev/null || echo '(경로 확인 필요)')"
  exit 0
fi

# 3) 고지 + 동의
echo "ℹ️  graphify = 카파시 LLM Wiki 아이디어를 구현한 오픈소스 도구 (GitHub: safishamsi/graphify)."
echo "    ⚠️ PyPI 패키지명은 'graphifyy' (y 두 개) 입니다. 'graphify'(y 하나)는 무관한 패키지이니 주의."
echo "    Wiki/코드 폴더를 지식 그래프(graph.json/html, GRAPH_REPORT.md)로 만들어 줍니다."
echo "    설치 없이도 ingest/query/lint 는 완전히 동작합니다 (그래프는 선택 기능)."
if [ "$AUTO" -ne 1 ]; then
  read -r -p "지금 'pip3 install graphifyy && graphify install' 진행할까요? [y/N] " ans
  case "${ans:-N}" in
    y|Y) ;;
    *) echo "건너뜀. 나중에: bash $(basename "$0")  또는  /llm-wiki graphify"; exit 0 ;;
  esac
fi

# 4) 설치 (uv 있으면 우선, 없으면 pip)
echo "📦 설치 중..."
INSTALLED=0
if command -v uv >/dev/null 2>&1; then
  uv tool install graphifyy && INSTALLED=1
fi
if [ "$INSTALLED" -ne 1 ]; then
  pip3 install --user graphifyy && INSTALLED=1
fi

if [ "$INSTALLED" -eq 1 ]; then
  echo "--- 후속 셋업: graphify install ---"
  graphify install 2>&1 | tail -10 || echo "ℹ️  'graphify install' 출력 확인 필요."
  echo "--- 설치 검증 ---"
  command -v graphify >/dev/null 2>&1 && echo "✅ CLI 'graphify' 사용 가능: $(command -v graphify)" \
    || echo "ℹ️  graphify CLI가 PATH에 없으면, pip --user bin 경로(예: ~/Library/Python/3.x/bin)를 PATH에 추가하세요."
  echo ""
  echo "다음: /llm-wiki graphify  → graphify-out/ 에 graph.json/html + GRAPH_REPORT.md 생성"
else
  echo "❌ 설치 실패. graphify 없이도 ingest/query/lint 는 정상 동작합니다."
  exit 0
fi
