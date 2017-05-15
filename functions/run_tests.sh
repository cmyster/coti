run_tests ()
{
    HOST=$1
    USER=$2
    TAG=$3

    case "$USER" in
        root) HOME="root" ;;
           *) HOME="home/$USER" ;;
    esac

    cp -r $CWD/tests .
    echo "Creating a list of relevant tests."

    rm -rf test_list
    for file in $(ls tests/test_*.sh)
    do
        if grep -e "TAG.*$TAG" $file &> /dev/null
        then
            echo "Adding test: $(grep NAME $file | cut -d "=" -f 2)"
            echo $file >> test_list
        fi
    done

    echo "Moving tests to ${HOST}."

    tar cf tests.tar -T test_list
    $SSH ${2}@$HOST "rm -rf tests && mkdir tests"
    scp -q tests.tar ${2}@${HOST}:/${HOME}/tests/
    $SSH ${2}@$HOST "tar xf /${HOME}/tests/tests.tar && rm -rf /${HOME}/tests/tests.tar"
    $SSH ${2}@$HOST "chmod +x /${HOME}/tests/*"
    set > env
    scp -q env ${2}@${HOST}:/${HOME}/tests/

    echo "Starting to run tests with tag $TAG on $HOST as user ${USER}."
    for test in $(cat test_list)
    do
        NAME=$(grep NAME $test | cut -d "=" -f 2)
        DESCRIPTION=$(grep DESCRIPTION $test | cut -d "=" -f 2)
        echo "Running: $NAME"
        echo "Description: $DESCRIPTION"
        if $SSH ${USER}@$HOST /${HOME}/$test
        then
            echo "[PASS] $NAME"
        else
            echo "[FAIL] $NAME"
        fi

        echo -e "==="
    done
}
