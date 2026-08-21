---
name: llm-wiki
description: 안드레 카파시의 LLM Wiki 패턴으로 옵시디언 기반 AI 세컨드 브레인을 셋업·운영한다. 새 볼트 셋업, Raw 소스 인제스트, 위키 기반 쿼리(Graph/Wiki RAG), 위키 린트/최신화, Graphify 지식 그래프 구축을 담당한다. "LLM 위키", "세컨드 브레인", "옵시디언 볼트 셋업", "지식 인제스트", "llm-wiki", "ingest", "위키 쿼리" 요청 시 사용.
---

# LLM Wiki — 나만의 AI 세컨드 브레인

옵시디언(지식 베이스) × Claude Code(AI 컴파일러) × LLM Wiki 패턴(스키마) × Graphify(지식 그래프)
조합으로 **목적 있는 지식 수집 → AI 소화 → 복리 축적**을 구현한다. (출처: 카파시 LLM Wiki, 2025-04-03)

## 핵심 원칙 — Gold In, Gold Out
- 무지성 수집은 쓰레기 데이터(Garbage In, Garbage Out). **"왜 수집했는가"를 설명할 수 있는** 목적 있는 수집만이 골드 데이터가 된다.
- 그래서 모든 인제스트 단계에서 AI는 사용자에게 **"이 소스를 왜 모았고, 어떤 관점을 넣을지"** 를 먼저 묻는다.
- 모든 정리는 무작위가 아니라 **스키마(규칙/기준/목적)** 를 따른다. 스키마는 각 폴더의 `CLAUDE.md`와 루트 `CLAUDE.md`에 담긴다.

## 모드 (인자로 분기)
`/llm-wiki <mode> [args]` 형태로 호출한다.

> **인자 없이 호출된 경우 (중요):** 볼트를 스캔하거나 파일을 읽어 의도를 추론하지 **말 것**(토큰 낭비 금지). 그 대신 아래 모드 표를 **그대로 한 번 보여주고**, "무엇을 하시겠어요? (`/llm-wiki <mode> [args]`)"라고 **먼저 물어본다.** 사용자가 모드를 답하기 전에는 어떤 컨텍스트도 읽지 않는다.

| mode | 하는 일 |
|------|---------|
| `setup` | 새 옵시디언 볼트를 LLM Wiki 구조로 생성하고 인터뷰로 핵심 맥락을 채운다 + 웹 클리퍼 연결 |
| `normalize` | 웹 클리퍼가 엉뚱한 폴더(Clippings 등)에 저장한 노트를 Raw로 옮기고 스키마에 맞게 보정 |
| `ingest [경로]` | (자동 normalize 후) Raw 소스를 읽고 → 목적 인터뷰 → Wiki에 개념/개체로 정리 |
| `query <질문>` | 위키 문서를 근거로 질문에 답한다 (벡터 DB 없는 RAG). Graphify가 있으면 그래프 근거 활용 |
| `lint` | 위키 전체를 점검·최신화한다. 깨진 링크/중복/오래된 인덱스 정리 |
| `graphify` | Wiki를 Graphify로 지식 그래프(graph.json/html/report)로 변환 |

---

## MODE: setup — 새 볼트 셋업 (다른 사람도 이걸로 셋팅)

1. 볼트 위치를 사용자에게 확인한다 (기본: `~/Documents/llm-wiki-vault`).
2. 셋업 스크립트를 실행해 폴더 구조 + 폴더별 CLAUDE.md + 웹클리퍼 템플릿 + `.obsidian` 골격을 생성한다:
   ```bash
   bash ~/.claude/skills/llm-wiki/scripts/setup_vault.sh "<볼트경로>" "<볼트이름>"
   ```
3. **핵심 맥락 인터뷰** — 다음 3문항을 사용자에게 묻는다 (`reference/workflow.md`의 인터뷰 가이드 참고):
   - **나는 누구인가?** (역할/일/핵심 가치/강점)
   - **왜 기록하고 싶은가?** (가장 안 되는 것, 비전)
   - **어떤 아웃풋을 만들고 싶은가?** (주요 오디언스, 채널)
4. 답변을 바탕으로 `<볼트>/_Core-Context.md`(나의 핵심 맥락 노트)와 루트 `<볼트>/CLAUDE.md`를 완성한다.
   - 템플릿: `templates/core_context.md`, `templates/root_CLAUDE.md`. `{{PLACEHOLDER}}`를 인터뷰 답변으로 치환.
5. **옵시디언 웹 클리퍼 연결** (필수 — 순서 중요. 안 하면 클리핑이 `Clippings/`로 샘):
   - 웹 클리퍼는 **템플릿이 1개뿐이면 그 기본 템플릿을 삭제할 수 없다.** 그래서 순서가 중요하다:
     1. 웹 클리퍼 아이콘 우클릭 → Settings → **Templates → Import** → 먼저 **`Default.json`** 가져오기 (이제 템플릿이 2개 → 기본 템플릿 삭제 가능).
     2. 기존 **"기본 템플릿"** 선택 → **삭제**.
     3. 나머지 4종(`YouTube`/`Podcast`/`Book`/`Research`) Import.
     4. **`LLM Wiki Default`** 를 목록 맨 위로 올린다 (트리거 안 걸린 일반 페이지의 기본이 됨).
   - 우리 템플릿은 모두 저장 위치가 `Raw/`. 일반 글=Default, YouTube/Podcast/Research 등은 트리거로 자동 선택.
6. **(선택) graphify 설치** — 지식 그래프를 쓸 거면 셋업 단계에서 함께 설치한다(미검증 고지 + 동의 후):
   ```bash
   bash ~/.claude/skills/llm-wiki/scripts/install_graphify.sh
   ```
7. 완료 후 "이제 `/llm-wiki ingest`로 첫 소스를 소화할 수 있다"고 안내한다.
   - 혹시 이미 `Clippings/` 등에 저장된 게 있으면 `/llm-wiki normalize`로 한 번에 정리하라고 안내한다.

> 다른 사람이 셋팅할 때도 위 절차가 그대로 재현된다 — 스크립트가 구조를, 인터뷰가 개인 맥락을 채운다.

---

## MODE: normalize — 오저장 클리핑 정리 (Raw 규칙으로 흡수)

옵시디언 웹 클리퍼 기본 템플릿은 `Clippings/`에 저장하고 frontmatter도 LLM Wiki 스키마와 다르다.
이 모드는 그런 노트를 **자동으로 Raw 규칙에 맞게 정규화**한다 (결정적·멱등):

```bash
python3 ~/.claude/skills/llm-wiki/scripts/normalize_raw.py "<볼트경로>"
```
- 후보 폴더(`Clippings`/`Clipped`/`Web Clips`/`Inbox`)의 `.md`를 `Raw/`로 이동.
- frontmatter에 `type`/`created`/`status: inbox`/`purpose`/`tags` 보강, `clippings` 태그 → `raw/<type>`.
- 파일명에 `YYYY-MM-DD - ` prefix 추가. 빈 후보 폴더 제거.

정규화 후, `purpose`가 빈 노트는 `ingest`에서 수집 목적을 물어 채운다.

---

## MODE: ingest — 소스 소화

`reference/workflow.md`의 인제스트 프로토콜을 따른다. 요약:
0. **먼저 정규화**: `python3 ~/.claude/skills/llm-wiki/scripts/normalize_raw.py "<볼트>"` 를 실행해 엉뚱한 폴더에 저장된 클리핑을 Raw로 흡수한다.
1. 대상 소스를 읽는다 (Raw 폴더 신규 파일 또는 사용자가 지정한 경로/URL).
2. **목적 인터뷰**: "이걸 왜 수집했나? 어떤 관점/연결을 원하나?" 를 먼저 묻는다 (Gold In 보장).
3. 소스에서 개념(Concept)과 개체(Entity)를 분리하고, 기존 Wiki 노트와 `[[링크]]`로 연결한다.
4. `Wiki/Concepts/`·`Wiki/Entities/`에 노트를 생성/업데이트하고 `Wiki/Index/`·`Wiki/Log/`를 갱신한다.
5. 원천은 `Raw/`에 남기고, 정리 결과는 사용자의 진짜 글과 구분된 "재료"임을 명시한다.
6. 시사점이 나오면 사용자에게 "Synthesis 저장할까요?"를 묻고 동의 시 `Synthesis/`에 보고서 형태로 저장한다.

각 폴더의 `CLAUDE.md`에 적힌 스키마(파일명 규칙, frontmatter, 분류 기준)를 반드시 준수한다.

---

## MODE: query — 위키 기반 답변

1. 질문과 관련된 `Wiki/`·`Synthesis/` 노트를 검색한다 (키워드 + 링크 그래프 따라가기).
2. Graphify 산출물(`graphify_out/graph.json`)이 있으면 노드/엣지 근거를 함께 활용한다.
3. **근거 노트를 인용**하며 답한다. 벡터 DB가 아니라 위키 문서를 근거로 하는 RAG임을 기억한다.
4. 위키에 답이 없으면 "위키에 근거 없음"을 분명히 밝히고, 인제스트를 제안한다.

---

## MODE: lint — 위키 정리/최신화

`reference/workflow.md`의 린트 체크리스트를 따른다: 깨진 `[[링크]]`, 고아 노트, 중복 개념 병합, 오래된 인덱스/목차 재생성, frontmatter 누락 보정. 변경은 사용자에게 요약 보고 후 적용한다.

---

## MODE: graphify — 지식 그래프 (graphify 스킬에 위임)

graphify는 카파시 LLM Wiki를 구현한 오픈소스 도구(PyPI: **`graphifyy`**, CLI/스킬: `graphify`)이며, **자체 `/graphify` 스킬**을 갖는다. 우리는 중복 구현하지 않고 여기에 위임한다.

1. 사전 점검·설치: `bash ~/.claude/skills/llm-wiki/scripts/install_graphify.sh` (미설치면 고지+동의 후 설치). `graphify install`이 `/graphify` 스킬을 등록한다.
2. 볼트(또는 `Wiki/`)를 대상으로 graphify 스킬을 실행한다:
   - `/graphify <볼트경로>` — 전체 파이프라인(추출→커뮤니티 탐지→시각화).
   - 옵션: `--update`(증분), `--no-viz`(JSON/리포트만), `--wiki`(index.md+커뮤니티별 글).
3. 산출물은 **현재 작업 디렉토리의 `graphify-out/`** 에 생성된다: `graph.json`(GraphRAG), `graph.html`(시각화), `GRAPH_REPORT.md`(영문 분석).
4. 이후 질문은 `/graphify query "<질문>"` 으로 그래프 근거 답변(BFS/DFS). `graphify-out/`이 있으면 `query` 모드도 이를 우선 활용한다.

> 참고: graphify는 Obsidian/Wiki 산출도 직접 지원(`--obsidian`, `--wiki`)하므로, LLM Wiki 볼트와 자연스럽게 결합된다.

---

## 볼트 구조 (참고)
```
<볼트>/
  CLAUDE.md            # 나의 핵심 맥락 + 작업 규칙 + 전역 스키마
  _Core-Context.md     # 나는 누구/왜 기록/어떤 아웃풋 (인터뷰 결과)
  Raw/        + CLAUDE.md   # 원천 수집물 (웹클리퍼 저장 위치)
  Wiki/       + CLAUDE.md   # 정리된 지식: Index/ Log/ Concepts/ Entities/
  Synthesis/  + CLAUDE.md   # 질문/연결로 도출한 시사점 보고서
  Output/     + CLAUDE.md   # 산출물 (영상 스크립트/카드뉴스/글 등)
  Templates/webclipper/*.json  # 옵시디언 웹 클리퍼 템플릿
  graphify_out/                # Graphify 결과 (선택)
```

자세한 패턴 설명은 `reference/llm-wiki-pattern.md`, 운영 프로토콜은 `reference/workflow.md` 참고.
