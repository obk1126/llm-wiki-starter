#!/usr/bin/env python3
"""normalize_raw.py — 옵시디언 웹 클리퍼가 LLM Wiki 규칙과 다르게 저장한 노트를 정규화한다.

하는 일 (멱등):
  1) Raw 밖 후보 폴더(Clippings/Clipped/Web Clips/Inbox)의 .md 를 Raw/ 로 이동
  2) frontmatter에 LLM Wiki 필수 키(type/created/status/purpose/tags)를 보강
  3) tags 의 'clippings' → 'raw/<type>'
  4) 파일명에 'YYYY-MM-DD - ' prefix 가 없으면 created 기준으로 추가
  5) 비게 된 후보 폴더 제거
이미 규칙에 맞는 파일은 건드리지 않는다. 표준 라이브러리만 사용(PyYAML 불필요).

사용법: python3 normalize_raw.py "<볼트경로>"
"""
import sys, os, re
from pathlib import Path
from datetime import date, datetime

CANDIDATE_DIRS = ["Clippings", "Clipped", "Web Clips", "Webclips", "Inbox"]
PROTECTED = {"CLAUDE.md", "README.md", "_Core-Context.md"}


def split_fm(text):
    """(frontmatter_str|None, body_str) 반환."""
    if text.startswith("---\n"):
        end = text.find("\n---", 4)
        if end != -1:
            fm = text[4:end]
            rest = text[end + 4:]
            if rest.startswith("\n"):
                rest = rest[1:]
            return fm, rest
    return None, text


def has_key(fm, key):
    return re.search(rf"(?m)^{re.escape(key)}\s*:", fm) is not None


def get_val(fm, key):
    m = re.search(rf"(?m)^{re.escape(key)}\s*:[ \t]*(.*)$", fm)
    return m.group(1).strip().strip('"').strip("'") if m else None


def normalize_fm(fm, default_type="article"):
    fm = fm or ""
    # type 먼저 보장 (tags 치환에 사용)
    if not has_key(fm, "type"):
        fm = (f"type: {default_type}\n" + fm).rstrip("\n")
    ttype = get_val(fm, "type") or default_type
    # 기본 클리퍼의 'clippings' 태그를 우리 규칙으로
    fm = re.sub(r'(?m)^(\s*-\s*)["\']?clippings["\']?\s*$', rf"\1raw/{ttype}", fm)
    fm = re.sub(r'(?m)^tags:[ \t]*["\']?clippings["\']?\s*$', f"tags:\n  - raw/{ttype}", fm)
    # 누락 키 보강
    additions = []
    if not has_key(fm, "created"):
        additions.append(f"created: {date.today().isoformat()}")
    if not has_key(fm, "status"):
        additions.append("status: inbox")
    if not has_key(fm, "purpose"):
        additions.append('purpose: ""')
    if not has_key(fm, "tags"):
        additions.append(f"tags:\n  - raw/{ttype}")
    if additions:
        fm = fm.rstrip("\n") + "\n" + "\n".join(additions)
    return fm


def dated_name(name, created):
    if re.match(r"^\d{4}-\d{2}-\d{2} - ", name):
        return name
    return f"{created} - {name}"


def unique_dest(dest: Path):
    if not dest.exists():
        return dest
    stem, suf = dest.stem, dest.suffix
    i = 2
    while True:
        cand = dest.with_name(f"{stem} ({i}){suf}")
        if not cand.exists():
            return cand
        i += 1


def process(path: Path, raw_dir: Path, move: bool):
    text = path.read_text(encoding="utf-8")
    fm, body = split_fm(text)
    created = (fm and get_val(fm, "created")) or \
        datetime.fromtimestamp(path.stat().st_mtime).date().isoformat()
    new_fm = normalize_fm(fm)
    new_text = f"---\n{new_fm}\n---\n{body}" if body else f"---\n{new_fm}\n---\n"

    dest_dir = raw_dir if move else path.parent
    dest = dest_dir / dated_name(path.name, created)

    content_changed = new_text != text
    will_move = dest.resolve() != path.resolve()
    if not content_changed and not will_move:
        return None  # 이미 정규화됨

    if will_move:
        dest = unique_dest(dest)
    dest.write_text(new_text, encoding="utf-8")
    if will_move and dest.resolve() != path.resolve():
        path.unlink()
    return (str(path), str(dest), content_changed, will_move)


def main():
    vault = Path(sys.argv[1] if len(sys.argv) > 1
                 else os.path.expanduser("~/Documents/llm-wiki-vault")).expanduser()
    raw = vault / "Raw"
    if not raw.is_dir():
        print(f"❌ Raw 폴더가 없습니다: {raw} (LLM Wiki 볼트가 맞나요?)")
        sys.exit(1)

    actions = []
    # 1) 후보 폴더 → Raw 이동 + 정규화
    for d in CANDIDATE_DIRS:
        p = vault / d
        if p.is_dir():
            for f in sorted(p.glob("*.md")):
                r = process(f, raw, move=True)
                if r:
                    actions.append(r)
            # 비었으면 폴더 제거 (.gitkeep 등만 남으면 유지)
            leftover = [x for x in p.iterdir() if x.name != ".DS_Store"]
            if not leftover:
                p.rmdir()
                print(f"🗑  빈 폴더 제거: {d}/")
    # 2) Raw 안의 비규칙 파일 정규화 (이동 없음)
    for f in sorted(raw.glob("*.md")):
        if f.name in PROTECTED:
            continue
        r = process(f, raw, move=True)  # Raw 내부면 move 효과는 이름 보정만
        if r:
            actions.append(r)

    if not actions:
        print("✅ 정규화할 항목 없음 — Raw가 이미 LLM Wiki 규칙에 맞습니다.")
        return
    print(f"✅ {len(actions)}건 정규화:")
    for src, dst, changed, moved in actions:
        tag = "이동+보정" if moved and changed else ("이동" if moved else "보정")
        print(f"  [{tag}] {Path(src).name}  →  Raw/{Path(dst).name}")
    print("\n다음: /llm-wiki ingest 로 'inbox' 상태 소스를 소화하세요 (수집 목적 인터뷰 → Wiki 정리).")


if __name__ == "__main__":
    main()
