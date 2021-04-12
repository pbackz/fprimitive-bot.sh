check-scripts: *.sh ; shellcheck -x *.sh ;

check-primitive: fprimitive-bot.sh ; shellcheck -x fprimitive-bot.sh ; 