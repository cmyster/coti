run_tests ()
{
    HOST=$1
    USER=$2
    TAG=$3

    case "$USER" in
        root) HOME="root" ;;
           *) HOME="home/$USER" ;;
    esac

    rm -rf tests
    cp -r "$CWD"/tests .
    echo "Creating a list of relevant tests."

    rm -rf test_list
    for file in ./tests/test_*.sh
    do
        if grep -e "TAG.*$TAG" "$file" &> /dev/null
        then
            echo "Adding test: $(grep NAME "$file" | cut -d "=" -f 2)"
            echo "$file" >> test_list
        fi
    done

    echo "Moving tests to ${HOST}."

    tar cf tests.tar -T test_list
    $SSH_CUST "${USER}@$HOST" "rm -rf /${HOME}/tests && mkdir /${HOME}/tests"
    scp -q tests.tar "${USER}@${HOST}:/${HOME}"/tests/
    $SSH_CUST "${USER}@$HOST" "tar xf /${HOME}/tests/tests.tar && rm -rf /${HOME}/tests/tests.tar"
    $SSH_CUST "${USER}@$HOST" "chmod +x /${HOME}/tests/*"
    set | grep "^[A-Z].*=" | grep -v "\\$\|PATH\|HOME\|BASH\|EUID\|PPID\|SHELL\|UID" > env
    scp -q env "${USER}@${HOST}:/${HOME}/tests/"

    echo "Starting to run tests with tag $TAG on $HOST as user ${USER}."
    for test in $(cat test_list)
    do
        NAME=$(grep NAME "$test" | cut -d "=" -f 2)
        DESCRIPTION=$(grep DESCRIPTION "$test" | cut -d "=" -f 2)
        echo "Running:     $NAME"
        echo "Description: $DESCRIPTION"
        if $SSH_CUST ${USER}@$HOST "/${HOME}/$test" &> /dev/null
        then
            echo "[PASS]"
        else
            echo "[FAIL]"
        fi
        echo -e "===================="
    done
}
