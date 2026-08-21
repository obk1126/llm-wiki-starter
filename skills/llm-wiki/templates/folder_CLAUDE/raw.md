# CLAUDE.md — Raw/ (원천 수집물)

이 폴더는 **목적을 가지고 수집한 원천 데이터**가 들어오는 곳이다. (논문/아티클/영상/팟캐스트/책/이미지)
주로 옵시디언 **웹 클리퍼**가 `Templates/webclipper/*.json` 템플릿으로 여기에 저장한다.

## 규칙 (스키마)
- 한 소스 = 한 노트. 원문은 절대 가공하지 않고 보존한다 (정리는 Wiki에서 한다).
- 파일명: `YYYY-MM-DD - <소스 제목>.md`.
- 필수 frontmatter:
  ```yaml
  ---
  type: article | youtube | podcast | book | research
  source: <원문 URL 또는 출처>
  author: <저자/채널>
  created: <수집일>
  status: inbox        # inbox → ingested
  purpose: <왜 수집했는가 — Gold In의 핵심>
  tags: []
  ---
  ```
- `purpose`가 비어 있으면 인제스트 전에 사용자에게 **수집 목적**을 먼저 묻는다.
- 인제스트가 끝난 소스는 frontmatter `status: ingested`로 바꾸고, 생성된 Wiki 노트를 `related:`에 링크한다.

## 인제스트 입력
`/llm-wiki ingest`는 `status: inbox`인 노트만 대상으로 한다.
