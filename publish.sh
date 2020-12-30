jekyll build
rm -rf ./docs
cp -r ./_site ./docs
cd ./docs
git add .|git commit . -m "publish"|git push
