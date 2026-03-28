@echo off
cd /d C:\Projects\memo_app
git add -A
git -c user.name="hert525" -c user.email="hrt525525@gmail.com" commit -m "try signed ipa build with fallback"
git push origin main
