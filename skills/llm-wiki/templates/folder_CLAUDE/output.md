# CLAUDE.md — Output/ (산출물)

Wiki/Synthesis의 골드 데이터를 바탕으로 **외부로 내보낼 결과물**을 만드는 곳.
(`_Core-Context.md`의 "어떤 아웃풋" 목표에 맞춤 — 예: 유튜브 롱폼 스크립트, 인스타 카드뉴스, 쇼츠 대본, 스레드/링크드인 글)

## 규칙 (스키마)
- 파일명: `YYYY-MM-DD - <채널> - <제목>.md`.
- 필수 frontmatter:
  ```yaml
  ---
  type: output
  channel: youtube | instagram | thread | linkedin | docx | ppt | etc
  status: draft | review | published
  sources: []          # 근거 Wiki/Synthesis 노트 [[링크]]
  created: <날짜>
  tags: []
  ---
  ```
- 산출물은 반드시 **근거 노트를 추적 가능**하게 `sources:`에 남긴다 (Gold Out 검증).
- 사용자의 톤/오디언스(`_Core-Context.md`)에 맞춰 작성한다.
