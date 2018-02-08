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
    $SSH_CUST "${2}@$HOST" "rm -rf tests && mkdir tests"
    scp -q tests.tar "${2}@${HOST}:/${HOME}"/tests/
    $SSH_CUST "${2}@$HOST" "tar xf /${HOME}/tests/tests.tar && rm -rf /${HOME}/tests/tests.tar"
    $SSH_CUST "${2}@$HOST" "chmod +x /${HOME}/tests/*"
    set > env
    scp -q env "${2}@${HOST}:/${HOME}"/tests/

    echo "Starting to run tests with tag $TAG on $HOST as user ${USER}."
    while read -r test
    do
        NAME=$(grep NAME "$test" | cut -d "=" -f 2)
        DESCRIPTION=$(grep DESCRIPTION "$test" | cut -d "=" -f 2)
        echo "Running: $NAME"
        echo "Description: $DESCRIPTION"
        if $SSH_CUST "${USER}@$HOST /${HOME}/$test"
        then
            echo "[PASS] $NAME"
        else
            echo "[FAIL] $NAME"
        fi

        echo -e "==="
    done < test_list
}
