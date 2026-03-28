@echo off
cd /d C:\Projects\memo_app
git add codemagic.yaml
git -c user.name="hert525" -c user.email="hrt525525@gmail.com" commit -m "add codemagic.yaml"
git push origin main
