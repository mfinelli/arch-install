# http://stackoverflow.com/a/17695543
function prompt_yesno() {
    read -p "$1 "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
