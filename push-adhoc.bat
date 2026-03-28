@echo off
cd /d C:\Projects\memo_app
git add -A
git -c user.name="hert525" -c user.email="hrt525525@gmail.com" commit -m "fix: use ad_hoc signing type"
git push origin main
