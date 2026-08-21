# LLM Wiki Starter — 나만의 AI 세컨드 브레인 셋업 킷

대화는 휘발되고, 위키는 축적된다.
이 킷은 **옵시디언(지식 베이스) × Claude Code(AI 컴파일러) × LLM Wiki 패턴(스키마)** 조합으로
"목적 있는 수집 → AI 소화 → 복리 축적" 구조를 30분 안에 세팅하게 해준다.

> 여기에는 **스킬(도구)만** 들어 있다. 지식 내용물은 없다 — 그건 각자 자기 것으로 채우는 것.

## 필요한 것

- [Claude Code](https://claude.com/claude-code) (CLI 또는 데스크탑 앱)
- [Obsidian](https://obsidian.md) (무료)
- 선택: Obsidian Web Clipper 브라우저 확장 (웹 글을 볼트로 저장할 때)

## 설치 (2분)

```bash
git clone <이 저장소 URL>
cd llm-wiki-starter
bash install.sh
```

`install.sh`는 `skills/llm-wiki/`를 `~/.claude/skills/`에 복사한다. 그게 전부다.

## 시작 (30분)

Claude Code를 열고:

```
/llm-wiki setup
```

이 한 줄이 나머지를 안내한다:

1. **볼트 생성** — 폴더 구조 + 폴더별 스키마(CLAUDE.md)가 자동으로 만들어진다
   ```
   내볼트/
     CLAUDE.md          # 핵심 맥락 + 작업 규칙
     _Core-Context.md   # 나는 누구 / 왜 기록 / 어떤 아웃풋 (인터뷰로 채움)
     Raw/               # 원료 — 일단 던져 넣는 곳
     Wiki/              # 지식 — AI가 소화한 정식 문서 (개념/개체)
     Synthesis/         # 통찰 — 질문이 만든 시사점
     Output/            # 산출물 — 밖으로 나가는 결과물
   ```
2. **핵심 맥락 인터뷰** — "나는 누구인가 / 왜 기록하는가 / 어떤 아웃풋을 원하는가" 3문항.
   이 답이 이후 모든 정리의 기준이 된다.
3. **웹 클리퍼 연결** (선택) — 템플릿 5종이 함께 설치된다. 웹에서 본 글이 곧장 `Raw/`로 떨어진다.

## 매일 쓰는 명령

| 명령 | 하는 일 |
|------|---------|
| `/llm-wiki ingest` | Raw에 던져둔 원료를 읽고 → 수집 목적을 묻고 → Wiki에 개념/개체로 정리 |
| `/llm-wiki query <질문>` | 위키 문서를 근거로 답한다 — 일반론이 아니라 내 맥락으로 |
| `/llm-wiki lint` | 깨진 링크·중복·오래된 색인 정리 |
| `/llm-wiki graphify` | 위키를 지식 그래프(시각화)로 변환 (선택 설치) |

## 원칙 하나 — Gold In, Gold Out

**"왜 수집했는지 설명할 수 있는 것"만 위키에 넣는다.**
목적 없는 스크랩은 쌓일수록 검색을 방해하는 쓰레기 데이터가 된다.
그래서 인제스트할 때마다 AI가 먼저 묻는다 — "이걸 왜 모았나요?"

## 첫 골드 추천

세팅 직후 넣을 첫 원료로 이것을 추천한다:

- 최근에 AI에게 보낸 **잘 먹힌 프롬프트** 1개 (다음 과제의 출발점이 된다)
- 자기 업무의 **반복 설명 거리** 1개 — 보고서 양식, 견적 기준, 자기소개 등
  (같은 설명을 두 번 하고 있다면, 그건 지식이 아니라 노동이다)

## 구조가 본체, 도구는 껍데기

옵시디언+클로드가 기본 조합이지만 필수는 아니다.
Raw → Wiki → Synthesis → Output 구조와 Gold In 원칙만 지키면
노션+GPT든 뭐든 같은 효과를 낸다.

---

패턴 출처: Andrej Karpathy의 LLM Wiki 아이디어를 실무용으로 구현한 것.
자세한 개념은 `skills/llm-wiki/reference/llm-wiki-pattern.md` 참고.
