cd C:\Users\tmkin\OneDrive\Documents\Projects\softball-statline
git add --all
timestamp() {
  date +"at %H:%M:%S on %d/%m/%Y"
}
git commit -am "Update Softball Statline $(timestamp)"
git push origin master