#!/usr/bin/env bash
# diagnose.sh — собирает диагностику по ошибке CONFIG_CC_STACKPROTECTOR_STRONG
# Запускать из корня репозитория ядра (там же, где Makefile и build.sh)

OUT="diagnose_output.txt"
> "$OUT"

section() {
    echo "" >> "$OUT"
    echo "===== $1 =====" >> "$OUT"
}

section "pwd / repo check"
pwd >> "$OUT"
ls Makefile scripts/Kbuild.include 2>&1 >> "$OUT"

section "Makefile: STACKPROTECTOR_STRONG context"
grep -n -B3 -A8 "STACKPROTECTOR_STRONG" Makefile >> "$OUT" 2>&1

section "Makefile: prepare-compiler-check target"
grep -n -A20 "^prepare-compiler-check" Makefile >> "$OUT" 2>&1

section "scripts/Kbuild.include: cc-option macro"
grep -n -A12 "^cc-option " scripts/Kbuild.include >> "$OUT" 2>&1

section "scripts/Kbuild.include: try-run macro (used by cc-option)"
grep -n -A15 "^try-run " scripts/Kbuild.include >> "$OUT" 2>&1

section "python references in build scripts"
grep -rn "python" scripts/*.sh 2>/dev/null >> "$OUT"
grep -rln "python" scripts/ 2>/dev/null >> "$OUT"

section "python availability on this system"
which python 2>&1 >> "$OUT"
which python3 2>&1 >> "$OUT"
python --version 2>&1 >> "$OUT"
python3 --version 2>&1 >> "$OUT"

section "clang / toolchain in PATH"
which clang 2>&1 >> "$OUT"
clang --version 2>&1 >> "$OUT"
echo "PATH=$PATH" >> "$OUT"

section "relevant env vars"
env | grep -E "^(ARCH|CC|LD|LLVM|CLANG_TRIPLE|CROSS_COMPILE)" >> "$OUT"

echo "Готово. Результат в $OUT"
cat "$OUT"