#!/bin/bash

# GitHub Secrets 验证脚本
# 请检查以下 GitHub Secrets 的值是否与下面显示的完全一致

echo "======================================"
echo "GitHub Secrets 配置验证"
echo "======================================"
echo ""

# 1. 显示 keystore 信息
echo "1. Keystore 文件信息："
/opt/homebrew/opt/openjdk@17/bin/keytool -list -keystore app/clocker-release.keystore -alias clocker -storepass 'Qazwsx@2026' 2>&1 | head -3
echo ""

# 2. 显示密码
echo "2. 正确的密码配置："
echo "   KEYSTORE_PASSWORD: Qazwsx@2026"
echo "   KEY_PASSWORD: Qazwsx@2026"
echo "   KEY_ALIAS: clocker"
echo ""

# 3. 显示 Base64 长度
echo "3. Base64 编码信息："
BASE64_LEN=$(base64 -i app/clocker-release.keystore | wc -c)
echo "   Base64 长度应为: $BASE64_LEN 字符"
echo ""

# 4. 验证步骤
echo "======================================"
echo "请按以下步骤检查 GitHub Secrets："
echo "======================================"
echo ""
echo "1. 访问: https://github.com/Vincent-chao-lang/clocker/settings/secrets/actions"
echo ""
echo "2. 检查并更新以下 Secrets："
echo ""
echo "   KEYSTORE_BASE64:"
echo "   - 复制下面完整的 Base64 字符串（3665 字符）"
echo "   - 确保没有多余的空格或换行"
echo ""
echo "   KEYSTORE_PASSWORD:"
echo "   - 值应为: Qazwsx@2026"
echo "   - 注意大小写"
echo ""
echo "   KEY_ALIAS:"
echo "   - 值应为: clocker"
echo ""
echo "   KEY_PASSWORD:"
echo "   - 值应为: Qazwsx@2026"
echo ""
echo "======================================"
echo "完整的 Base64 字符串："
echo "======================================"
base64 -i app/clocker-release.keystore
echo ""
echo "======================================"
