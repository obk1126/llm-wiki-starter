# CLAUDE.md — {{VAULT_NAME}} (LLM Wiki 루트 스키마)

이 볼트는 안드레 카파시의 **LLM Wiki** 패턴 기반 AI 세컨드 브레인이다.
Claude Code는 이 파일을 읽고 "내가 누구를 위해, 어떤 목적으로 지식을 관리하는지"를 이해한 뒤 작업한다.

## 나의 핵심 맥락
> 상세 버전은 `_Core-Context.md` 참고. 인터뷰로 채워진다.

- **나는 누구인가**: {{WHO_AM_I}}
- **왜 기록하는가**: {{WHY_RECORD}}
- **어떤 아웃풋**: {{OUTPUT_GOAL}}
- **주요 오디언스/채널**: {{AUDIENCE}}

## 최우선 원칙 — Gold In, Gold Out
- 목적 없는 수집은 쓰레기 데이터. **"왜 수집했는가"를 설명할 수 있는** 골드 데이터만 위키로 승격한다.
- 인제스트 시 사용자에게 **수집 목적과 관점**을 먼저 질문한다.

## 작업 규칙 (Operating Rules)
1. 모든 정리는 무작위가 아니라 **각 폴더 `CLAUDE.md`의 스키마**를 따른다.
2. Raw → Wiki 승격 시 개념(Concept)과 개체(Entity)를 분리하고 `[[위키링크]]`로 연결한다.
3. 노트는 항상 frontmatter(`type`, `source`, `created`, `tags`, `purpose`)를 갖는다.
4. AI가 만든 정리 결과는 "재료"이며 **사용자의 진짜 글과 구분**한다.
5. 시사점(Synthesis) 저장은 사용자 동의 후에만 한다.
6. 파괴적 작업(대량 삭제/이동)은 먼저 요약 보고하고 승인받는다.

## 폴더 역할
| 폴더 | 역할 | 스키마 |
|------|------|--------|
| `Raw/` | 원천 수집물(웹클리퍼 저장) | `Raw/CLAUDE.md` |
| `Wiki/` | AI가 정리한 지식(Index/Log/Concepts/Entities) | `Wiki/CLAUDE.md` |
| `Synthesis/` | 질문·연결로 도출한 시사점 보고서 | `Synthesis/CLAUDE.md` |
| `Output/` | 외부로 내보낼 산출물 | `Output/CLAUDE.md` |
| `graphify_out/` | Graphify 지식 그래프(graph.json/html/report) | — |

## 운영 명령 (Claude Code 스킬)
- `/llm-wiki ingest` — Raw 소스 소화 → Wiki 반영
- `/llm-wiki query <질문>` — 위키 근거 답변
- `/llm-wiki lint` — 위키 최신화/정리
- `/llm-wiki graphify` — 지식 그래프 구축
