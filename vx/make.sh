echo "Building..."

# Cleam build and temp
rm -Rf build
rm -Rf temp

# Create the directories we need
directories=( "temp" "build" "build/css" "build/js" "build/img" )
for i in "${directories[@]}"
do
    mkdir $i
done

# Copying static files
files=( "index.html" "img/ajax-loader.gif" "js/wp-code-highlight.js" "js/backbone-min.js" "js/jquery-1.7.min.js" "js/underscore-min.js" "js/handlebars.runtime-1.0.rc.1.js" )
for i in "${files[@]}"
do
    cp -R src/$i build/$i
done

 
# Compiling handlebars template
handlebars src/template/ -f build/js/template.js

# Compiling coffeescript files
cat src/coffee/* > ./temp/main.coffee
coffee --compile --output build/js/ temp/
# We can remove the tempory directory for compiling coffeescript files
#rm -Rf temp

# compile less files
lessc src/less/style.less > build/css/style.css

# Sync with the server
#rsync -av * michel@neumino.com:www/new/

echo "Done."
