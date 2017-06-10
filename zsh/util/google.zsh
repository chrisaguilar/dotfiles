function google() {
    open "https://google.com/search?q=`echo $@ | tr \"[:blank:]\" +`"
}
