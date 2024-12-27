rm -rf /zkaif.github.io/github/docs
cd /zkaif.github.io
jekyll build --destination github/docs
cd /zkaif.github.io/github/docs
git add .
git commit . -m "publish"
git push
