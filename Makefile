default: index.html write.html unlock.html

index.html: miniLockLib.js minipost.js stylesheets/*.css
	echo '<!DOCTYPE HTML><meta charset="UTF-8">' > index.html
	echo '<title>miniLock Postcard</title>' >> index.html
	echo '<!-- Review source code at https://github.com/minipostlink/minipost/tree/deploy -->' >> index.html
	echo '<script src="miniLockLib.js" charset="UTF-8"></script>' >> index.html
	echo '<script src="minipost.js" charset="UTF-8"></script>' >> index.html
	echo '<h1 aria-live="polite"></h1>' >> index.html
	echo '<style>' >> index.html
	cat stylesheets/zero.css >> index.html
	cat stylesheets/basics.css >> index.html
	cat stylesheets/typefaces.css >> index.html
	cat stylesheets/postcard.css >> index.html
	cat stylesheets/outputs.css >> index.html
	cat stylesheets/index.css >> index.html
	cat stylesheets/write.css >> index.html
	cat stylesheets/unlock.css >> index.html
	cat stylesheets/paint.css >> index.html
	echo '</style>' >> index.html

unlock.html: index.html
	cp index.html unlock.html

write.html: index.html
	cp index.html write.html

minipost.js: zepto.js underscore.js backbone.js minipost.coffee views/HTML.stamps.coffee models/*.coffee views/*.coffee
	rm -f minipost.js
	cat zepto.js >> minipost.js
	echo ";\n" >> minipost.js
	cat underscore.js >> minipost.js
	echo ";\n" >> minipost.js
	cat backbone.js >> minipost.js
	echo ";\n" >> minipost.js
	browserify --transform coffeeify minipost.coffee >> minipost.js

backbone.js:
	cp node_modules/backbone/backbone.js backbone.js

miniLockLib.js:
	cp node_modules/miniLockLib/miniLockLib.js miniLockLib.js

underscore.js:
	cp node_modules/underscore/underscore.js underscore.js

zepto.js: node_modules/zepto.js
	cp node_modules/zepto.js zepto.js

node_modules/zepto.js:
	curl https://madrobby.github.io/zepto/zepto.js > node_modules/zepto.js

views/HTML.stamps.coffee:
	make $(subst .svg,.coffee,$(wildcard stamps/*.svg))
	cat stamps/*.coffee > $@

stamps/%.coffee: stamps/%.svg
	echo module.exports[\"$(basename $(@F))\"] = \"\"\" > '$@'
	cat '$<' \
		| sed 's/<?xml version="1.0" encoding="UTF-8" standalone="no"?>//' \
		| sed 's/ sketch:type="MSPage"//' \
		| sed 's/ sketch:type="MSArtboardGroup"//' \
		| sed 's/ sketch:type="MSShapeGroup"//' \
		| sed 's/<desc>Created with Sketch.<\/desc>//' \
		| sed 's/ id="radialGradient/ preserve-id="radialGradient/' \
		| sed 's/ id=/ class=/' \
		| sed 's/ preserve-id=/ id=/' \
		| sed 's/radialGradient-/$(basename $(@F))-radialGradient-/' \
		| grep '<' \
		>> '$@'
	echo \"\"\" >> '$(basename $@).coffee'

clean:
	rm -f *.html
	rm -f minipost.js
	rm -f stamps/*.coffee
	rm -f views/HTML.stamps.coffee

repo:
	rm -rf .git
	git init
	git config user.name "45678"
	git config user.email "undefined@undefined"
	make views/HTML.stamps.coffee
	git add --all
	git commit --message "INIT master branch"
	git checkout -b deploy
	rm .gitignore
	echo "node_modules" >> .gitignore
	echo "stamps" >> .gitignore
	git add .gitignore
	git commit --message "INIT deploy branch"
	git checkout master
	git remote add origin git@github.com:minipostlink/minipost.git
	git remote add minipost.link core@sin.minipost.link:minipost.git
	git remote add auto.minipost.link core@nyc.minipost.link:minipost.git
	git remote add minipostlink.github.io git@github.com:minipostlink/minipostlink.github.io.git
	git branch

deploy:
	git checkout master
	git checkout deploy
	git merge master
	make clean index.html unlock.html write.html
	git add --all
	git commit --message "Comitted after merge with 'make deploy'"
	git checkout master
	make index.html

nodes:
	make minipostlink.github.io
	make auto.minipost.link
	make minipost.link
	make deploy_mirror

deploy_mirror:
	git push origin deploy

minipost.link:
	git push minipost.link deploy

auto.minipost.link:
	git push auto.minipost.link deploy

minipostlink.github.io:
	git push minipostlink.github.io deploy:deploy
	git push minipostlink.github.io deploy:master

pow:
	mkdir -p ~/.pow/minipost
	ln -s $(PWD) ~/.pow/minipost/public

unlink_pow:
	rm -rf ~/.pow/minipost
