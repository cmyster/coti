tempest_packages ()
{
    HOST_NAME=$1
    cat > tempest_packages <<EOF
PACKAGES=(
          aodh
          ceilometer
          cinder
          designate
          glance
          gnocchi
          heat
          horizon
          ironic
          ironic-inspector
          keystone
          magnum
          manila
          mistral
          murano
          neutron
          neutron-fwaas
          neutron-lbaas
          neutron-vpnaas
          nova
          sahara
          swift
          trove
          watcher
          zaqar
         )

for package in \${PACKAGES[@]}
do
    yum -q -y install python-\$package-tests
done
EOF

run_script_file tempest_packages root $HOST_NAME /root
}
