#!/usr/bin/env bash
# Games777 development validation (syntax + lint + smoke tests).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export WORKSPACE="$ROOT"
cd "$ROOT"

echo "=== Games777 dev checks ==="
echo "Workspace: $ROOT"
echo ""

echo "--- Syntax check (luajit -bl) ---"
SYNTAX_ERRORS=0
while IFS= read -r -d '' file; do
    if ! luajit -bl "$file" >/dev/null 2>&1; then
        echo "SYNTAX ERROR: $file"
        SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
    fi
done < <(find "$ROOT" -name "*.lua" -not -path "*/scripts/dev/*" -print0)

if [ "$SYNTAX_ERRORS" -eq 0 ]; then
    LUA_COUNT=$(find "$ROOT" -name "*.lua" -not -path "*/scripts/dev/*" | wc -l)
    echo "All $LUA_COUNT Lua files passed syntax check."
else
    echo "$SYNTAX_ERRORS file(s) failed syntax check."
    exit 1
fi
echo ""

echo "--- Luacheck ---"
set +e
LINT_SUMMARY=$(luacheck "$ROOT" --quiet 2>&1)
LINT_EXIT=$?
set -e
echo "$LINT_SUMMARY" | tail -3
if [ "$LINT_EXIT" -gt 1 ]; then
    echo "Luacheck reported errors; see output above."
    exit 1
fi
echo "Luacheck completed (warnings are expected for Cocos globals)."
echo ""

echo "--- Smoke tests ---"
lua5.1 "$ROOT/scripts/dev/validate.lua"
echo ""

echo "--- Navigation API probe (optional connectivity) ---"
PKG_NAME=$(lua5.1 -e "
package.path='$ROOT/?.lua;$ROOT/?/init.lua;$ROOT/cocos/cocos2d/?.lua;'..package.path
local f=io.open('$ROOT/bootstrap/src/BuildConfig.json','r')
local raw=f:read('*a'); f:close()
local j=require('json'); print(j.decode(raw).PKG_NAME)
" 2>/dev/null || echo "com.Games777.ow")
DOMAIN=$(lua5.1 -e "
package.path='$ROOT/?.lua;$ROOT/?/init.lua;$ROOT/cocos/?.lua;$ROOT/cocos/?/init.lua;$ROOT/cocos/cocos2d/?.lua;'..package.path
local f=io.open('$ROOT/bootstrap/src/BuildConfig.json','r')
local raw=f:read('*a'); f:close()
local j=require('json'); print(j.decode(raw).DomainUrl)
" 2>/dev/null || echo "")
if [ -n "$DOMAIN" ]; then
    URL="${DOMAIN}${PKG_NAME}"
    HTTP_CODE=$(curl -sS -o /tmp/nav_probe.json -w "%{http_code}" --connect-timeout 8 --max-time 15 "$URL" || echo "000")
    echo "GET $URL -> HTTP $HTTP_CODE"
    if [ "$HTTP_CODE" = "200" ]; then
        echo "Navigation response:"
        head -c 200 /tmp/nav_probe.json
        echo ""
    fi
fi

echo ""
echo "=== All dev checks passed ==="
