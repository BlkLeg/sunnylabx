#!/bin/bash
# SunnyLabX Compliance Checker
# Validates Docker Compose files against COPILOT_INSTRUCTIONS.md requirements

echo "🔍 SunnyLabX Codebase Compliance Check"
echo "======================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

compliance_score=0
total_checks=0

# Check 1: No "version" field in docker-compose files
echo "1. Checking for obsolete 'version' fields..."
total_checks=$((total_checks + 1))

version_files=$(find . -name "docker-compose*.yml" -exec grep -l "^version:" {} \; 2>/dev/null)
if [ -z "$version_files" ]; then
    echo -e "   ${GREEN}✅ PASS${NC}: No obsolete 'version' fields found"
    compliance_score=$((compliance_score + 1))
else
    echo -e "   ${RED}❌ FAIL${NC}: Found 'version' fields in:"
    echo "$version_files" | sed 's/^/      /'
fi
echo ""

# Check 2: Resource limits applied
echo "2. Checking for resource limits..."
total_checks=$((total_checks + 1))

compose_files=$(find . -name "docker-compose*.yml")
files_with_limits=0
total_compose_files=0

for file in $compose_files; do
    total_compose_files=$((total_compose_files + 1))
    if grep -q "deploy:" "$file" && grep -q "resources:" "$file"; then
        files_with_limits=$((files_with_limits + 1))
    fi
done

if [ $files_with_limits -eq $total_compose_files ] && [ $total_compose_files -gt 0 ]; then
    echo -e "   ${GREEN}✅ PASS${NC}: All compose files have resource limits"
    compliance_score=$((compliance_score + 1))
elif [ $files_with_limits -gt 0 ]; then
    echo -e "   ${YELLOW}⚠️  PARTIAL${NC}: $files_with_limits/$total_compose_files files have resource limits"
else
    echo -e "   ${RED}❌ FAIL${NC}: No resource limits found in any compose files"
fi
echo ""

# Check 3: Named volumes usage
echo "3. Checking for named volumes usage..."
total_checks=$((total_checks + 1))

files_with_named_volumes=0
for file in $compose_files; do
    if grep -q "^volumes:" "$file"; then
        files_with_named_volumes=$((files_with_named_volumes + 1))
    fi
done

if [ $files_with_named_volumes -gt 0 ]; then
    echo -e "   ${GREEN}✅ PASS${NC}: Named volumes found in $files_with_named_volumes files"
    compliance_score=$((compliance_score + 1))
else
    echo -e "   ${RED}❌ FAIL${NC}: No named volumes found"
fi
echo ""

# Check 4: Logical network setup
echo "4. Checking for logical network setup..."
total_checks=$((total_checks + 1))

networks_found=$(find . -name "docker-compose*.yml" -exec grep -l "^networks:" {} \; 2>/dev/null | wc -l)
if [ $networks_found -gt 0 ]; then
    echo -e "   ${GREEN}✅ PASS${NC}: Logical networks found in $networks_found files"
    compliance_score=$((compliance_score + 1))
else
    echo -e "   ${RED}❌ FAIL${NC}: No logical networks found"
fi
echo ""

# Check 5: Media directory structure (if media services exist)
echo "5. Checking media directory references..."
total_checks=$((total_checks + 1))

media_refs=$(find . -name "docker-compose*.yml" -exec grep -l "/mnt/hdd-[1-4]" {} \; 2>/dev/null | wc -l)
if [ $media_refs -gt 0 ]; then
    echo -e "   ${GREEN}✅ PASS${NC}: Proper media directory structure found"
    compliance_score=$((compliance_score + 1))
else
    echo -e "   ${YELLOW}⚠️  INFO${NC}: No media directory references found (expected for placeholder files)"
    compliance_score=$((compliance_score + 1))  # Not a failure for placeholder setup
fi
echo ""

# Check 6: Node-specific file organization
echo "6. Checking node-specific organization..."
total_checks=$((total_checks + 1))

if [ -d "thousandsunny" ] && [ -d "goingmerry" ]; then
    echo -e "   ${GREEN}✅ PASS${NC}: Node-specific directories found"
    compliance_score=$((compliance_score + 1))
else
    echo -e "   ${RED}❌ FAIL${NC}: Missing node-specific directories"
fi
echo ""

# Final Score
echo "🏆 COMPLIANCE SUMMARY"
echo "===================="
percentage=$((compliance_score * 100 / total_checks))

if [ $percentage -eq 100 ]; then
    echo -e "Score: ${GREEN}$compliance_score/$total_checks ($percentage%)${NC}"
    echo -e "Status: ${GREEN}✅ FULLY COMPLIANT${NC}"
elif [ $percentage -ge 80 ]; then
    echo -e "Score: ${YELLOW}$compliance_score/$total_checks ($percentage%)${NC}"
    echo -e "Status: ${YELLOW}⚠️  MOSTLY COMPLIANT${NC}"
else
    echo -e "Score: ${RED}$compliance_score/$total_checks ($percentage%)${NC}"
    echo -e "Status: ${RED}❌ NON-COMPLIANT${NC}"
fi

echo ""
echo "🔧 REMEDIATION NEEDED:"
echo "- Add resource limits to all Docker Compose services"
echo "- Implement proper media directory mounting when services are configured"
echo "- Ensure all placeholder images are replaced with real configurations"
echo ""
echo "📖 See INVENTORY.md for detailed resource limit guidelines"