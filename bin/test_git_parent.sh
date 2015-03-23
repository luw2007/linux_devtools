pushedrev=...
basename=${1:-cef}
if ! baserev="$(git rev-parse --verify refs/heads/"$basename" 2>/dev/null)"; then
    echo "'$basename' is missing, call for help!"
    exit 1
fi
parents_of_children_of_base="$(
  git rev-list master --pretty=tformat:%P "$pushedrev" --not "$baserev" |
  grep -F "$baserev"
)"
case ",$parents_of_children_of_base" in
    ,)     echo "must descend from tip of '$basename'"
           exit 1 ;;
    ,*\ *) echo "must not merge tip of '$basename' (rebase instead)"
           exit 1 ;;
    ,*)    exit 0 ;;
esac
